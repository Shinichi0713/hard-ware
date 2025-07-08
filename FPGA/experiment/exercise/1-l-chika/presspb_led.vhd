-- VHDL sample : presspb_led.vhd


library ieee;
use ieee.std_logic_1164.all;


entity presspb_led is
	port (
		PB	 :  in  std_logic;
		LED 	 :  out std_logic
	     );
end;


architecture rtl of presspb_led is 
begin 
	LED <= PB;			
end rtl;