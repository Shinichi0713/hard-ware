library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_counter is
end tb_counter;

architecture sim of tb_counter is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal en  : std_logic := '0';
    signal q   : std_logic_vector(3 downto 0);
begin

    uut: entity work.counter
        port map (
            clk => clk,
            rst => rst,
            en  => en,
            q   => q
        );

    -- クロック生成 (10ns周期)
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- リセット
        wait for 20 ns;
        rst <= '0';
        en  <= '1';

        -- カウント
        wait for 200 ns;

        -- 停止
        en <= '0';
        wait for 50 ns;

        -- 再開
        en <= '1';
        wait for 100 ns;

        wait;
    end process;

end sim;
