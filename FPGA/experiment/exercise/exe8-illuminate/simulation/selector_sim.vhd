library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_selector is
end entity;

architecture sim of tb_selector is
    -- DUT（被試験回路）に接続する信号を宣言
    signal dataa  : unsigned(3 downto 0) := (others => '0');
    signal datab  : unsigned(3 downto 0) := (others => '0');
    signal sel    : std_logic := '0';
    signal result : unsigned(3 downto 0);
begin
    -- DUT のインスタンス化
    uut: entity work.selector
        port map (
            dataa  => dataa,
            datab  => datab,
            sel    => sel,
            result => result
        );

    -- テストシーケンス
    stim_proc : process
    begin
        -- 初期値
        dataa <= "1010";  -- 10
        datab <= "0101";  -- 5
        sel   <= '0';
        wait for 20 ns;

        -- sel=0 の場合、result=datab になるはず
        sel <= '0';
        wait for 20 ns;

        -- sel=1 の場合、result=dataa になるはず
        sel <= '1';
        wait for 20 ns;

        -- 入力を変えて確認
        dataa <= "1111";  -- 15
        datab <= "0000";  -- 0
        sel   <= '1';     -- dataa を選択
        wait for 20 ns;

        sel   <= '0';     -- datab を選択
        wait for 20 ns;

        -- シミュレーション終了
        wait;
    end process;
end architecture;


