library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity compare_if_sim is
end compare_if_sim;

architecture compare_if of compare_if_sim is
component compare_if is
port (da, db	:	in	std_logic_vector (7 downto 0);
		equ, agb, alb	:	out	std_logic	);
end component;

signal da, db           : std_logic_vector(7 downto 0):=(others => '0');
signal equ, agb, alb  : std_logic := '0';
signal inveca, invecb: std_logic_vector(7 downto 0):=(others => '0');

constant period : time := 50 ns;

begin
 u1:compare_if
 port map(  da => da,
                db => db,
                equ	 => equ,
                agb => agb,
                alb => alb );

process
   begin
	   inveca <= "00000001";
	loop
		wait for period;
		inveca <= inveca + 1;
	end loop;
end process;

process
   begin
      invecb <= "00001001";
	loop	
		wait for period;
		invecb <= invecb - 1;
	end loop;
end process;
	
	da <= inveca;
	db <= invecb;	
	
end compare_if;				