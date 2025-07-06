--- library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
--- entity
entity led_chaser is
	Port(
		clk	: in std_logic;
		reset	: in std_logic;
		leds	: out std_logic_vector(5 downto 0)
		);
end led_chaser;
 
--- architecture
architecture Behavioral of led_chaser is
	signal cnt	:unsigned(25 downto 0) := (others => '0'); -- 26bitカウンタ(約1秒@50MHz)
	signal led_idx	:unsigned(2 downto 0) := (others => '0');  -- LEDインデックス(0～5)
begin
	process(clk, reset)
	begin
		if reset = '1' then
			cnt <= (others => '0');
			led_idx <= (others => '0');
		elsif rising_edge(clk) then
			if cnt = 49999999 then  -- 50,000,000クロック=1秒
				cnt <= (others => '0');
				if led_idx = 5 then
				  led_idx <= (others => '0');
				else
				  led_idx <= led_idx + 1;
				end if;
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	leds <= std_logic_vector(shift_left(to_unsigned(1, 6), to_integer(led_idx)));
end Behavioral;