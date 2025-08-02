-- PLL Component File for LED Chaser
-- This file should be generated using Quartus Prime IP Catalog
-- Component: ALTPLL or Altera PLL
-- Input: 50MHz, Output: 1MHz

-- Note: This is a template. The actual PLL component should be generated
-- using Quartus Prime's IP Catalog with the following settings:
--
-- PLL Configuration:
-- - Input Clock Frequency: 50.0 MHz
-- - Output Clock 0: 1.0 MHz
-- - Phase Shift: 0 degrees
-- - Duty Cycle: 50%
--
-- To generate the actual PLL:
-- 1. Open Quartus Prime
-- 2. Go to Tools -> IP Catalog
-- 3. Search for "PLL" and select "ALTPLL" or "Altera PLL"
-- 4. Configure with above settings
-- 5. Generate with entity name "pll_led_chaser"

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- PLL Component Declaration (Template)
-- Replace this with the actual generated component from Quartus
component pll_led_chaser
    port (
        refclk   : in  std_logic := 'X';  -- 50MHz reference clock
        rst      : in  std_logic := 'X';  -- Reset input
        outclk_0 : out std_logic;         -- 1MHz output clock
        locked   : out std_logic          -- PLL locked indicator
    );
end component;

-- Alternative: Direct instantiation template for ALTPLL
-- COMPONENT altpll
-- GENERIC (
--     bandwidth_type          : STRING;
--     clk0_divide_by          : NATURAL;
--     clk0_duty_cycle         : NATURAL;
--     clk0_multiply_by        : NATURAL;
--     clk0_phase_shift        : STRING;
--     compensate_clock        : STRING;
--     inclk0_input_frequency  : NATURAL;
--     intended_device_family  : STRING;
--     lpm_hint                : STRING;
--     lpm_type                : STRING;
--     operation_mode          : STRING;
--     pll_type                : STRING;
--     port_activeclock        : STRING;
--     port_areset             : STRING;
--     port_clkbad0            : STRING;
--     port_clkbad1            : STRING;
--     port_clkloss            : STRING;
--     port_clkswitch          : STRING;
--     port_configupdate       : STRING;
--     port_fbin               : STRING;
--     port_inclk0             : STRING;
--     port_inclk1             : STRING;
--     port_locked             : STRING;
--     port_pfdena             : STRING;
--     port_phasecounterselect : STRING;
--     port_phasedone          : STRING;
--     port_phasestep          : STRING;
--     port_phaseupdown        : STRING;
--     port_pllena             : STRING;
--     port_scanaclr           : STRING;
--     port_scanclk            : STRING;
--     port_scanclkena         : STRING;
--     port_scandata           : STRING;
--     port_scandataout        : STRING;
--     port_scandone           : STRING;
--     port_scanread           : STRING;
--     port_scanwrite          : STRING;
--     port_clk0               : STRING;
--     port_clk1               : STRING;
--     port_clk2               : STRING;
--     port_clk3               : STRING;
--     port_clk4               : STRING;
--     port_clk5               : STRING;
--     port_clkena0            : STRING;
--     port_clkena1            : STRING;
--     port_clkena2            : STRING;
--     port_clkena3            : STRING;
--     port_clkena4            : STRING;
--     port_clkena5            : STRING;
--     port_extclk0            : STRING;
--     port_extclk1            : STRING;
--     port_extclk2            : STRING;
--     port_extclk3            : STRING;
--     width_clock             : NATURAL
-- );
-- PORT (
--     areset  : IN STD_LOGIC := '0';
--     inclk0  : IN STD_LOGIC := '0';
--     c0      : OUT STD_LOGIC;
--     locked  : OUT STD_LOGIC
-- );
-- END COMPONENT;
