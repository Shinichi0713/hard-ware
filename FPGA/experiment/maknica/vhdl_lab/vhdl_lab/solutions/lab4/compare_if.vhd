library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity compare_if is
port (da, db		:	in	std_logic_vector (7 downto 0);
	  equ, agb, alb	:	out	std_logic	);
end compare_if;

architecture logic of compare_if is
begin
	process (da, db)
	begin
	
		if (da = db) then 
			equ <= '1';
		else
			equ <= '0';
		end if;

		if (da > db) then 
			agb <= '1';
		else
			agb <= '0';
		end if;

		if (da < db) then 
			alb <= '1';
		else
			alb <= '0';
		end if;
		
	end process;		
end logic;