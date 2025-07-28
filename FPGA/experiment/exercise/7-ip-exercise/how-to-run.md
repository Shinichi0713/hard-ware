ModelSimでこの`sqrt`エンティティのシミュレーションを行い、`radical`に4の値を設定したい場合は、**テストベンチ（testbench）**を作成して、その中で`radical`信号に値を与える方法が一般的です。

---

## 例：テストベンチの書き方

以下は、`radical`に4（8ビットで`"00000100"`）を与えるVHDLテストベンチの例です。

```vhdl
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY sqrt_tb IS
END sqrt_tb;

ARCHITECTURE behavior OF sqrt_tb IS

    -- コンポーネント宣言
    COMPONENT sqrt
        PORT(
            radical    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            q          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            remainder  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    -- テストベンチ用信号
    SIGNAL radical    : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    SIGNAL q          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL remainder  : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN

    -- UUT（被テスト回路）のインスタンス化
    uut: sqrt PORT MAP (
        radical => radical,
        q => q,
        remainder => remainder
    );

    -- radicalに4を設定
    stim_proc: process
    begin
        radical <= "00000100";   -- 4を2進数でセット
        wait for 10 ns;          -- 10ns待って、波形を観察できるように
        wait;                    -- これ以降はシミュレーション停止
    end process;

END behavior;
```

---

## シミュレーション手順（ModelSimの場合）

1. 上記テストベンチ（例：`sqrt_tb.vhd`）を作成
2. ModelSimでプロジェクトに追加し、コンパイル
3. テストベンチ（`sqrt_tb`）をトップレベルでシミュレーション
4. 波形ウィンドウで`q`や`remainder`の出力を確認

---

## ポイント

- **テストベンチ内で`radical`信号に直接値を与える**ことで、任意の入力値でシミュレーションできます。
- `wait for 10 ns;` などで十分な時間を待つと、波形で出力を確認しやすくなります。

---

もし他にも複数の値でテストしたい場合は、`stim_proc`プロセス内で`radical`に異なる値を順次与えていくこともできます。

---

**まとめ：**  
ModelSimで`sqrt`のシミュレーションをする際は、テストベンチを作成し、その中で`radical`に4（`"00000100"`）を代入してください。

以上です。