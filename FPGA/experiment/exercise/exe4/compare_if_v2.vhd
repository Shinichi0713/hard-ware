
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;

entity compare_if is
	port(
	da: in std_logic_vector(7 downto 0);
	db: in std_logic_vector(7 downto 0);
	equ: out std_logic;
	agb: out std_logic;
	alb: out std_logic);
end entity;

architecture Behavioral of compare_if is
begin
	process(da, db)
	begin
		if da > db then
			equ <= '0';
			agb <= '1';
			alb <= '0';
		elsif db < db then		
			equ <= '0';
			agb <= '0';
			alb <= '1';
		else
			equ <= '1';
			agb <= '0';
			alb <= '0';
		end if;
	end process;
end Behavioral;

