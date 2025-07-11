--- library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
 
entity led_chaser is
    Port(
        btn : in std_logic;  -- ボタン入力
        reset : in std_logic;
        leds : out std_logic_vector(5 downto 0)
    );
end led_chaser;
 
architecture Behavioral of led_chaser is
    signal led_idx : unsigned(2 downto 0) := (others => '0');
    signal btn_prev : std_logic := '0';
begin
    process(btn, reset)
    begin
        if reset = '1' then
            led_idx <= (others => '0');
            btn_prev <= '0';
        elsif rising_edge(btn) and btn_prev = '0' then  -- ボタンの立ち上がり
            if led_idx = 5 then
                led_idx <= (others => '0');
            else
                led_idx <= led_idx + 1;
            end if;
        end if;
        btn_prev <= btn;
    end process;
    leds <= std_logic_vector(shift_left(to_unsigned(1, 6), to_integer(led_idx)));
end Behavioral;