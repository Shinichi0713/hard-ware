library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_counter is
end entity;

architecture sim of tb_counter is
    -- DUT?Device Under Test????????????
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal counter_out : unsigned(31 downto 0);

    -- ??
    constant CLK_PERIOD : time := 20 ns;  -- 50MHz??
begin

    -- DUT ???????
    uut: entity work.counter
        port map (
            clock       => clk,
            reset       => rst,
            counter_out => counter_out
        );

    -- ??????????
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- ????????
    stim_proc : process
    begin
        -- ????
        rst <= '0';
        wait for 40 ns;

        -- ??????
        rst <= '1';
        wait for 200 ns;

        -- ??????
        rst <= '0';
        wait for 40 ns;
        rst <= '1';
        wait for 200 ns;

        -- ??????????
        wait;
    end process;

end architecture;
