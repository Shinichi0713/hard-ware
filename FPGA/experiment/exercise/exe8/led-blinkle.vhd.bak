library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blinky is
    Port (
        clk : in  std_logic;    -- クロック入力
        led : out std_logic     -- 出力ピン (LED などに接続)
    );
end blinky;

architecture Behavioral of blinky is
    signal counter : integer := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = 50000000 then
                led <= not led;  -- 出力トグル
                counter <= 0;
            end if;
        end if;
    end process;
end Behavioral;
