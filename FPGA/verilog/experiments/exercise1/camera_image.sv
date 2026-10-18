// ============================================================================
// Camera 3D Spatial Reconstruction System (SystemVerilog)
// ============================================================================
// カメラの画素座標(u,v)と深度Zから3D空間座標(X,Y,Z)を復元し、
// 複数ポイント間の位置関係（距離行列・近傍関係）を構成します。
//
// 固小数点形式: Q16.16 (16bit整数部 + 16bit小数部)
// 座標単位: メートル (Q16.16)
// 画素座標: 整数 (0 ~ 1023)
// 深度Z: メートル (Q16.16)
// ============================================================================

`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
// 固定小数点ユーティリティパッケージ (Q16.16)
// ----------------------------------------------------------------------------
package fixed_point_pkg;
    localparam int FRAC_BITS = 16;
    localparam int SCALE     = 1 << FRAC_BITS;  // 65536

    // Q16.16 乗算 (a*b) -> c
    function automatic signed [63:0] qmul64(
        input signed [31:0] a,
        input signed [31:0] b
    );
        qmul64 = (64'(a) * 64'(b));
    endfunction

    // Q16.16 乗算結果をQ16.16に正規化
    function automatic signed [31:0] qmul(
        input signed [31:0] a,
        input signed [31:0] b
    );
        logic signed [63:0] tmp;
        tmp = qmul64(a, b);
        qmul = tmp[31 + FRAC_BITS : FRAC_BITS];
    endfunction

    // Q16.16 累積乗算加算: acc = acc + a*b
    function automatic signed [63:0] qmac64(
        input signed [63:0] acc,
        input signed [31:0] a,
        input signed [31:0] b
    );
        qmac64 = acc + qmul64(a, b);
    endfunction

    // 48bit値を32bitにクリップ（飽和）
    function automatic signed [31:0] qclip48to32(
        input signed [47:0] val
    );
        if (val >  signed'(48'h7FFF_FFFF_FFFF)) qclip48to32 = 32'h7FFF_FFFF;
        else if (val < signed'(48'h8000_0000_0000)) qclip48to32 = 32'h8000_0000;
        else qclip48to32 = val[31:0];
    endfunction

    // 64bit値を32bitにクリップ（飽和）
    function automatic signed [31:0] qclip64to32(
        input signed [63:0] val
    );
        if (val >  signed'(64'h7FFF_FFFF_FFFF_FFFF)) qclip64to32 = 32'h7FFF_FFFF;
        else if (val < signed'(64'h8000_0000_0000_0000)) qclip64to32 = 32'h8000_0000;
        else qclip64to32 = val[31:0];
    endfunction
endpackage

// ----------------------------------------------------------------------------
// Integer Square Root (Newton-Raphson / Non-restoring method)
// 入力: 64bit unsigned, 出力: 32bit unsigned (Q16.16)
// 用途: 3D距離計算 sqrt(dx^2 + dy^2 + dz^2)
// ----------------------------------------------------------------------------
module integer_sqrt_q16 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [63:0] radicand,     // Q32.32 相当 (64bit integer representing value * 2^32)
    output logic [31:0] root,         // Q16.16 結果
    output logic        done
);
    // 非復元法よる整数平方根 (64bit -> 32bit)
    // radicand は実際の値 * 2^32 と解釈し、結果は * 2^16 で返す
    // つまり radicand = value * 2^32 の平方根 = sqrt(value) * 2^16

    logic [63:0] a;       // 残り被開平方数
    logic [63:0] r;       // 余り
    logic [31:0] q;       // 結果（ルート）
    logic [5:0]  bit_pos; // 現在処理中のビット位置
    logic        busy;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy    <= 1'b0;
            done    <= 1'b0;
            root    <= '0;
            a       <= '0;
            r       <= '0;
            q       <= '0;
            bit_pos <= '0;
        end else begin
            if (start && !busy) begin
                busy    <= 1'b1;
                done    <= 1'b0;
                a       <= radicand;
                r       <= '0;
                q       <= '0;
                bit_pos <= 6'd32;  // 32 iterations for 32bit result
            end else if (busy) begin
                if (bit_pos == 0) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    root <= q;
                end else begin
                    bit_pos <= bit_pos - 1'b1;
                    logic [63:0] tmp_r;
                    logic [63:0] test_val;
                    tmp_r   = (r << 2) | ((a >> 62) & 2'b11);
                    a       <= a << 2;
                    test_val = (q << 2) | 2'b01;
                    if (tmp_r >= test_val) begin
                        r <= tmp_r - test_val;
                        q <= (q << 1) | 1'b1;
                    end else begin
                        r <= tmp_r;
                        q <= (q << 1);
                    end
                end
            end else begin
                done <= 1'b0;
            end
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Camera 3D Coordinate Reconstructor
// ピンホールカメラモデルによる3D復元:
//   X = (u - cx) * Z / fx
//   Y = (v - cy) * Z / fy
//   Z = Z (そのまま)
//
// 入力: 画素座標(u,v) [10bit整数], 深度Z [Q16.16]
// 出力: 3D座標(X,Y,Z) [Q16.16]
// ----------------------------------------------------------------------------
module camera_3d_reconstructor #(
    parameter signed [31:0] FX     = 32'd39321600,  // 600.0  * 65536
    parameter signed [31:0] FY     = 32'd39321600,  // 600.0  * 65536
    parameter signed [31:0] CX     = 32'd20971520,  // 320.0  * 65536
    parameter signed [31:0] CY     = 32'd15728640,  // 240.0  * 65536
    parameter signed [31:0] INV_FX = 32'd109,        // 1/600  * 65536 ≈ 109
    parameter signed [31:0] INV_FY = 32'd109         // 1/600  * 65536 ≈ 109
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [9:0]  pixel_u,    // 画素X座標 (0 ~ 1023)
    input  logic [9:0]  pixel_v,    // 画素Y座標 (0 ~ 1023)
    input  logic [31:0] depth_z,  // Q16.16 深度 (メートル)
    output logic [31:0] world_x,    // Q16.16 3D X座標
    output logic [31:0] world_y,    // Q16.16 3D Y座標
    output logic [31:0] world_z,    // Q16.16 3D Z座標
    output logic        valid
);
    import fixed_point_pkg::*;

    // パイプラインステージ制御
    logic [1:0] stage;
    logic [31:0] du_q16;  // (u - cx) in Q16.16
    logic [31:0] dv_q16;  // (v - cy) in Q16.16
    logic [31:0] z_reg;

    // (u - cx) と (v - cy) をQ16.16に変換
    // u,v は整数なので、左シフト16bitでQ16.16化
    wire signed [31:0] u_q16 = {22'b0, pixel_u} <<< FRAC_BITS;  // Q16.16
    wire signed [31:0] v_q16 = {22'b0, pixel_v} <<< FRAC_BITS;  // Q16.16

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage   <= 2'd0;
            valid   <= 1'b0;
            world_x <= '0;
            world_y <= '0;
            world_z <= '0;
            du_q16  <= '0;
            dv_q16  <= '0;
            z_reg   <= '0;
        end else if (en) begin
            case (stage)
                2'd0: begin
                    // Stage 0: 画素座標と主点の差分計算
                    du_q16 <= u_q16 - CX;   // (u - cx) in Q16.16
                    dv_q16 <= v_q16 - CY;   // (v - cy) in Q16.16
                    z_reg  <= depth_z;
                    stage  <= 2'd1;
                    valid  <= 1'b0;
                end
                2'd1: begin
                    // Stage 1: X = du * Z / fx = du * Z * inv_fx
                    //         Y = dv * Z / fy = dv * Z * inv_fy
                    // Q16.16 * Q16.16 * Q16.16 -> 調整が必要
                    // du * Z = Q32.32 -> >>16 = Q16.16
                    // その後 * inv_fx (Q16.16) -> >>16 = Q16.16
                    logic signed [63:0] xz_tmp, yz_tmp;
                    xz_tmp = (64'(du_q16) * 64'(z_reg)) >>> FRAC_BITS;
                    yz_tmp = (64'(dv_q16) * 64'(z_reg)) >>> FRAC_BITS;

                    world_x <= qclip64to32((xz_tmp * 64'(INV_FX)) >>> FRAC_BITS);
                    world_y <= qclip64to32((yz_tmp * 64'(INV_FY)) >>> FRAC_BITS);
                    world_z <= z_reg;
                    stage   <= 2'd2;
                end
                2'd2: begin
                    valid <= 1'b1;
                    stage <= 2'd0;  // 次の入力を待つ
                end
                default: stage <= 2'd0;
            endcase
        end else begin
            valid <= 1'b0;
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Point-to-Point 3D Distance Calculator
// 2点間のユークリッド距離: d = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
// ----------------------------------------------------------------------------
module point_distance_calculator (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [31:0] x1, y1, z1,   // Q16.16 point 1
    input  logic [31:0] x2, y2, z2,   // Q16.16 point 2
    output logic [31:0] distance,      // Q16.16 distance
    output logic        done
);
    import fixed_point_pkg::*;

    logic [2:0] state;
    logic [31:0] dx, dy, dz;
    logic [63:0] dx2, dy2, dz2;
    logic [63:0] sum_sq;
    logic [63:0] radicand;
    logic        sqrt_start;
    logic [31:0] sqrt_root;
    logic        sqrt_done;

    integer_sqrt_q16 u_sqrt (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (sqrt_start),
        .radicand (radicand),
        .root     (sqrt_root),
        .done     (sqrt_done)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= 3'd0;
            done       <= 1'b0;
            distance   <= '0;
            dx <= '0; dy <= '0; dz <= '0;
            dx2 <= '0; dy2 <= '0; dz2 <= '0;
            sum_sq <= '0;
            radicand <= '0;
            sqrt_start <= 1'b0;
        end else begin
            case (state)
                3'd0: begin
                    done <= 1'b0;
                    if (start) begin
                        // Stage 0: 差分計算
                        dx <= x2 - x1;
                        dy <= y2 - y1;
                        dz <= z2 - z1;
                        state <= 3'd1;
                    end
                end
                3'd1: begin
                    // Stage 1: 二乗計算 (Q16.16 * Q16.16 = Q32.32)
                    dx2 <= qmul64(dx, dx);  // Q32.32
                    dy2 <= qmul64(dy, dy);
                    dz2 <= qmul64(dz, dz);
                    state <= 3'd2;
                end
                3'd2: begin
                    // Stage 2: 二乗和 (Q32.32)
                    sum_sq <= dx2 + dy2 + dz2;
                    state  <= 3'd3;
                end
                3'd3: begin
                    // Stage 3: 平方根開始
                    // sum_sq は Q32.32。
                    // sqrt(sum_sq) = sqrt(value * 2^32) = sqrt(value) * 2^16
                    // → 結果は Q16.16 としてそのまま解釈可能
                    radicand   <= sum_sq;
                    sqrt_start <= 1'b1;
                    state      <= 3'd4;
                end
                3'd4: begin
                    sqrt_start <= 1'b0;
                    if (sqrt_done) begin
                        distance <= sqrt_root;
                        done     <= 1'b1;
                        state    <= 3'd0;
                    end
                end
                default: state <= 3'd0;
            endcase
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Multi-Point Spatial Relation Analyzer
// N個の3Dポイント間の距離行列を計算し、閾値による近傍関係を判定
// ----------------------------------------------------------------------------
module spatial_relation_analyzer #(
    parameter int MAX_POINTS = 8,
    parameter signed [31:0] PROXIMITY_THRESHOLD = 32'd6554  // 0.1m in Q16.16
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [3:0]  num_points,   // 実際のポイント数 (2 ~ MAX_POINTS)
    // ポイント配列 (Q16.16)
    input  logic [31:0] points_x [0:MAX_POINTS-1],
    input  logic [31:0] points_y [0:MAX_POINTS-1],
    input  logic [31:0] points_z [0:MAX_POINTS-1],
    // 距離行列力 (Q16.16) - 上三角行列のみ有効
    output logic [31:0] dist_matrix [0:MAX_POINTS-1][0:MAX_POINTS-1],
    // 近傍関係 (閾値以下なら1)
    output logic        proximity_mask [0:MAX_POINTS-1][0:MAX_POINTS-1],
    output logic        done
);
    logic [3:0] i, j;
    logic [3:0] state;
    logic       dist_start;
    logic [31:0] dist_result;
    logic       dist_done;

    point_distance_calculator u_dist (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (dist_start),
        .x1       (points_x[i]),
        .y1       (points_y[i]),
        .z1       (points_z[i]),
        .x2       (points_x[j]),
        .y2       (points_y[j]),
        .z2       (points_z[j]),
        .distance (dist_result),
        .done     (dist_done)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 4'd0;
            done  <= 1'b0;
            i <= '0; j <= '0;
            dist_start <= 1'b0;
            for (int m = 0; m < MAX_POINTS; m++) begin
                for (int n = 0; n < MAX_POINTS; n++) begin
                    dist_matrix[m][n] <= '0;
                    proximity_mask[m][n] <= 1'b0;
                end
            end
        end else begin
            case (state)
                4'd0: begin
                    done <= 1'b0;
                    if (start && num_points >= 2 && num_points <= MAX_POINTS) begin
                        i <= 4'd0;
                        j <= 4'd1;
                        state <= 4'd1;
                    end
                end
                4'd1: begin
                    // 距離計算開始
                    if (i < num_points && j < num_points) begin
                        dist_start <= 1'b1;
                        state <= 4'd2;
                    end else begin
                        state <= 4'd5;  // 完了
                    end
                end
                4'd2: begin
                    dist_start <= 1'b0;
                    if (dist_done) begin
                        // 距離行列に格納（対称行列）
                        dist_matrix[i][j] <= dist_result;
                        dist_matrix[j][i] <= dist_result;
                        // 近傍判定
                        if (dist_result <= PROXIMITY_THRESHOLD) begin
                            proximity_mask[i][j] <= 1'b1;
                            proximity_mask[j][i] <= 1'b1;
                        end else begin
                            proximity_mask[i][j] <= 1'b0;
                            proximity_mask[j][i] <= 1'b0;
                        end
                        state <= 4'd3;
                    end
                end
                4'd3: begin
                    // 次のj
                    if (j + 1 < num_points) begin
                        j <= j + 1'b1;
                        state <= 4'd1;
                    end else begin
                        state <= 4'd4;  // iを進める
                    end
                end
                4'd4: begin
                    // 次のi、jをリセッ
                    if (i + 2 < num_points) begin
                        i <= i + 1'b1;
                        j <= i + 2'b10;  // j = i + 2 (上三角行列)
                        state <= 4'd1;
                    end else begin
                        state <= 4'd5;
                    end
                end
                4'd5: begin
                    done <= 1'b1;
                    state <= 4'd0;
                end
                default: state <= 4'd0;
            endcase
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Camera 3D Pipeline - Top Level
// カメラ入力 -> 3D復元 -> 空間関係分析 の統合パイプライン
// ----------------------------------------------------------------------------
module camera_3d_pipeline #(
    parameter int MAX_POINTS = 8
)(
    input  logic        clk,
    input  logic        rst_n,

    // 制御
    input  logic        enable,
    input  logic        start_reconstruction,
    input  logic        start_analysis,
    input  logic [3:0]  num_points,

    // カメラ入力 (複数ポイント)
    input  logic [9:0]  pixel_u [0:MAX_POINTS-1],
    input  logic [9:0]  pixel_v [0:MAX_POINTS-1],
    input  logic [31:0] depth_z [0:MAX_POINTS-1],  // Q16.16

    // 3D座標出力
    output logic [31:0] world_x [0:MAX_POINTS-1],   // Q16.16
    output logic [31:0] world_y [0:MAX_POINTS-1],   // Q16.16
    output logic [31:0] world_z [0:MAX_POINTS-1],   // Q16.16
    output logic        recon_done,

    // 距離行列・近傍関係
    output logic [31:0] dist_matrix [0:MAX_POINTS-1][0:MAX_POINTS-1],
    output logic        proximity_mask [0:MAX_POINTS-1][0:MAX_POINTS-1],
    output logic        analysis_done,

    // デバッグ
    output logic [31:0] dbg_recon_count
);

    // 3D復元モジュールの生成 (各ポイント用)
    logic [MAX_POINTS-1:0] recon_valid;
    logic [3:0] recon_idx;
    logic       recon_busy;

    genvar g;
    generate
        for (g = 0; g < MAX_POINTS; g++) begin : gen_reconstructor
            camera_3d_reconstructor u_recon (
                .clk      (clk),
                .rst_n    (rst_n),
                .en       (recon_busy && (recon_idx == g)),
                .pixel_u  (pixel_u[g]),
                .pixel_v  (pixel_v[g]),
                .depth_z  (depth_z[g]),
                .world_x  (world_x[g]),
                .world_y  (world_y[g]),
                .world_z  (world_z[g]),
                .valid    (recon_valid[g])
            );
        end
    endgenerate

    // 復元シーケンサ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            recon_busy   <= 1'b0;
            recon_done   <= 1'b0;
            recon_idx    <= 4'd0;
            dbg_recon_count <= 32'd0;
        end else if (enable && start_reconstruction && !recon_busy) begin
            recon_busy <= 1'b1;
            recon_done <= 1'b0;
            recon_idx  <= 4'd0;
        end else if (recon_busy) begin
            if (recon_valid[recon_idx]) begin
                dbg_recon_count <= dbg_recon_count + 1'b1;
                if (recon_idx + 1 < num_points) begin
                    recon_idx <= recon_idx + 1'b1;
                end else begin
                    recon_busy <= 1'b0;
                    recon_done <= 1'b1;
                end
            end
        end else begin
            recon_done <= 1'b0;
        end
    end

    // 空間関係分析モジュール
    spatial_relation_analyzer #(.MAX_POINTS(MAX_POINTS)) u_analyzer (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start_analysis),
        .num_points     (num_points),
        .points_x       (world_x),
        .points_y       (world_y),
        .points_z       (world_z),
        .dist_matrix    (dist_matrix),
        .proximity_mask (proximity_mask),
        .done           (analysis_done)
    );

endmodule

// ----------------------------------------------------------------------------
// Testbench
// ----------------------------------------------------------------------------
`ifdef SIMULATION
module tb_camera_3d_pipeline;
    import fixed_point_pkg::*;

    localparam int MAX_P = 4;
    localparam int CLK_PERIOD = 10; // 100MHz

    logic clk = 0;
    logic rst_n;
    logic enable;
    logic start_recon;
    logic start_analysis;
    logic [3:0] num_points;

    logic [9:0]  pixel_u [0:MAX_P-1];
    logic [9:0]  pixel_v [0:MAX_P-1];
    logic [31:0] depth_z [0:MAX_P-1];

    logic [31:0] world_x [0:MAX_P-1];
    logic [31:0] world_y [0:MAX_P-1];
    logic [31:0] world_z [0:MAX_P-1];
    logic        recon_done;

    logic [31:0] dist_matrix [0:MAX_P-1][0:MAX_P-1];
    logic        proximity_mask [0:MAX_P-1][0:MAX_P-1];
    logic        analysis_done;
    logic [31:0] dbg_recon_count;

    always #(CLK_PERIOD/2) clk = ~clk;

    camera_3d_pipeline #(.MAX_POINTS(MAX_P)) dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .enable          (enable),
        .start_reconstruction (start_recon),
        .start_analysis  (start_analysis),
        .num_points      (num_points),
        .pixel_u         (pixel_u),
        .pixel_v         (pixel_v),
        .depth_z         (depth_z),
        .world_x         (world_x),
        .world_y         (world_y),
        .world_z         (world_z),
        .recon_done      (recon_done),
        .dist_matrix     (dist_matrix),
        .proximity_mask  (proximity_mask),
        .analysis_done   (analysis_done),
        .dbg_recon_count (dbg_recon_count)
    );

    // Q16.16 表示用関数
    function automatic real q16_to_real(input [31:0] qval);
        q16_to_real = $signed(qval) / 65536.0;
    endfunction

    initial begin
        $display("============================================================");
        $display(" Camera 3D Spatial Reconstruction Pipeline Testbench");
        $display("============================================================");

        // 初期化
        rst_n = 0;
        enable = 0;
        start_recon = 0;
        start_analysis = 0;
        num_points = 4;

        // テストポイント設定:
        // Point 0: u=320, v=240, Z=2.0m  -> 中心: X=0, Y=0, Z=2.0
        // Point 1: u=400, v=240, Z=2.0m  -> X=(400-320)*2/600=0.267
        // Point 2: u=320, v=300, Z=2.0m  -> Y=(300-240)*2/600=0.200
        // Point 3: u=400, v=300, Z=3.0m  -> X=(400-320)*3/600=0.400, Y=(300-240)*3/600=0.300

        pixel_u[0] = 10'd320;  pixel_v[0] = 10'd240;
        pixel_u[1] = 10'd400;  pixel_v[1] = 10'd240;
        pixel_u[2] = 10'd320;  pixel_v[2] = 10'd300;
        pixel_u[3] = 10'd400;  pixel_v[3] = 10'd300;

        depth_z[0] = 32'd131072;  // 2.0 * 65536
        depth_z[1] = 32'd131072;  // 2.0 * 65536
        depth_z[2] = 32'd131072;  // 2.0 * 65536
        depth_z[3] = 32'd196608;  // 3.0 * 65536

        #(CLK_PERIOD*5);
        rst_n = 1;
        #(CLK_PERIOD*2);
        enable = 1;

        // --- 3D復元テト ---
        $display("\n--- Starting 3D Reconstruction ---");
        start_recon = 1;
        #(CLK_PERIOD);
        start_recon = 0;

        wait(recon_done);
        #(CLK_PERIOD*3);

        $display("3D Coordinates (Q16.16 -> real value):");
        for (int p = 0; p < num_points; p++) begin
            $display("  Point %0d: X=%0.4f, Y=%0.4f, Z=%0.4f",
                     p, q16_to_real(world_x[p]), q16_to_real(world_y[p]), q16_to_real(world_z[p]));
        end

        // --- 空間関係分析テスト ---
        $display("\n--- Starting Spatial Analysis ---");
        start_analysis = 1;
        #(CLK_PERIOD);
        start_analysis = 0;

        wait(analysis_done);
        #(CLK_PERIOD*3);

        $display("Distance Matrix (m):");
        for (int i = 0; i < num_points; i++) begin
            for (int j = 0; j < num_points; j++) begin
                $write(" %0.4f", q16_to_real(dist_matrix[i][j]));
            end
            $display("");
        end

        $display("\nProximity Mask (threshold=0.1m):");
        for (int i = 0; i < num_points; i++) begin
            for (int j = 0; j < num_points; j++) begin
                $write(" %b", proximity_mask[i][j]);
            end
            $display("");
        end

        // --- 期待値との比較 ---
        $display("\n--- Expected vs Actual (Point 1 X) ---");
        $display("  Expected X for Point 1: 0.2667 m");
        $display("  Actual   X for Point 1: %0.4f m", q16_to_real(world_x[1]));

        $display("\n============================================================");
        $display(" Simulation Finished");
        $display("============================================================");
        $finish;
    end
endmodule
`endif
