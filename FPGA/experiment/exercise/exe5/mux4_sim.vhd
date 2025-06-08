library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity mux4_sim is
end mux4_sim;

architecture mux4 of mux4_sim is
component mux4
port (	a, b	: in std_logic_vector(3 downto 0);
       sel	: in std_logic;
	y	: out std_logic_vector(3 downto 0));
end component;

signal sel	: std_logic;		
signal a	: std_logic_vector(3 downto 0) := "1001";
signal b	: std_logic_vector(3 downto 0) := "0111";
signal y	: std_logic_vector(3 downto 0);

constant period : time := 50 ns;
begin
 u1:mux4
 port map(	a => a,
		b => b,
		sel => sel,
		y => y );
 
process
 begin
 	sel <='0';wait for period/2;
 	sel <='1';wait for period/2;
end process;
		
end mux4;				