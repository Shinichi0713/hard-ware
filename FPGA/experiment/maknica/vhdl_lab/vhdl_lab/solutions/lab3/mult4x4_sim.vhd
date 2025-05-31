library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity mult4x4_sim is
end mult4x4_sim;

architecture mult4x4 of mult4x4_sim is
component mult4x4
port (	a, b : in std_logic_vector(3 downto 0);
		product  :  out std_logic_vector(7 downto 0));
end component;

signal mult_a, mult_b   	: std_logic_vector(3 downto 0):=(others => '0');
signal mult_product   	: std_logic_vector(7 downto 0):=(others => '0');
signal cnta	:	std_logic_vector(3 downto 0):=(others => '0');
signal cntb	:	std_logic_vector(3 downto 0):=(others => '0');

constant period_a : time := 50 ns;
constant period_b : time := 100 ns;

begin
 u1:mult4x4
 port map(   a => mult_a,
             b => mult_b,
             product => mult_product );

process
   begin
	   cnta <= "0001";
	loop
		wait for period_a;
		cnta <= cnta + '1';
	end loop;
end process;

process
   begin
      cntb <= "0101";
	loop	
		wait for period_b;
		cntb <= cntb + '1';
	end loop;
end process;
	
	mult_a <= cnta;
	mult_b <= cntb;	
	
end mult4x4;				