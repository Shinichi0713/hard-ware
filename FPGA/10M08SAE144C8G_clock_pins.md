# 10M08SAE144C8G Clock Pin Investigation

## Device Information
- Device: 10M08SAE144C8G
- Package: 144-pin EQFP
- Speed Grade: C8

## Clock Pin Verification Steps

### Step 1: Open Device and Pin-Out Viewer
1. Launch Quartus Prime
2. Tools → Device and Pin-Out Viewer
3. Select Family: MAX 10
4. Select Device: 10M08SAE144C8G

### Step 2: Identify Clock Pins
Look for pins with following characteristics:
- Function contains "GCLK" (Global Clock)
- Can drive global clock networks
- Suitable for high-frequency signals

### Step 3: Common Clock Pins for 144-pin Package
Based on MAX10 architecture, typical global clock pins:

```
Pin Number | Pin Name | Function     | Recommended Use
-----------|----------|--------------|----------------
PIN_27     | GCLK0    | Global CLK 0 | Primary clock input (RECOMMENDED)
PIN_28     | GCLK1    | Global CLK 1 | Secondary clock
PIN_87     | GCLK2    | Global CLK 2 | Alternative clock
PIN_88     | GCLK3    | Global CLK 3 | Alternative clock
```

### Step 4: Pin Assignment in Quartus
```tcl
# Add to .qsf file
set_location_assignment PIN_27 -to clk_50mhz
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_50mhz

# Clock constraint in .sdc file
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
```

### Step 5: Verification
1. Check Pin Planner for conflicts
2. Verify clock can reach all logic elements
3. Run timing analysis

## Important Notes

### Clock Quality Requirements
- Use global clock pins for best performance
- Avoid regular I/O pins for high-frequency clocks
- Ensure proper termination and signal integrity

### Package-Specific Considerations
- 144-pin EQFP package has specific pin locations
- Consult official Intel documentation for exact pinout
- Some pins may have restrictions based on configuration

### Alternative Investigation Methods
If standard pins don't work:
1. Check board schematic for clock routing
2. Verify external oscillator connections
3. Consider using different global clock inputs

## References
- Intel MAX 10 FPGA Device Datasheet
- MAX 10 FPGA Development Kit User Guide
- Quartus Prime Pin Planner Documentation
