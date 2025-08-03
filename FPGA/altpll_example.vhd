-- ALTPLL Example: 50MHz to 100MHz Clock Generation
-- Device: MAX10

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_doubler is
    port (
        clk_50mhz   : in  std_logic;   -- 50MHz input
        reset       : in  std_logic;   -- Reset
        clk_100mhz  : out std_logic;   -- 100MHz output
        pll_locked  : out std_logic    -- PLL lock status
    );
end clock_doubler;

architecture Behavioral of clock_doubler is

    -- ALTPLL Component Declaration
    component altpll
        generic (
            bandwidth_type          : string := "AUTO";
            clk0_divide_by          : natural := 1;
            clk0_duty_cycle         : natural := 50;
            clk0_multiply_by        : natural := 2;
            clk0_phase_shift        : string := "0";
            compensate_clock        : string := "CLK0";
            inclk0_input_frequency  : natural := 20000;  -- 50MHz = 20000ps
            intended_device_family  : string := "MAX 10";
            lpm_hint                : string := "CBX_MODULE_PREFIX=clock_doubler";
            lpm_type                : string := "altpll";
            operation_mode          : string := "NORMAL";
            pll_type                : string := "AUTO";
            port_activeclock        : string := "PORT_UNUSED";
            port_areset             : string := "PORT_USED";
            port_clkbad0            : string := "PORT_UNUSED";
            port_clkbad1            : string := "PORT_UNUSED";
            port_clkloss            : string := "PORT_UNUSED";
            port_clkswitch          : string := "PORT_UNUSED";
            port_configupdate       : string := "PORT_UNUSED";
            port_fbin               : string := "PORT_UNUSED";
            port_inclk0             : string := "PORT_USED";
            port_inclk1             : string := "PORT_UNUSED";
            port_locked             : string := "PORT_USED";
            port_pfdena             : string := "PORT_UNUSED";
            port_phasecounterselect : string := "PORT_UNUSED";
            port_phasedone          : string := "PORT_UNUSED";
            port_phasestep          : string := "PORT_UNUSED";
            port_phaseupdown        : string := "PORT_UNUSED";
            port_pllena             : string := "PORT_UNUSED";
            port_scanaclr           : string := "PORT_UNUSED";
            port_scanclk            : string := "PORT_UNUSED";
            port_scanclkena         : string := "PORT_UNUSED";
            port_scandata           : string := "PORT_UNUSED";
            port_scandataout        : string := "PORT_UNUSED";
            port_scandone           : string := "PORT_UNUSED";
            port_scanread           : string := "PORT_UNUSED";
            port_scanwrite          : string := "PORT_UNUSED";
            port_clk0               : string := "PORT_USED";
            port_clk1               : string := "PORT_UNUSED";
            port_clk2               : string := "PORT_UNUSED";
            port_clk3               : string := "PORT_UNUSED";
            port_clk4               : string := "PORT_UNUSED";
            port_clk5               : string := "PORT_UNUSED";
            port_clkena0            : string := "PORT_UNUSED";
            port_clkena1            : string := "PORT_UNUSED";
            port_clkena2            : string := "PORT_UNUSED";
            port_clkena3            : string := "PORT_UNUSED";
            port_clkena4            : string := "PORT_UNUSED";
            port_clkena5            : string := "PORT_UNUSED";
            port_extclk0            : string := "PORT_UNUSED";
            port_extclk1            : string := "PORT_UNUSED";
            port_extclk2            : string := "PORT_UNUSED";
            port_extclk3            : string := "PORT_UNUSED";
            width_clock             : natural := 5
        );
        port (
            areset  : in  std_logic := '0';
            inclk0  : in  std_logic := '0';
            c0      : out std_logic;
            locked  : out std_logic
        );
    end component;

begin

    -- ALTPLL Instance
    pll_inst : altpll
        generic map (
            bandwidth_type         => "AUTO",
            clk0_divide_by         => 1,          -- No division
            clk0_duty_cycle        => 50,         -- 50% duty cycle
            clk0_multiply_by       => 2,          -- 2x multiplication
            clk0_phase_shift       => "0",        -- No phase shift
            inclk0_input_frequency => 20000,      -- 50MHz input (20000ps period)
            intended_device_family => "MAX 10",
            operation_mode         => "NORMAL",
            pll_type              => "AUTO"
        )
        port map (
            areset => reset,
            inclk0 => clk_50mhz,
            c0     => clk_100mhz,
            locked => pll_locked
        );

end Behavioral;

-- Usage Notes:
-- 1. This generates 100MHz from 50MHz input
-- 2. Wait for pll_locked='1' before using clk_100mhz
-- 3. Add appropriate timing constraints in SDC file:
--    create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
--    derive_pll_clocks -create_base_clocks
