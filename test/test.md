VHDL（VHSIC Hardware Description Language）における**エンティティ（entity）**の宣言は、設計したい回路（モジュール）の**外部インターフェース**（入出力ポートなど）を定義する部分です。  
エンティティは「この回路はどんな名前で、どんな入出力端子を持っているか」を記述します。

---

## 基本構文

```vhdl
entity エンティティ名 is
    port (
        ポート名1 : モード1 型1;
        ポート名2 : モード2 型2;
        -- 必要なだけポートを宣言
    );
end エンティティ名;
```

### 主な要素
- **エンティティ名**：回路モジュールの名前
- **port**：入出力ポートのリストを定義
- **ポート名**：各ピン（端子）の名前
- **モード**：`in`（入力）, `out`（出力）, `inout`（双方向）など
- **型**：`bit`, `std_logic`, `std_logic_vector` など

---

## 例：2入力ANDゲート

```vhdl
entity and_gate is
    port (
        a : in std_logic;
        b : in std_logic;
        y : out std_logic
    );
end and_gate;
```
- 入力：`a`, `b`
- 出力：`y`

---

## 例：8ビット加算器

```vhdl
entity adder8 is
    port (
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        sum : out std_logic_vector(7 downto 0)
    );
end adder8;
```
- 8ビット入力：`a`, `b`
- 8ビット出力：`sum`

---

## ポイント
- **エンティティ宣言は「回路の外から見た窓」**です。内部の動作（アーキテクチャ）はこの後ろに記述します。
- **モード**は必ず指定します。
- **型**は設計内容に応じて選びます（`std_logic`や`std_logic_vector`がよく使われます）。

---

## まとめ
- エンティティ宣言は、VHDLで回路の「名前」と「入出力」を定義する部分です。
- 基本構文を守り、必要なポートを適切に宣言しましょう。

以上です。