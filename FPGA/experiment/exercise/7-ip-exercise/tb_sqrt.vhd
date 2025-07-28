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