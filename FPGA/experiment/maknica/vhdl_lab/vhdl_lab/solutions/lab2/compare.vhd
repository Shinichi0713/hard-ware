library ieee;
use ieee.std_logic_1164.all;

entity compare is
port (da, db	:	in	std_logic_vector (7 downto 0);
		equ, agb, alb	:	out	std_logic	);
end compare;

architecture logic of compare is
begin
	equ	<= '1' when (da = db) else '0';
	agb	<= '1' when (da > db) else '0';
	alb	<= '1' when (da < db) else '0';
end logic;