module multi_sensor_search_env #(
    parameter int GRID_SIZE   = 15,
    parameter int NUM_AGENTS  = 3,
    parameter int SENSOR_RANGE = 1,
    parameter int MAX_STEPS   = 100
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   start,                     // エピソード開始・リセット
    input  logic [2:0]             actions [0:NUM_AGENTS-1],  // 各エージェントの行動 (0:待機, 1:上, 2:下, 3:左, 4:右)
    
    output logic [3:0]             agent_x [0:NUM_AGENTS-1],  // 各エージェントのX座標 (0〜14)
    output logic [3:0]             agent_y [0:NUM_AGENTS-1],  // 各エージェントのY座標 (0〜14)
    output logic [7:0]             coverage_pct,              // カバレッジ率 (0〜100%)
    output logic signed [15:0]     rewards [0:NUM_AGENTS-1],  // 各エージェントの報酬
    output logic                   done                       // エピソード終了フラグ
);

    // 15x15 マップレジスタ (0:未探索, 1:探索済み)
    logic [GRID_SIZE-1:0][GRID_SIZE-1:0] explored_map;
    logic [7:0] step_counter;

    // 座標用内部レジスタ
    logic [3:0] x_next [0:NUM_AGENTS-1];
    logic [3:0] y_next [0:NUM_AGENTS-1];

    // 探索済みセルの総数計算用
    logic [7:0] total_explored_cells;

    always_comb begin
        total_explored_cells = 0;
        for (int r = 0; r < GRID_SIZE; r++) begin
            for (int c = 0; c < GRID_SIZE; c++) begin
                if (explored_map[r][c]) total_explored_cells = total_explored_cells + 1;
            end
        end
        // カバレッジ率 (total_explored_cells * 100 / 225) の簡易計算
        coverage_pct = (total_explored_cells * 100) / (GRID_SIZE * GRID_SIZE);
    end

    // メイン制御 FSM とステップ更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_AGENTS; i++) begin
                agent_x[i] <= 4'd0;
                agent_y[i] <= 4'd0;
                rewards[i] <= 16'sd0;
            end
            explored_map <= '0;
            step_counter <= 8'd0;
            done <= 1'b1;
        end else if (start) begin
            // 初期化 (ハードウェア乱数または固定初期位置)
            agent_x[0] <= 4'd3;  agent_y[0] <= 4'd3;
            agent_x[1] <= 4'd7;  agent_y[1] <= 4'd7;
            agent_x[2] <= 4'd11; agent_y[2] <= 4'd11;
            
            explored_map <= '0;
            step_counter <= 8'd0;
            done <= 1'b0;
            for (int i = 0; i < NUM_AGENTS; i++) begin
                rewards[i] <= 16'sd0;
            end
        end else if (!done) begin
            step_counter <= step_counter + 1;

            // 1. 移動処理とクリッピング (0 〜 GRID_SIZE-1)
            for (int i = 0; i < NUM_AGENTS; i++) begin
                logic signed [4:0] cx, cy;
                cx = {1'b0, agent_x[i]};
                cy = {1'b0, agent_y[i]};

                case (actions[i])
                    3'd1: cy = cy + 1; // 上
                    3'd2: cy = cy - 1; // 下
                    3'd3: cx = cx - 1; // 左
                    3'd4: cx = cx + 1; // 右
                    default: ;         // 待機
                endcase

                // クリップ処理
                if (cx < 0) agent_x[i] <= 0;
                else if (cx >= GRID_SIZE) agent_x[i] <= GRID_SIZE - 1;
                else agent_x[i] <= cx[3:0];

                if (cy < 0) agent_y[i] <= 0;
                else if (cy >= GRID_SIZE) agent_y[i] <= GRID_SIZE - 1;
                else agent_y[i] <= cy[3:0];
            end

            // 2. センサー範囲の探索更新と報酬計算 (簡易モデル)
            // タイムペナルティの付与
            for (int i = 0; i < NUM_AGENTS; i++) begin
                rewards[i] <= -1; // -0.1のスケール
            end

            // センサー範囲（3x3）内の未探索マスを探索済みに更新
            for (int i = 0; i < NUM_AGENTS; i++) begin
                int x_min, x_max, y_min, y_max;
                x_min = (agent_x[i] >= SENSOR_RANGE) ? (agent_x[i] - SENSOR_RANGE) : 0;
                x_max = (agent_x[i] + SENSOR_RANGE < GRID_SIZE) ? (agent_x[i] + SENSOR_RANGE) : GRID_SIZE - 1;
                y_min = (agent_y[i] >= SENSOR_RANGE) ? (agent_y[i] - SENSOR_RANGE) : 0;
                y_max = (agent_y[i] + SENSOR_RANGE < GRID_SIZE) ? (agent_y[i] + SENSOR_RANGE) : GRID_SIZE - 1;

                for (int ry = y_min; ry <= y_max; ry++) begin
                    for (int rx = x_min; rx <= x_max; rx++) begin
                        if (!explored_map[ry][rx]) begin
                            explored_map[ry][rx] <= 1'b1;
                            rewards[i] <= rewards[i] + 10; // 新規発見ボーナス
                        end
                    end
                end
            end

            // 3. 終了判定
            if ((coverage_pct >= 100) || (step_counter >= MAX_STEPS - 1)) begin
                done <= 1'b1;
            end
        end
    end

endmodule


module multi_sensor_search_env #(
    parameter int GRID_SIZE   = 15,
    parameter int NUM_AGENTS  = 3,
    parameter int SENSOR_RANGE = 1,
    parameter int MAX_STEPS   = 100
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   start,                     // エピソード開始・リセット
    input  logic [2:0]             actions [0:NUM_AGENTS-1],  // 各エージェントの行動 (0:待機, 1:上, 2:下, 3:左, 4:右)
    
    output logic [3:0]             agent_x [0:NUM_AGENTS-1],  // 各エージェントのX座標 (0〜14)
    output logic [3:0]             agent_y [0:NUM_AGENTS-1],  // 各エージェントのY座標 (0〜14)
    output logic [7:0]             coverage_pct,              // カバレッジ率 (0〜100%)
    output logic signed [15:0]     rewards [0:NUM_AGENTS-1],  // 各エージェントの報酬
    output logic                   done                       // エピソード終了フラグ
);

    // 15x15 マップレジスタ (0:未探索, 1:探索済み)
    logic [GRID_SIZE-1:0][GRID_SIZE-1:0] explored_map;
    logic [7:0] step_counter;

    // 座標用内部レジスタ
    logic [3:0] x_next [0:NUM_AGENTS-1];
    logic [3:0] y_next [0:NUM_AGENTS-1];

    // 探索済みセルの総数計算用
    logic [7:0] total_explored_cells;

    always_comb begin
        total_explored_cells = 0;
        for (int r = 0; r < GRID_SIZE; r++) begin
            for (int c = 0; c < GRID_SIZE; c++) begin
                if (explored_map[r][c]) total_explored_cells = total_explored_cells + 1;
            end
        end
        // カバレッジ率 (total_explored_cells * 100 / 225) の簡易計算
        coverage_pct = (total_explored_cells * 100) / (GRID_SIZE * GRID_SIZE);
    end

    // メイン制御 FSM とステップ更新
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < NUM_AGENTS; i++) begin
                agent_x[i] <= 4'd0;
                agent_y[i] <= 4'd0;
                rewards[i] <= 16'sd0;
            end
            explored_map <= '0;
            step_counter <= 8'd0;
            done <= 1'b1;
        end else if (start) begin
            // 初期化 (ハードウェア乱数または固定初期位置)
            agent_x[0] <= 4'd3;  agent_y[0] <= 4'd3;
            agent_x[1] <= 4'd7;  agent_y[1] <= 4'd7;
            agent_x[2] <= 4'd11; agent_y[2] <= 4'd11;
            
            explored_map <= '0;
            step_counter <= 8'd0;
            done <= 1'b0;
            for (int i = 0; i < NUM_AGENTS; i++) begin
                rewards[i] <= 16'sd0;
            end
        end else if (!done) begin
            step_counter <= step_counter + 1;

            // 1. 移動処理とクリッピング (0 〜 GRID_SIZE-1)
            for (int i = 0; i < NUM_AGENTS; i++) begin
                logic signed [4:0] cx, cy;
                cx = {1'b0, agent_x[i]};
                cy = {1'b0, agent_y[i]};

                case (actions[i])
                    3'd1: cy = cy + 1; // 上
                    3'd2: cy = cy - 1; // 下
                    3'd3: cx = cx - 1; // 左
                    3'd4: cx = cx + 1; // 右
                    default: ;         // 待機
                endcase

                // クリップ処理
                if (cx < 0) agent_x[i] <= 0;
                else if (cx >= GRID_SIZE) agent_x[i] <= GRID_SIZE - 1;
                else agent_x[i] <= cx[3:0];

                if (cy < 0) agent_y[i] <= 0;
                else if (cy >= GRID_SIZE) agent_y[i] <= GRID_SIZE - 1;
                else agent_y[i] <= cy[3:0];
            end

            // 2. センサー範囲の探索更新と報酬計算 (簡易モデル)
            // タイムペナルティの付与
            for (int i = 0; i < NUM_AGENTS; i++) begin
                rewards[i] <= -1; // -0.1のスケール
            end

            // センサー範囲（3x3）内の未探索マスを探索済みに更新
            for (int i = 0; i < NUM_AGENTS; i++) begin
                int x_min, x_max, y_min, y_max;
                x_min = (agent_x[i] >= SENSOR_RANGE) ? (agent_x[i] - SENSOR_RANGE) : 0;
                x_max = (agent_x[i] + SENSOR_RANGE < GRID_SIZE) ? (agent_x[i] + SENSOR_RANGE) : GRID_SIZE - 1;
                y_min = (agent_y[i] >= SENSOR_RANGE) ? (agent_y[i] - SENSOR_RANGE) : 0;
                y_max = (agent_y[i] + SENSOR_RANGE < GRID_SIZE) ? (agent_y[i] + SENSOR_RANGE) : GRID_SIZE - 1;

                for (int ry = y_min; ry <= y_max; ry++) begin
                    for (int rx = x_min; rx <= x_max; rx++) begin
                        if (!explored_map[ry][rx]) begin
                            explored_map[ry][rx] <= 1'b1;
                            rewards[i] <= rewards[i] + 10; // 新規発見ボーナス
                        end
                    end
                end
            end

            // 3. 終了判定
            if ((coverage_pct >= 100) || (step_counter >= MAX_STEPS - 1)) begin
                done <= 1'b1;
            end
        end
    end

endmodule