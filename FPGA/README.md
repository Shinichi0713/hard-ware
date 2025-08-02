# LED Chaser MAX10 Project Setup Guide

## Overview
This project implements an LED chaser using MAX10's internal PLL to generate a slower clock for LED pattern control.

## Files Description

### 1. led_chaser_max10.vhd
- Main entity implementing LED chaser functionality
- Uses internal PLL to generate 1MHz clock from 50MHz input
- Controls 8 LEDs in a sequential pattern (1 second per LED)

### 2. pll_component_template.vhd
- Template for PLL component
- Must be replaced with actual PLL generated from Quartus Prime

## Hardware Requirements

### Input Signals:
- `clk_50mhz`: 50MHz system clock
- `reset_n`: Active low reset button

### Output Signals:
- `led_out[7:0]`: 8 LED outputs

## Quartus Prime Setup Instructions

### Step 1: Create PLL IP
1. Open Quartus Prime
2. Go to **Tools → IP Catalog**
3. Search for "PLL" and select **"ALTPLL"** or **"Altera PLL"**
4. Configure PLL with following settings:
   - **Entity Name**: `pll_led_chaser`
   - **Input Clock Frequency**: 50.0 MHz
   - **Output Clock 0**: 1.0 MHz
   - **Phase Shift**: 0 degrees
   - **Duty Cycle**: 50%
5. Generate the IP core

### Step 2: Pin Assignment
Assign pins in Quartus Prime Pin Planner:

```
# Example pin assignments (adjust for your board)
set_location_assignment PIN_P11 -to clk_50mhz
set_location_assignment PIN_P12 -to reset_n
set_location_assignment PIN_A8 -to led_out[0]
set_location_assignment PIN_A9 -to led_out[1]
set_location_assignment PIN_A10 -to led_out[2]
set_location_assignment PIN_B10 -to led_out[3]
set_location_assignment PIN_D13 -to led_out[4]
set_location_assignment PIN_C13 -to led_out[5]
set_location_assignment PIN_E14 -to led_out[6]
set_location_assignment PIN_D14 -to led_out[7]
```

### Step 3: Compilation and Programming
1. Add `led_chaser_max10.vhd` to your project
2. Set as top-level entity
3. Compile the project
4. Program the MAX10 device

## Operation

### LED Pattern:
- LEDs light up sequentially from LED0 to LED7
- Each LED stays on for 1 second
- Pattern repeats continuously
- Reset button resets the pattern to LED0

### Timing:
- PLL generates 1MHz clock from 50MHz input
- Counter counts to 1,000,000 (1 second at 1MHz)
- LED position updates every second

## Features

### PLL Integration:
- Uses MAX10 internal PLL for clock generation
- Automatic reset handling until PLL locks
- Clean clock distribution

### Robust Design:
- Proper reset synchronization
- PLL lock detection
- Modular design for easy modification

## Customization Options

### Change LED Speed:
Modify `COUNT_MAX` constant in led_chaser_max10.vhd:
```vhdl
-- For 0.5 second per LED:
constant COUNT_MAX : unsigned(19 downto 0) := to_unsigned(500000-1, 20);

-- For 2 seconds per LED:
constant COUNT_MAX : unsigned(19 downto 0) := to_unsigned(2000000-1, 20);
```

### Change PLL Output Frequency:
1. Regenerate PLL IP with different output frequency
2. Update `COUNT_MAX` accordingly
3. For example, with 2MHz PLL output:
```vhdl
constant COUNT_MAX : unsigned(20 downto 0) := to_unsigned(2000000-1, 21);
```

### Different LED Patterns:
Modify the `led_decoder_proc` process to implement different patterns:
- Bouncing pattern
- Multiple LEDs on simultaneously
- Random patterns

## Troubleshooting

### Common Issues:

1. **LEDs not working:**
   - Check pin assignments
   - Verify PLL is generating correct frequency
   - Check reset signal polarity

2. **PLL not locking:**
   - Verify input clock frequency
   - Check PLL configuration
   - Ensure proper power supply

3. **Timing issues:**
   - Verify `COUNT_MAX` calculation
   - Check PLL output frequency
   - Review clock constraints

### Debug Suggestions:
- Use SignalTap Logic Analyzer to monitor internal signals
- Check `pll_locked` signal
- Monitor `led_counter` and `led_position` signals

## Board-Specific Notes

### DE10-Lite:
- 50MHz clock on PIN_P11
- LEDs on PINA8-PINA15
- Push buttons for reset

### Custom Boards:
- Adjust pin assignments accordingly
- Verify clock input frequency
- Check LED driver requirements
