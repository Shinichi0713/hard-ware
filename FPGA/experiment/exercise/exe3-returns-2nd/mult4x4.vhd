
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4 is
	port ( a : in std_logic_vector (3 downto 0);
	       b : in std_logic_vector (3 downto 0);
	       product : out std_logic_vector (7 downto 0));
end mult4x4;

architecture Behavioral of mult4x4 is
begin
	process(a, b)
	begin
	      product <= std_logic_vector(unsigned(a) * unsigned(b));
	end process;
end Behavioral;
