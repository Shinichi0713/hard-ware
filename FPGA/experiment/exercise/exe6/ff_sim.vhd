library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ff_sim is
end ff_sim;

architecture ff of ff_sim is
component ff
port (clk, aclr, clken : in std_logic;
	  d : in std_logic;
	  q : out std_logic);
end component;

signal clk, clken, clr : std_logic;
signal d : std_logic:= '1';
signal q : std_logic:= '0';

constant period : time := 10 ns;

begin
 u1:ff
 port map( clk => clk,
           aclr => clr,
		     clken => clken,
		     d => d,
		     q => q);

process
 begin
 	clk <='0';
 	wait for period/2;
 	clk <='1';
 	wait for period/2;
end process;

process
 begin
 	clr <='1';
 	wait for period/2*2;
 	clr <='0';
 	wait for period/2*10;
end process;

process
begin
   clken <= '0';
   wait for 500 ns;
   clken <= '1';
   wait for 500 ns;
end process;

process
begin
   loop
   wait for period;
   d <= d ;	
   end loop;
end process;

end ff;
