library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity adder_sim is
end adder_sim;

architecture adder of adder_sim is
component adder
port (	a, b : in std_logic_vector(15 downto 0);
		sum	  :  out std_logic_vector(15 downto 0));
end component;

signal adder_a, adder_b   	: std_logic_vector(15 downto 0):=(others => '0');
signal sum   	: std_logic_vector(15 downto 0):=(others => '0');
signal inveca	:	std_logic_vector(15 downto 0):=(others => '0');
signal invecb	:	std_logic_vector(15 downto 0):=(others => '0');

constant period_a : time := 50 ns;
constant period_b : time := 100 ns;

begin
 u1:adder
 port map(   a => adder_a,
             b => adder_b,
             sum => sum );

process
   begin
	   inveca <= "0000000000000001";
	loop
		wait for period_a;
		inveca <= inveca + '1';
	end loop;
end process;

process
   begin
      invecb <= "0000000000000101";
	loop	
		wait for period_b;
		invecb <= invecb + '1';
	end loop;
end process;
	
	adder_a <= inveca;
	adder_b <= invecb;	
	
end adder;				