library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity light_illumination is
port(
	osc_clk: in std_logic;
	reset: in std_logic;
	button: in std_logic;
	led: out unsigned(3 downto 0));
end light_illumination;

architecture rtl of light_illumination is

	signal pll_c0 : std_logic; 
	signal cnt : unsigned (31 downto 0); 
	signal tmp : unsigned (3 downto 0);

	component pll
	port(
		areset: in std_logic :='0';
		inclk0 : in std_logic :='0';
		c0 : out std_logic);
	end component;

	component counter
	port(
		clock : in std_logic;
		reset : in std_logic;
		counter_out : out unsigned(31 downto 0));
	end component;
	
	component counter_bus_mux
	port(
		dataa : in unsigned(3 downto 0); 
		datab : in unsigned(3 downto 0); 
		sel : in std_logic;
		result : out unsigned(3 downto 0));
	end component;
	
	begin
		pll_inst:pll port map(
			areset => not reset,
			inclk0 => osc_clk,
			c0 => pll_c0);
		counter_inst:counter port map(
			clock => pll_c0,
			reset => reset,
			counter_out => cnt
		);
		counter_bus_mux_inst : counter_bus_mux port map ( 
			dataa => cnt(24 downto 21), 
			datab => cnt(26 downto 23), 
			sel  => BUTTON, 
			result => tmp 
		 );
	led<= not tmp;
end rtl;


