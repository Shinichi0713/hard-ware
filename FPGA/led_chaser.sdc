# SDC File for LED Chaser MAX10 Project
# Device: 10M08SAE144C8G
# Project: led_chaser_max10

# ==================================================
# Clock Constraints
# ==================================================

# Primary clock constraint (50MHz input clock)
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# Derive PLL clocks automatically
derive_pll_clocks -create_base_clocks

# ==================================================
# Input/Output Delays
# ==================================================

# Input delay for reset signal
set_input_delay -clock clk_50mhz -max 2.0 [get_ports reset_n]
set_input_delay -clock clk_50mhz -min 0.5 [get_ports reset_n]

# Output delay for LED signals
# Note: LED outputs are driven by PLL-derived clock
set_output_delay -clock [get_clocks {*pll*c0}] -max 2.0 [get_ports led_out[*]]
set_output_delay -clock [get_clocks {*pll*c0}] -min 0.5 [get_ports led_out[*]]

# ==================================================
# Clock Groups (if needed)
# ==================================================

# Set clock groups to avoid timing analysis between unrelated clocks
# set_clock_groups -asynchronous -group [get_clocks clk_50mhz] -group [get_clocks {*pll*c0}]

# ==================================================
# False Paths (if needed)
# ==================================================

# Set false path for reset signal (asynchronous reset)
set_false_path -from [get_ports reset_n] -to [all_registers]

# ==================================================
# Maximum Delay Constraints (if needed)
# ==================================================

# Set maximum delay for combinational paths
# set_max_delay -from [get_registers] -to [get_ports led_out[*]] 10.0

# ==================================================
# Timing Exceptions (if needed)
# ==================================================

# Multicycle paths (if any logic requires multiple clock cycles)
# set_multicycle_path -setup -end 2 -from [get_registers] -to [get_registers]
# set_multicycle_path -hold -end 1 -from [get_registers] -to [get_registers]
