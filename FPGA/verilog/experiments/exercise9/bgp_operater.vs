module bgp_ibgp_ebgp_parser (
    input  logic        clk,
    input  logic        rst_n,
    
    // Configuration Inputs
    input  logic [31:0] local_as,        // 自ルータのAS番号
    input  logic [31:0] peer_as,         // 接続ピアのAS番号
    
    // AXI Stream Input (BGP UPDATE Message Payload)
    input  logic [31:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    input  logic        s_axis_tlast,
    output logic        s_axis_tready,
    
    // Parsed & Classified Output Interface
    output logic        is_ibgp,          // 1: iBGP (peer_as == local_as), 0: eBGP
    output logic [31:0] extracted_local_pref, // iBGPで重要となるLocal Preference
    output logic [ 7:0] as_path_length,   // AS_PATHのセグメント長
    output logic        route_valid       // 属性解析完了パルス
);

    // ピア種別の判定 (iBGP vs eBGP)
    // peer_asが自ASと同一であればiBGP、異なればeBGPと判定
    assign is_ibgp = (peer_as == local_as);

    // FSM States
    typedef enum logic [2:0] {
        IDLE            = 3'b000,
        WITHDRAWN_LEN   = 3'b001,
        ATTR_LEN        = 3'b010,
        PARSE_ATTRS     = 3'b011,
        NLRI_PROCESSING = 3'b100
    } state_t;

    state_t state;

    logic [15:0] total_path_attr_len;
    logic [15:0] attr_bytes_processed;

    assign s_axis_tready = (state != NLRI_PROCESSING) || s_axis_tlast;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state                 <= IDLE;
            total_path_attr_len   <= 0;
            attr_bytes_processed  <= 0;
            extracted_local_pref  <= 32'd100; // Default Local Pref
            as_path_length        <= 8'd0;
            route_valid           <= 1'b0;
        end else begin
            route_valid <= 1'b0;

            case (state)
                IDLE: begin
                    if (s_axis_tvalid) begin
                        // UPDATEメッセージの最初は Withdrawn Routes Length (2 bytes)
                        state <= WITHDRAWN_LEN;
                    end
                end

                WITHDRAWN_LEN: begin
                    if (s_axis_tvalid) begin
                        // 次に Total Path Attribute Length (2 bytes)
                        // ここでは簡易的にデータの上位16ビットに長さが入っていると仮定
                        total_path_attr_len <= s_axis_tdata[31:16];
                        attr_bytes_processed <= 0;
                        state <= PARSE_ATTRS;
                    end
                end

                PARSE_ATTRS: begin
                    if (s_axis_tvalid) begin
                        // パス属性（Path Attributes）の解析ループ
                        // 例: 属性フラグ・タイプに応じたLOCAL_PREFやAS_PATHの抽出演算
                        // ※実際にはTLV構造をステートマシンで厳密にデコードします
                        
                        // 簡易的なLOCAL_PREF抽出の模倣 (Typeコードが 0x05 の場合など)
                        if (s_axis_tdata[23:16] == 8'h05) begin // 0x05 = LOCAL_PREF Attribute Type
                            extracted_local_pref <= s_axis_tdata[15:0];
                        end

                        attr_bytes_processed <= attr_bytes_processed + 4;
                        if (attr_bytes_processed >= total_path_attr_len - 4) begin
                            state <= NLRI_PROCESSING;
                            route_valid <= 1'b1; // 属性解析完了
                        end
                    end
                end

                NLRI_PROCESSING: begin
                    if (s_axis_tvalid && s_axis_tlast) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule