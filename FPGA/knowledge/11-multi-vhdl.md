FPGAで2つのentity（エンティティ、モジュール）を動作させたい場合、**上位のトップモジュール（トップエンティティ）を作成し、その中で2つのentityをインスタンス化して接続する**のが一般的です。

---

## 基本的な手順

### 1. それぞれのentity（モジュール）を作る

例：  
```vhdl
-- entity1
entity entity1 is
    Port ( clk : in std_logic;
           rst : in std_logic;
           a   : in std_logic;
           y   : out std_logic);
end entity1;

architecture Behavioral of entity1 is
begin
    -- 振る舞いを記述
end Behavioral;

-- entity2
entity entity2 is
    Port ( clk : in std_logic;
           rst : in std_logic;
           b   : in std_logic;
           z   : out std_logic);
end entity2;

architecture Behavioral of entity2 is
begin
    -- 振る舞いを記述
end Behavioral;
```

---

### 2. トップモジュール（トップエンティティ）でインスタンス化

```vhdl
entity top is
    Port ( clk : in std_logic;
           rst : in std_logic;
           a   : in std_logic;
           b   : in std_logic;
           y   : out std_logic;
           z   : out std_logic);
end top;

architecture Structural of top is

    -- 必要なら内部信号を宣言

begin

    u1: entity work.entity1
        port map (
            clk => clk,
            rst => rst,
            a   => a,
            y   => y
        );

    u2: entity work.entity2
        port map (
            clk => clk,
            rst => rst,
            b   => b,
            z   => z
        );

end Structural;
```

---

## ポイント

- **トップエンティティで複数のentityをインスタンス化して使う**のが基本です。
- entity間で信号をやりとりしたい場合は、トップで内部信号を宣言して接続します。
- Verilogの場合も同様で、`module`をトップでインスタンス化します。

---

## まとめ

1. 各entity（モジュール）を作成
2. トップモジュールでインスタンス化し、必要な信号を接続

この構造で、FPGA上で複数のentityを同時に動作させることができます。

ご不明な点があれば、具体的なコード例や接続方法もご案内できますので、お気軽にどうぞ。

# 内部信号を活用
VHDLを例に「トップモジュールで内部信号を宣言し、2つのentityを接続する」例を示します。

### 例：内部信号を使って2つのentityを接続
__前提__

entity1の出力yをentity2の入力bへ接続したいとします。

entity1
```vhdl
entity entity1 is
    Port ( clk : in std_logic;
           rst : in std_logic;
           a   : in std_logic;
           y   : out std_logic);
end entity1;

architecture Behavioral of entity1 is
begin
    -- 例: y <= a;
    y <= a;
end Behavioral;
```

entity2
```vhdl
entity entity2 is
    Port ( clk : in std_logic;
           rst : in std_logic;
           b   : in std_logic;
           z   : out std_logic);
end entity2;

architecture Behavioral of entity2 is
begin
    -- 例: z <= b;
    z <= b;
end Behavioral;
```

トップモジュール（内部信号の宣言と接続）
```vhdl
entity top is
    Port ( clk : in std_logic;
           rst : in std_logic;
           a   : in std_logic;
           z   : out std_logic);
end top;

architecture Structural of top is
    -- 内部信号を宣言
    signal y_sig : std_logic;
begin

    -- entity1のインスタンス
    u1: entity work.entity1
        port map (
            clk => clk,
            rst => rst,
            a   => a,
            y   => y_sig      -- 内部信号へ接続
        );

    -- entity2のインスタンス
    u2: entity work.entity2
        port map (
            clk => clk,
            rst => rst,
            b   => y_sig,     -- 内部信号から入力
            z   => z
        );

end Structural;
```

__ポイント__

architecture ... isのisの後でsignal y_sig : std_logic;のように内部信号を宣言します。
その信号を、各entityのport mapで接続します。
このようにして、entity間のデータの受け渡しができます。


## 以下メモ
2つのエンティティを動作させる場合はトップモジュールを作成して、2つのエンティティをインスタンス化して接続する流れ。



