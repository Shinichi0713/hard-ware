library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stepper_driver is
end;

architecture sim of tb_stepper_driver is
    signal clk          : std_logic := '0';
    signal reset_n      : std_logic := '0';
    signal speed_divider: unsigned(31 downto 0) := to_unsigned(25_000, 32);
    signal dir_ctrl     : std_logic := '0';
    signal step_out     : std_logic;
    signal dir_out      : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50MHz
begin
    uut: entity work.stepper_driver
        port map(
            clk          => clk,
            reset_n      => reset_n,
            speed_divider=> speed_divider,
            dir_ctrl     => dir_ctrl,
            step_out     => step_out,
            dir_out      => dir_out
        );

    -- クロック生成
    clk <= not clk after CLK_PERIOD/2;

    -- テストシナリオ
    process
    begin
        -- 初期リセット
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';

        -- 正転で一定速度
        dir_ctrl <= '0';
        wait for 2 ms;

        -- 逆転に切り替え
        dir_ctrl <= '1';
        wait for 2 ms;

        -- スピード変更
        speed_divider <= to_unsigned(5_000, 32); -- 速くする
        wait for 2 ms;

        wait;
    end process;
end;
