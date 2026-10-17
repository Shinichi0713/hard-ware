module memory_agent_tb;

    // --- 1. Message 構造体 ---
    typedef struct {
        string role;    // "User" または "Assistant"
        string content;
        string timestamp;
    } message_t;

    // --- 2. MemoryManager の状態を表現する変数 ---
    message_t short_term[$];       // 短期記憶（動的キュー）
    int short_term_limit = 4;
    string long_term_map[string];  // 長期記憶（連想配列：キー・バリュー）

    // 短期記憶にメッセージを追加し、上限を超えたら古いものを削除
    function void add_short_term(string role, string content);
        message_t msg;
        msg.role = role;
        msg.content = content;
        msg.timestamp = "2026-10-15T00:00:00";
        
        short_term.push_back(msg);
        if (short_term.size() > short_term_limit) begin
            void'(short_term.pop_front()); // 最も古い履歴を削除
        end
    endfunction

    // 長期記憶に重要な知識や属性を保存
    function void add_long_term(string key, string value);
        long_term_map[key] = value;
    endfunction

    // 長期記憶の検索（キーの存在確認と取得）
    function string search_long_term(string key);
        if (long_term_map.exists(key)) begin
            return long_term_map[key];
        end
        return "";
    endfunction

    // --- 3. MemoryAgent のシミュレーション処理 ---
    function string simulate_llm_processing(string user_input);
        string res;
        string stored_name;

        // ユーザーが名前を教えてくれた場合の処理
        if (user_input == "こんにちは、私の名前は佐藤健一です。") {
            add_long_term("ユーザーの名前", "佐藤健1");
            return "承知いたしました！ あなたの名前を「佐藤健一」として記憶しました。";
        }

        // 長期記憶にアクセスする質問への対応
        if (user_input == "私の名前を知っていますか？") {
            stored_name = search_long_term("ユーザーの名前");
            if (stored_name != "") begin
                return {"はい、覚えていますよ。佐藤健一ですね！"};
            end
            return "まだあなたのお名前を伺っていません。";
        }

        // 通常の応答
        return {"ご入力ありがとうございます。（保持しているコンテキストに基づき処理中...）\n[受け取った入力]: ", user_input};
    endfunction

    // ステップ実行関数
    function string step(string user_input);
        string response;
        
        // 1. ユーザー入力を短期記憶に記録
        add_short_term("User", user_input);

        // 2. エージェントの推論処理
        response = simulate_llm_processing(user_input);

        // 3. エージェントの応答を短期記憶に記録
        add_short_term("Assistant", response);

        return response;
    endfunction

    // --- 4. 実行・動作確認テスト (初期ブロック) ---
    initial begin
        string resp;

        $display("=== ターン 1 ===");
        $display("User: こんにちは、私の名前は佐藤健一です。");
        resp = step("こんにちは、私の名前は佐藤健一です。");
        $display("Agent: %0s\n", resp);

        $display("=== ターン 2 ===");
        $display("User: 今日は良い天気ですね。");
        resp = step("今日は良い天気ですね。");
        $display("Agent: %0s\n", resp);

        $display("=== ターン 3 ===");
        $display("User: 私の名前を知っていますか？");
        resp = step("私の名前を知っていますか？");
        $display("Agent: %0s\n", resp);

        $finish;
    end

endmodule