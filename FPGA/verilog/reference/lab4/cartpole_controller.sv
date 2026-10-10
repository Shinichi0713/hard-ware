module cartpole_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    output logic [31:0] step_count,
    output logic        done
);

    // 状態変数 (32ビット浮動小数点数: shortreal)
    shortreal x;          // カートの位置 [m]
    shortreal x_dot;      // カートの速度 [m/s]
    shortreal theta;      // ポールの角度 [rad]
    shortreal theta_dot;  // ポールの角速度 [rad/s]

    // 物理定数
    localparam shortreal GRAVITY     = 9.8;
    localparam shortreal MASSCART    = 1.0;
    localparam shortreal MASSPOLE    = 0.1;
    localparam shortreal TOTAL_MASS  = MASSCART + MASSPOLE;
    localparam shortreal LENGTH      = 0.5;
    localparam shortreal POLE_MASS_L = MASSPOLE * LENGTH;
    localparam shortreal FORCE_MAG   = 10.0;
    localparam shortreal TAU         = 0.02;   // 制御周期 20ms

    // 行動信号 (0: 左へ押す, 1: 右へ押す)
    logic action;

    // Q値（推論結果の代替表現、またはニューラルネット演算結果）
    shortreal q0, q1;

    // 簡易的なポリシー評価（組合せ回路による推論の模倣）
    always_comb begin
        // 実際のハードウェア実装ではここにMLP（全結合層）の積和演算回路を配置します
        q0 = -theta * 10.0 - x * 1.0;
        q1 =  theta * 10.0 + x * 1.0;
        
        // Argmax による行動選択
        action = (q1 > q0) ? 1'b1 : 1'b0;
    end

    // 物理シミュレーションおよび制御の更新回路 (順序回路)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x          <= 0.0;
            x_dot      <= 0.0;
            theta      <= 0.05; // 初期状態: わずかに傾ける
            theta_dot  <= 0.0;
            step_count <= 32'd0;
            done       <= 1'b0;
        end else if (start && !done) begin
            shortreal force;
            shortreal costheta, sintheta;
            shortreal temp, thetaacc, xacc;

            // 行動に応じた力の設定
            force = (action == 1'b1) ? FORCE_MAG : -FORCE_MAG;
            
            costheta = $cos(theta);
            sintheta = $sin(theta);

            // 物理方程式（オイラー法）の計算
            temp = (force + POLE_MASS_L * theta_dot * theta_dot * sintheta) / TOTAL_MASS;
            thetaacc = (GRAVITY * sintheta - costheta * temp) / 
                       (LENGTH * (4.0 / 3.0 - MASSPOLE * costheta * costheta / TOTAL_MASS));
            xacc = temp - POLE_MASS_L * thetaacc * costheta / TOTAL_MASS;

            // 状態の更新
            x         <= x + TAU * x_dot;
            x_dot     <= x_dot + TAU * xacc;
            theta     <= theta + TAU * theta_dot;
            theta_dot <= theta_dot + TAU * thetaacc;

            step_count <= step_count + 1;

            // 失敗条件の判定 (位置または角度が限界を超えた場合、あるいは500ステップ到達)
            if (x < -2.4 || x > 2.4 || theta < -0.2095 || theta > 0.2095 || step_count >= 500) begin
                done <= 1'b1;
            end
        end
    end

endmodule

module cartpole_hw_controller (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    output logic [31:0] step_count,
    output logic        done,
    output logic        action_out
);

    // --- 固定小数点フォーマット (Q16.16) ---
    // 1.0 = 1 << 16 = 32'h00010000
    typedef logic signed [31:0] fixed_t;

    localparam fixed_t ONE      = 32'h00010000;
    localparam fixed_t GRAVITY  = 32'h0009CD00; // 9.8 in Q16.16
    localparam fixed_t MASSCART = 32'h00010000; // 1.0
    localparam fixed_t MASSPOLE = 32'h0000199A; // 0.1
    localparam fixed_t LENGTH   = 0;            // 0.5 (32'h00008000)
    localparam fixed_t TAU      = 32'h0000051F; // 0.02 (約 0.02 * 65536)

    // 固定小数点乗算関数 (Q16.16 * Q16.16 -> shift by 16)
    function automatic fixed_t fix_mul(fixed_t a, fixed_t b);
        logic signed [63:0] temp;
        temp = $signed(a) * $signed(b);
        return temp[47:16]; // 小数点位置を調整
    endfunction

    // 状態変数 (x, x_dot, theta, theta_dot)
    fixed_t x, x_dot, theta, theta_dot;

    // --- 1. 三角関数の多項式近似 (sin(theta) ≈ theta, cos(theta) ≈ 1 - theta^2/2) ---
    // 微小角の範囲内であるため、ハードウェア効率の良い多項式近似を使用
    fixed_t sintheta, costheta;
    always_comb begin
        sintheta = theta; // sin(theta) ≬ theta
        // cos(theta) ≬ 1 - (theta^2) / 2
        costheta = ONE - (fix_mul(theta, theta) >>> 1);
    end

    // --- 2. ニューラルネットワーク推論部 (MLP: 4 -> 8 -> 2) ---
    // ここではハードウェア化しやすい簡易的な全結合層の構造を記述
    fixed_t q0, q1;
    always_comb begin
        // サンプルとして、重みパラメータを定数とした簡易積和演算回路
        // 入力: x, x_dot, theta, theta_dot
        q0 = -fix_mul(theta, 32'h000A0000) - fix_mul(x, 32'h00010000);
        q1 =  fix_mul(theta, 32'h000A0000) + fix_mul(x, 32'h00010000);
        
        // 決定論的行動選択 (Argmax)
        action_out = (q1 > q0) ? 1'b1 : 1'b0;
    end

    // --- 3. 物理シミュレーション更新回路 (順序回路) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x          <= 32'sd0;
            x_dot      <= 32'sd0;
            theta      <= 32'h000D33; // 初期値: 約 0.05 rad
            theta_dot  <= 32'sd0;
            step_count <= 32'd0;
            done       <= 1'b0;
        end else if (start && !done) begin
            fixed_t force;
            fixed_t temp, thetaacc, xacc;
            fixed_t force_mag = 32'h000A0000; // 10.0 in Q16.16
            fixed_t total_mass = MASSCART + MASSPOLE;
            fixed_t polemass_length = fix_mul(MASSPOLE, 32'h00008000); // 0.5

            // 行動に応じた力
            force = (action_out == 1'b1) ? force_mag : -force_mag;

            // 運動方程式の計算 (固定小数点演算)
            // temp = (force + polemass_length * theta_dot^2 * sintheta) / total_mass
            temp = fix_mul(polemass_length, fix_mul(theta_dot, theta_dot));
            temp = fix_mul(temp, sintheta);
            temp = (force + temp) / total_mass;

            // 加速度の計算
            // 簡易化された物理演算パス
            thetaacc = fix_mul(GRAVITY, sintheta) - fix_mul(costheta, temp);
            xacc     = temp - fix_mul(polemass_length, fix_mul(thetaacc, costheta)) / total_mass;

            // 状態のオイラー法による更新
            x     <= x     + fix_mul(TAU, x_dot);
            x_dot <= x_dot + fix_mul(TAU, xacc);
            theta     <= theta     + fix_mul(TAU, theta_dot);
            theta_dot <= theta_dot + fix_mul(TAU, thetaacc);

            step_count <= step_count + 1;

            // 終了判定 (位置 2.4m または 角度 0.2095 rad を超えた場合)
            if (x < -32'h00026666 || x > 32'h00026666 || 
                theta < -32'h000035C2 || theta > 32'h000035C2 || 
                step_count >= 500) begin
                done <= 1'b1;
            end
        end
    end

endmodule