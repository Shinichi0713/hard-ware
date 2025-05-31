library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
port	(	a, b	:	in	std_logic_vector (3 downto 0);
			sel		:	in	std_logic;
			y		:	out	std_logic_vector (3 downto 0)	);
end mux4;

architecture logic of mux4 is
begin
	process (a, b, sel)
	begin
		case (sel) is
			when '0' => 
				y <= a;
			when others => 
				y <= b;
		end case;
	end process;
end logic;					