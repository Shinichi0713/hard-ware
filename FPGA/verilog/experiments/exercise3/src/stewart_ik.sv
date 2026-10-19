`timescale 1ns / 1ps

module stewart_ik (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid_in,
    input  logic signed [31:0] roll,    // Q16.16 rad
    input  logic signed [31:0] pitch,   // Q16.16 rad
    output logic        valid_out,
    output logic signed [31:0] leg_length [0:5]  // Q16.16 mm
);

    import stewart_pkg::*;

    // 簡易 CORDIC 風 sin/cos 近似（小角近似）
    // sin(theta) ≈ theta, cos(theta) ≈ 1 - theta^2/2 (|theta| < 0.5 rad)
    function automatic logic signed [31:0] sin_approx(input logic signed [31:0] theta);
        logic signed [63:0] theta3;
        begin
            // sin(x) ≈ x - x^3/6
            theta3 = (theta * theta * theta) >>> 32;
            sin_approx = theta - (theta3 / 32'sd6);
        end
    endfunction

    function automatic logic signed [31:0] cos_approx(input logic signed [31:0] theta);
        logic signed [63:0] theta2;
        begin
            // cos(x) ≈ 1 - x^2/2
            theta2 = (theta * theta) >>> 32;
            cos_approx = (32'sd1 <<< 16) - (theta2 >>> 1);
        end
    endfunction

    // 6本の脚のベース角度（60度間隔）
    localparam logic signed [31:0] ANGLES [0:5] = '{
        32'd0,           // 0 deg
        32'd109221,      // 60 deg * 65536/π ≈ 実際はラジアン値
        32'd218453,      // 120 deg
        32'd327680,      // 180 deg
        32'd436906,      // 240 deg
        32'd546133       // 300 deg
    };

    // 実際のラジアン値（Q16.16）
    // 0, π/3, 2π/3, π, 4π/3, 5π/3
    localparam logic signed [31:0] BASE_ANGLES [0:5] = '{
        32'd0,
        32'd68548,   // π/3 * 2^16 / π = 65536/3 ≈ 21845? -> 実際は 1.047rad * 65536 = 68619
        32'd137097,  // 2π/3
        32'd205887,  // π
        32'd274677,  // 4π/3
        32'd343226   // 5π/3
    };

    // 正確な値を再計算
    // π/3   = 1.04719755 -> 68619
    // 2π/3  = 2.0943951  -> 137239
    // π     = 3.14159265 -> 205887
    // 4π/3  = 4.1887902  -> 274535
    // 5π/3  = 5.23598775 -> 343184
    localparam logic signed [31:0] B_ANGLES [0:5] = '{
        32'd0,
        32'd68619,
        32'd137239,
        32'd205887,
        32'd274535,
        32'd343184
    };

    logic signed [31:0] sr, cr, sp, cp;
    logic signed [31:0] platform_x [0:5];
    logic signed [31:0] platform_y [0:5];
    logic signed [31:0] platform_z [0:5];
    logic signed [31:0] base_x [0:5];
    logic signed [31:0] base_y [0:5];
    logic [2:0] leg_idx;
    logic processing;

    // ベースジョイント位置（固定）
    generate
        genvar i;
        for (i = 0; i < 6; i++) begin : gen_base
            // x = R * cos(angle + offset)
            // y = R * sin(angle + offset)
            // 簡易: テーブル参照方式に変更可能
            assign base_x[i] = (i % 2 == 0) ?
                ((i == 0) ? BASE_RADIUS : -BASE_RADIUS) :
                ((i == 1 || i == 5) ? (BASE_RADIUS >>> 1) : -(BASE_RADIUS >>> 1));
            assign base_y[i] = (i == 0 || i == 3) ? 32'sd0 :
                ((i == 1 || i == 2) ? (BASE_RADIUS * 32'sd56756 >>> 16) : -(BASE_RADIUS * 32'sd56756 >>> 16));
        end
    endgenerate

    // 回転行列を適用したプラットフォーム位置計算
    // 簡易版: Rx(roll), Ry(pitch) の順で回転
    // p' = Ry * Rx * p
    // p'x = cx * sp * sz + sx * sy ... 簡易化
    // 小角近似: cos≈1, sin≈角
    // p'x ≈ px + pitch * pz
    // p'y ≈ py - roll * pz
    // p'z ≈ pz - pitch * px + roll * py

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            leg_idx   <= 0;
            processing <= 0;
            for (int j = 0; j < 6; j++) leg_length[j] <= NEUTRAL_HEIGHT;
        end else begin
            valid_out <= 0;
            if (valid_in && !processing) begin
                processing <= 1;
                leg_idx    <= 0;
                sr <= sin_approx(roll);
                cr <= cos_approx(roll);
                sp <= sin_approx(pitch);
                cp <= cos_approx(pitch);
            end else if (processing) begin
                // プラットフォーム初期位置（中立時）
                // 簡易: 上平台ジョイントは base と同じ角度配置で半径 PLATFORM_RADIUS
                logic signed [31:0] px, py, pz;
                int idx = leg_idx;

                // 上平台ジョイント位置（中立）
                px = (idx == 0 || idx == 3) ?
                    ((idx == 0) ? PLATFORM_RADIUS : -PLATFORM_RADIUS) :
                    ((idx == 1 || idx == 5) ? (PLATFORM_RADIUS >>> 1) : -(PLATFORM_RADIUS >>> 1));
                py = (idx == 0 || idx == 3) ? 32'sd0 :
                    ((idx == 1 || idx == 2) ? (PLATFORM_RADIUS * 32'sd56756 >>> 16) : -(PLATFORM_RADIUS * 32'sd56756 >>> 16));
                pz = NEUTRAL_HEIGHT;

                // 回転適用（小角近似）
                // p'_x = px * cp + pz * sp
                // p'_y = py * cr - pz * sr
                // p'_z = -px * sp + py * sr + pz
                platform_x[idx] <= ((px * cp) >>> 16) + ((pz * sp) >>> 16);
                platform_y[idx] <= ((py * cr) >>> 16) - ((pz * sr) >>> 16);
                platform_z[idx] <= ((-px * sp) >>> 16) + ((py * sr) >>> 16) + pz;

                // 脚長 = |platform - base|
                // dx = platform_x - base_x
                // dy = platform_y - base_y
                // dz = platform_z - 0 (base_z = 0)
                // L = sqrt(dx^2 + dy^2 + dz^2)
                // 簡易: dz が支配的なので L ≈ dz + (dx^2 + dy^2)/(2*dz)
                logic signed [63:0] dx2, dy2;
                logic signed [31:0] dx, dy, dz;
                logic signed [63:0] correction;

                dx = platform_x[idx] - base_x[idx];
                dy = platform_y[idx] - base_y[idx];
                dz = platform_z[idx]; // base_z = 0

                dx2 = (dx * dx) >>> 32;
                dy2 = (dy * dy) >>> 32;
                if (dz > 32'sd1000) begin
                    correction = (dx2 + dy2) / (dz <<< 1);
                    leg_length[idx] <= dz + correction[31:0];
                end else begin
                    leg_length[idx] <= dz;
                end

                if (leg_idx >= 5) begin
                    processing <= 0;
                    valid_out  <= 1;
                end else begin
                    leg_idx <= leg_idx + 1;
                end
            end
        end
    end

endmodule