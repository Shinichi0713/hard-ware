-- ?????
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- ????????
entity compare is 
    Port(
	da: in std_logic_vector(7 downto 0);
	db: in std_logic_vector(7 downto 0);
	equ: out std_logic;
	agb: out std_logic;
	alb: out std_logic
    );
end compare;

-- ?????????
architecture Behavioral of compare is
begin
    process(da, db)
    begin
        if da = db then
	    equ <= '1';
	    agb <= '0';
	    alb <= '0';
	elsif da > db then
	    equ <= '0';
	    agb <= '1';
	    alb <= '0';
	else
	    equ <= '0';
	    agb <= '0';
	    alb <= '1';
	end if;
    end process;
end Behavioral;


