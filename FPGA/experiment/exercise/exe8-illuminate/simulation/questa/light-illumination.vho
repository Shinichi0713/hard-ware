-- Copyright (C) 2025  Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Altera and sold by Altera or its authorized distributors.  Please
-- refer to the Altera Software License Subscription Agreements 
-- on the Quartus Prime software download page.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition"

-- DATE "09/15/2025 15:01:25"

-- 
-- Device: Altera 10M50DAF484C6GES Package FBGA484
-- 

-- 
-- This VHDL file should be used for QuestaSim (VHDL) only
-- 

LIBRARY ALTERA;
LIBRARY FIFTYFIVENM;
LIBRARY IEEE;
USE ALTERA.ALTERA_PRIMITIVES_COMPONENTS.ALL;
USE FIFTYFIVENM.FIFTYFIVENM_COMPONENTS.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	light_illumination IS
    PORT (
	osc_clk : IN std_logic;
	reset : IN std_logic;
	button : IN std_logic;
	led : OUT IEEE.NUMERIC_STD.unsigned(3 DOWNTO 0)
	);
END light_illumination;

-- Design Ports Information
-- led[0]	=>  Location: PIN_AA2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- led[1]	=>  Location: PIN_Y5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- led[2]	=>  Location: PIN_W4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- led[3]	=>  Location: PIN_W3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- button	=>  Location: PIN_V8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- reset	=>  Location: PIN_T6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- osc_clk	=>  Location: PIN_R11,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF light_illumination IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_osc_clk : std_logic;
SIGNAL ww_reset : std_logic;
SIGNAL ww_button : std_logic;
SIGNAL ww_led : std_logic_vector(3 DOWNTO 0);
SIGNAL \pll_inst|altpll_component|auto_generated|pll1_INCLK_bus\ : std_logic_vector(1 DOWNTO 0);
SIGNAL \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_ADC1~_CHSEL_bus\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_ADC2~_CHSEL_bus\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \~QUARTUS_CREATED_UNVM~~busy\ : std_logic;
SIGNAL \~ALTERA_TMS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TMS~~padout\ : std_logic;
SIGNAL \~ALTERA_TCK~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TCK~~padout\ : std_logic;
SIGNAL \~ALTERA_TDI~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TDI~~padout\ : std_logic;
SIGNAL \~ALTERA_TDO~~padout\ : std_logic;
SIGNAL \~ALTERA_CONFIG_SEL~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_CONFIG_SEL~~padout\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~padout\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~padout\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~padout\ : std_logic;
SIGNAL \~QUARTUS_CREATED_ADC1~~eoc\ : std_logic;
SIGNAL \~QUARTUS_CREATED_ADC2~~eoc\ : std_logic;
SIGNAL \~ALTERA_TDO~~obuf_o\ : std_logic;
SIGNAL \reset~input_o\ : std_logic;
SIGNAL \osc_clk~input_o\ : std_logic;
SIGNAL \pll_inst|altpll_component|auto_generated|wire_pll1_fbout\ : std_logic;
SIGNAL \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\ : std_logic;
SIGNAL \counter_inst|cnt[0]~78_combout\ : std_logic;
SIGNAL \counter_inst|cnt[1]~26_combout\ : std_logic;
SIGNAL \counter_inst|cnt[1]~27\ : std_logic;
SIGNAL \counter_inst|cnt[2]~28_combout\ : std_logic;
SIGNAL \counter_inst|cnt[2]~29\ : std_logic;
SIGNAL \counter_inst|cnt[3]~30_combout\ : std_logic;
SIGNAL \counter_inst|cnt[3]~31\ : std_logic;
SIGNAL \counter_inst|cnt[4]~32_combout\ : std_logic;
SIGNAL \counter_inst|cnt[4]~33\ : std_logic;
SIGNAL \counter_inst|cnt[5]~34_combout\ : std_logic;
SIGNAL \counter_inst|cnt[5]~35\ : std_logic;
SIGNAL \counter_inst|cnt[6]~36_combout\ : std_logic;
SIGNAL \counter_inst|cnt[6]~37\ : std_logic;
SIGNAL \counter_inst|cnt[7]~38_combout\ : std_logic;
SIGNAL \counter_inst|cnt[7]~39\ : std_logic;
SIGNAL \counter_inst|cnt[8]~40_combout\ : std_logic;
SIGNAL \counter_inst|cnt[8]~41\ : std_logic;
SIGNAL \counter_inst|cnt[9]~42_combout\ : std_logic;
SIGNAL \counter_inst|cnt[9]~43\ : std_logic;
SIGNAL \counter_inst|cnt[10]~44_combout\ : std_logic;
SIGNAL \counter_inst|cnt[10]~45\ : std_logic;
SIGNAL \counter_inst|cnt[11]~46_combout\ : std_logic;
SIGNAL \counter_inst|cnt[11]~47\ : std_logic;
SIGNAL \counter_inst|cnt[12]~48_combout\ : std_logic;
SIGNAL \counter_inst|cnt[12]~49\ : std_logic;
SIGNAL \counter_inst|cnt[13]~50_combout\ : std_logic;
SIGNAL \counter_inst|cnt[13]~51\ : std_logic;
SIGNAL \counter_inst|cnt[14]~52_combout\ : std_logic;
SIGNAL \counter_inst|cnt[14]~53\ : std_logic;
SIGNAL \counter_inst|cnt[15]~54_combout\ : std_logic;
SIGNAL \counter_inst|cnt[15]~55\ : std_logic;
SIGNAL \counter_inst|cnt[16]~56_combout\ : std_logic;
SIGNAL \counter_inst|cnt[16]~57\ : std_logic;
SIGNAL \counter_inst|cnt[17]~58_combout\ : std_logic;
SIGNAL \counter_inst|cnt[17]~59\ : std_logic;
SIGNAL \counter_inst|cnt[18]~60_combout\ : std_logic;
SIGNAL \counter_inst|cnt[18]~61\ : std_logic;
SIGNAL \counter_inst|cnt[19]~62_combout\ : std_logic;
SIGNAL \counter_inst|cnt[19]~63\ : std_logic;
SIGNAL \counter_inst|cnt[20]~64_combout\ : std_logic;
SIGNAL \counter_inst|cnt[20]~65\ : std_logic;
SIGNAL \counter_inst|cnt[21]~66_combout\ : std_logic;
SIGNAL \counter_inst|cnt[21]~67\ : std_logic;
SIGNAL \counter_inst|cnt[22]~68_combout\ : std_logic;
SIGNAL \counter_inst|cnt[22]~69\ : std_logic;
SIGNAL \counter_inst|cnt[23]~70_combout\ : std_logic;
SIGNAL \button~input_o\ : std_logic;
SIGNAL \counter_bus_mux_inst|result[0]~0_combout\ : std_logic;
SIGNAL \counter_inst|cnt[23]~71\ : std_logic;
SIGNAL \counter_inst|cnt[24]~72_combout\ : std_logic;
SIGNAL \counter_bus_mux_inst|result[1]~1_combout\ : std_logic;
SIGNAL \counter_inst|cnt[24]~73\ : std_logic;
SIGNAL \counter_inst|cnt[25]~74_combout\ : std_logic;
SIGNAL \counter_bus_mux_inst|result[2]~2_combout\ : std_logic;
SIGNAL \counter_inst|cnt[25]~75\ : std_logic;
SIGNAL \counter_inst|cnt[26]~76_combout\ : std_logic;
SIGNAL \counter_bus_mux_inst|result[3]~3_combout\ : std_logic;
SIGNAL \counter_inst|cnt\ : std_logic_vector(31 DOWNTO 0);
SIGNAL \pll_inst|altpll_component|auto_generated|wire_pll1_clk\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \counter_bus_mux_inst|ALT_INV_result[0]~0_combout\ : std_logic;
SIGNAL \counter_bus_mux_inst|ALT_INV_result[1]~1_combout\ : std_logic;
SIGNAL \ALT_INV_reset~input_o\ : std_logic;
SIGNAL \counter_bus_mux_inst|ALT_INV_result[2]~2_combout\ : std_logic;
SIGNAL \counter_bus_mux_inst|ALT_INV_result[3]~3_combout\ : std_logic;

BEGIN

ww_osc_clk <= osc_clk;
ww_reset <= reset;
ww_button <= button;
led <= IEEE.NUMERIC_STD.UNSIGNED(ww_led);
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

\pll_inst|altpll_component|auto_generated|pll1_INCLK_bus\ <= (gnd & \osc_clk~input_o\);

\pll_inst|altpll_component|auto_generated|wire_pll1_clk\(0) <= \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\(0);
\pll_inst|altpll_component|auto_generated|wire_pll1_clk\(1) <= \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\(1);
\pll_inst|altpll_component|auto_generated|wire_pll1_clk\(2) <= \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\(2);
\pll_inst|altpll_component|auto_generated|wire_pll1_clk\(3) <= \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\(3);
\pll_inst|altpll_component|auto_generated|wire_pll1_clk\(4) <= \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\(4);

\~QUARTUS_CREATED_ADC1~_CHSEL_bus\ <= (\~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\);

\~QUARTUS_CREATED_ADC2~_CHSEL_bus\ <= (\~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\);

\pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \pll_inst|altpll_component|auto_generated|wire_pll1_clk\(0));
\counter_bus_mux_inst|ALT_INV_result[0]~0_combout\ <= NOT \counter_bus_mux_inst|result[0]~0_combout\;
\counter_bus_mux_inst|ALT_INV_result[1]~1_combout\ <= NOT \counter_bus_mux_inst|result[1]~1_combout\;
\ALT_INV_reset~input_o\ <= NOT \reset~input_o\;
\counter_bus_mux_inst|ALT_INV_result[2]~2_combout\ <= NOT \counter_bus_mux_inst|result[2]~2_combout\;
\counter_bus_mux_inst|ALT_INV_result[3]~3_combout\ <= NOT \counter_bus_mux_inst|result[3]~3_combout\;

-- Location: LCCOMB_X44_Y51_N8
\~QUARTUS_CREATED_GND~I\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \~QUARTUS_CREATED_GND~I_combout\ = GND

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	combout => \~QUARTUS_CREATED_GND~I_combout\);

-- Location: IOOBUF_X18_Y0_N23
\led[0]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \counter_bus_mux_inst|ALT_INV_result[0]~0_combout\,
	devoe => ww_devoe,
	o => ww_led(0));

-- Location: IOOBUF_X18_Y0_N2
\led[1]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \counter_bus_mux_inst|ALT_INV_result[1]~1_combout\,
	devoe => ww_devoe,
	o => ww_led(1));

-- Location: IOOBUF_X18_Y0_N16
\led[2]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \counter_bus_mux_inst|ALT_INV_result[2]~2_combout\,
	devoe => ww_devoe,
	o => ww_led(2));

-- Location: IOOBUF_X18_Y0_N9
\led[3]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \counter_bus_mux_inst|ALT_INV_result[3]~3_combout\,
	devoe => ww_devoe,
	o => ww_led(3));

-- Location: IOIBUF_X0_Y3_N22
\reset~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_reset,
	o => \reset~input_o\);

-- Location: IOIBUF_X31_Y0_N1
\osc_clk~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_osc_clk,
	o => \osc_clk~input_o\);

-- Location: PLL_1
\pll_inst|altpll_component|auto_generated|pll1\ : fiftyfivenm_pll
-- pragma translate_off
GENERIC MAP (
	auto_settings => "false",
	bandwidth_type => "medium",
	c0_high => 60,
	c0_initial => 1,
	c0_low => 60,
	c0_mode => "even",
	c0_ph => 0,
	c1_high => 0,
	c1_initial => 0,
	c1_low => 0,
	c1_mode => "bypass",
	c1_ph => 0,
	c1_use_casc_in => "off",
	c2_high => 0,
	c2_initial => 0,
	c2_low => 0,
	c2_mode => "bypass",
	c2_ph => 0,
	c2_use_casc_in => "off",
	c3_high => 0,
	c3_initial => 0,
	c3_low => 0,
	c3_mode => "bypass",
	c3_ph => 0,
	c3_use_casc_in => "off",
	c4_high => 0,
	c4_initial => 0,
	c4_low => 0,
	c4_mode => "bypass",
	c4_ph => 0,
	c4_use_casc_in => "off",
	charge_pump_current_bits => 1,
	clk0_counter => "c0",
	clk0_divide_by => 10,
	clk0_duty_cycle => 50,
	clk0_multiply_by => 1,
	clk0_phase_shift => "0",
	clk1_counter => "unused",
	clk1_divide_by => 0,
	clk1_duty_cycle => 50,
	clk1_multiply_by => 0,
	clk1_phase_shift => "0",
	clk2_counter => "unused",
	clk2_divide_by => 0,
	clk2_duty_cycle => 50,
	clk2_multiply_by => 0,
	clk2_phase_shift => "0",
	clk3_counter => "unused",
	clk3_divide_by => 0,
	clk3_duty_cycle => 50,
	clk3_multiply_by => 0,
	clk3_phase_shift => "0",
	clk4_counter => "unused",
	clk4_divide_by => 0,
	clk4_duty_cycle => 50,
	clk4_multiply_by => 0,
	clk4_phase_shift => "0",
	compensate_clock => "clock0",
	inclk0_input_frequency => 20000,
	inclk1_input_frequency => 0,
	loop_filter_c_bits => 0,
	loop_filter_r_bits => 27,
	m => 12,
	m_initial => 1,
	m_ph => 0,
	n => 1,
	operation_mode => "normal",
	pfd_max => 200000,
	pfd_min => 3076,
	self_reset_on_loss_lock => "off",
	simulation_type => "functional",
	switch_over_type => "auto",
	vco_center => 1538,
	vco_divide_by => 0,
	vco_frequency_control => "auto",
	vco_max => 3333,
	vco_min => 1538,
	vco_multiply_by => 0,
	vco_phase_shift_step => 208,
	vco_post_scale => 2)
-- pragma translate_on
PORT MAP (
	areset => \ALT_INV_reset~input_o\,
	fbin => \pll_inst|altpll_component|auto_generated|wire_pll1_fbout\,
	inclk => \pll_inst|altpll_component|auto_generated|pll1_INCLK_bus\,
	fbout => \pll_inst|altpll_component|auto_generated|wire_pll1_fbout\,
	clk => \pll_inst|altpll_component|auto_generated|pll1_CLK_bus\);

-- Location: CLKCTRL_G18
\pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl\ : fiftyfivenm_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\);

-- Location: LCCOMB_X19_Y4_N0
\counter_inst|cnt[0]~78\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[0]~78_combout\ = \counter_inst|cnt\(0) $ (\reset~input_o\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111111110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \counter_inst|cnt\(0),
	datad => \reset~input_o\,
	combout => \counter_inst|cnt[0]~78_combout\);

-- Location: FF_X19_Y4_N1
\counter_inst|cnt[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[0]~78_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(0));

-- Location: LCCOMB_X19_Y4_N6
\counter_inst|cnt[1]~26\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[1]~26_combout\ = (\counter_inst|cnt\(1) & (\counter_inst|cnt\(0) $ (VCC))) # (!\counter_inst|cnt\(1) & (\counter_inst|cnt\(0) & VCC))
-- \counter_inst|cnt[1]~27\ = CARRY((\counter_inst|cnt\(1) & \counter_inst|cnt\(0)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0110011010001000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(1),
	datab => \counter_inst|cnt\(0),
	datad => VCC,
	combout => \counter_inst|cnt[1]~26_combout\,
	cout => \counter_inst|cnt[1]~27\);

-- Location: FF_X19_Y4_N7
\counter_inst|cnt[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[1]~26_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(1));

-- Location: LCCOMB_X19_Y4_N8
\counter_inst|cnt[2]~28\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[2]~28_combout\ = (\counter_inst|cnt\(2) & (!\counter_inst|cnt[1]~27\)) # (!\counter_inst|cnt\(2) & ((\counter_inst|cnt[1]~27\) # (GND)))
-- \counter_inst|cnt[2]~29\ = CARRY((!\counter_inst|cnt[1]~27\) # (!\counter_inst|cnt\(2)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(2),
	datad => VCC,
	cin => \counter_inst|cnt[1]~27\,
	combout => \counter_inst|cnt[2]~28_combout\,
	cout => \counter_inst|cnt[2]~29\);

-- Location: FF_X19_Y4_N9
\counter_inst|cnt[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[2]~28_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(2));

-- Location: LCCOMB_X19_Y4_N10
\counter_inst|cnt[3]~30\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[3]~30_combout\ = (\counter_inst|cnt\(3) & (\counter_inst|cnt[2]~29\ $ (GND))) # (!\counter_inst|cnt\(3) & (!\counter_inst|cnt[2]~29\ & VCC))
-- \counter_inst|cnt[3]~31\ = CARRY((\counter_inst|cnt\(3) & !\counter_inst|cnt[2]~29\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(3),
	datad => VCC,
	cin => \counter_inst|cnt[2]~29\,
	combout => \counter_inst|cnt[3]~30_combout\,
	cout => \counter_inst|cnt[3]~31\);

-- Location: FF_X19_Y4_N11
\counter_inst|cnt[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[3]~30_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(3));

-- Location: LCCOMB_X19_Y4_N12
\counter_inst|cnt[4]~32\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[4]~32_combout\ = (\counter_inst|cnt\(4) & (!\counter_inst|cnt[3]~31\)) # (!\counter_inst|cnt\(4) & ((\counter_inst|cnt[3]~31\) # (GND)))
-- \counter_inst|cnt[4]~33\ = CARRY((!\counter_inst|cnt[3]~31\) # (!\counter_inst|cnt\(4)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(4),
	datad => VCC,
	cin => \counter_inst|cnt[3]~31\,
	combout => \counter_inst|cnt[4]~32_combout\,
	cout => \counter_inst|cnt[4]~33\);

-- Location: FF_X19_Y4_N13
\counter_inst|cnt[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[4]~32_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(4));

-- Location: LCCOMB_X19_Y4_N14
\counter_inst|cnt[5]~34\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[5]~34_combout\ = (\counter_inst|cnt\(5) & (\counter_inst|cnt[4]~33\ $ (GND))) # (!\counter_inst|cnt\(5) & (!\counter_inst|cnt[4]~33\ & VCC))
-- \counter_inst|cnt[5]~35\ = CARRY((\counter_inst|cnt\(5) & !\counter_inst|cnt[4]~33\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(5),
	datad => VCC,
	cin => \counter_inst|cnt[4]~33\,
	combout => \counter_inst|cnt[5]~34_combout\,
	cout => \counter_inst|cnt[5]~35\);

-- Location: FF_X19_Y4_N15
\counter_inst|cnt[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[5]~34_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(5));

-- Location: LCCOMB_X19_Y4_N16
\counter_inst|cnt[6]~36\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[6]~36_combout\ = (\counter_inst|cnt\(6) & (!\counter_inst|cnt[5]~35\)) # (!\counter_inst|cnt\(6) & ((\counter_inst|cnt[5]~35\) # (GND)))
-- \counter_inst|cnt[6]~37\ = CARRY((!\counter_inst|cnt[5]~35\) # (!\counter_inst|cnt\(6)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(6),
	datad => VCC,
	cin => \counter_inst|cnt[5]~35\,
	combout => \counter_inst|cnt[6]~36_combout\,
	cout => \counter_inst|cnt[6]~37\);

-- Location: FF_X19_Y4_N17
\counter_inst|cnt[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[6]~36_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(6));

-- Location: LCCOMB_X19_Y4_N18
\counter_inst|cnt[7]~38\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[7]~38_combout\ = (\counter_inst|cnt\(7) & (\counter_inst|cnt[6]~37\ $ (GND))) # (!\counter_inst|cnt\(7) & (!\counter_inst|cnt[6]~37\ & VCC))
-- \counter_inst|cnt[7]~39\ = CARRY((\counter_inst|cnt\(7) & !\counter_inst|cnt[6]~37\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(7),
	datad => VCC,
	cin => \counter_inst|cnt[6]~37\,
	combout => \counter_inst|cnt[7]~38_combout\,
	cout => \counter_inst|cnt[7]~39\);

-- Location: FF_X19_Y4_N19
\counter_inst|cnt[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[7]~38_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(7));

-- Location: LCCOMB_X19_Y4_N20
\counter_inst|cnt[8]~40\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[8]~40_combout\ = (\counter_inst|cnt\(8) & (!\counter_inst|cnt[7]~39\)) # (!\counter_inst|cnt\(8) & ((\counter_inst|cnt[7]~39\) # (GND)))
-- \counter_inst|cnt[8]~41\ = CARRY((!\counter_inst|cnt[7]~39\) # (!\counter_inst|cnt\(8)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(8),
	datad => VCC,
	cin => \counter_inst|cnt[7]~39\,
	combout => \counter_inst|cnt[8]~40_combout\,
	cout => \counter_inst|cnt[8]~41\);

-- Location: FF_X19_Y4_N21
\counter_inst|cnt[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[8]~40_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(8));

-- Location: LCCOMB_X19_Y4_N22
\counter_inst|cnt[9]~42\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[9]~42_combout\ = (\counter_inst|cnt\(9) & (\counter_inst|cnt[8]~41\ $ (GND))) # (!\counter_inst|cnt\(9) & (!\counter_inst|cnt[8]~41\ & VCC))
-- \counter_inst|cnt[9]~43\ = CARRY((\counter_inst|cnt\(9) & !\counter_inst|cnt[8]~41\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(9),
	datad => VCC,
	cin => \counter_inst|cnt[8]~41\,
	combout => \counter_inst|cnt[9]~42_combout\,
	cout => \counter_inst|cnt[9]~43\);

-- Location: FF_X19_Y4_N23
\counter_inst|cnt[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[9]~42_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(9));

-- Location: LCCOMB_X19_Y4_N24
\counter_inst|cnt[10]~44\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[10]~44_combout\ = (\counter_inst|cnt\(10) & (!\counter_inst|cnt[9]~43\)) # (!\counter_inst|cnt\(10) & ((\counter_inst|cnt[9]~43\) # (GND)))
-- \counter_inst|cnt[10]~45\ = CARRY((!\counter_inst|cnt[9]~43\) # (!\counter_inst|cnt\(10)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(10),
	datad => VCC,
	cin => \counter_inst|cnt[9]~43\,
	combout => \counter_inst|cnt[10]~44_combout\,
	cout => \counter_inst|cnt[10]~45\);

-- Location: FF_X19_Y4_N25
\counter_inst|cnt[10]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[10]~44_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(10));

-- Location: LCCOMB_X19_Y4_N26
\counter_inst|cnt[11]~46\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[11]~46_combout\ = (\counter_inst|cnt\(11) & (\counter_inst|cnt[10]~45\ $ (GND))) # (!\counter_inst|cnt\(11) & (!\counter_inst|cnt[10]~45\ & VCC))
-- \counter_inst|cnt[11]~47\ = CARRY((\counter_inst|cnt\(11) & !\counter_inst|cnt[10]~45\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(11),
	datad => VCC,
	cin => \counter_inst|cnt[10]~45\,
	combout => \counter_inst|cnt[11]~46_combout\,
	cout => \counter_inst|cnt[11]~47\);

-- Location: FF_X19_Y4_N27
\counter_inst|cnt[11]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[11]~46_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(11));

-- Location: LCCOMB_X19_Y4_N28
\counter_inst|cnt[12]~48\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[12]~48_combout\ = (\counter_inst|cnt\(12) & (!\counter_inst|cnt[11]~47\)) # (!\counter_inst|cnt\(12) & ((\counter_inst|cnt[11]~47\) # (GND)))
-- \counter_inst|cnt[12]~49\ = CARRY((!\counter_inst|cnt[11]~47\) # (!\counter_inst|cnt\(12)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(12),
	datad => VCC,
	cin => \counter_inst|cnt[11]~47\,
	combout => \counter_inst|cnt[12]~48_combout\,
	cout => \counter_inst|cnt[12]~49\);

-- Location: FF_X19_Y4_N29
\counter_inst|cnt[12]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[12]~48_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(12));

-- Location: LCCOMB_X19_Y4_N30
\counter_inst|cnt[13]~50\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[13]~50_combout\ = (\counter_inst|cnt\(13) & (\counter_inst|cnt[12]~49\ $ (GND))) # (!\counter_inst|cnt\(13) & (!\counter_inst|cnt[12]~49\ & VCC))
-- \counter_inst|cnt[13]~51\ = CARRY((\counter_inst|cnt\(13) & !\counter_inst|cnt[12]~49\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(13),
	datad => VCC,
	cin => \counter_inst|cnt[12]~49\,
	combout => \counter_inst|cnt[13]~50_combout\,
	cout => \counter_inst|cnt[13]~51\);

-- Location: FF_X19_Y4_N31
\counter_inst|cnt[13]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[13]~50_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(13));

-- Location: LCCOMB_X19_Y3_N0
\counter_inst|cnt[14]~52\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[14]~52_combout\ = (\counter_inst|cnt\(14) & (!\counter_inst|cnt[13]~51\)) # (!\counter_inst|cnt\(14) & ((\counter_inst|cnt[13]~51\) # (GND)))
-- \counter_inst|cnt[14]~53\ = CARRY((!\counter_inst|cnt[13]~51\) # (!\counter_inst|cnt\(14)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(14),
	datad => VCC,
	cin => \counter_inst|cnt[13]~51\,
	combout => \counter_inst|cnt[14]~52_combout\,
	cout => \counter_inst|cnt[14]~53\);

-- Location: FF_X19_Y3_N1
\counter_inst|cnt[14]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[14]~52_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(14));

-- Location: LCCOMB_X19_Y3_N2
\counter_inst|cnt[15]~54\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[15]~54_combout\ = (\counter_inst|cnt\(15) & (\counter_inst|cnt[14]~53\ $ (GND))) # (!\counter_inst|cnt\(15) & (!\counter_inst|cnt[14]~53\ & VCC))
-- \counter_inst|cnt[15]~55\ = CARRY((\counter_inst|cnt\(15) & !\counter_inst|cnt[14]~53\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(15),
	datad => VCC,
	cin => \counter_inst|cnt[14]~53\,
	combout => \counter_inst|cnt[15]~54_combout\,
	cout => \counter_inst|cnt[15]~55\);

-- Location: FF_X19_Y3_N3
\counter_inst|cnt[15]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[15]~54_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(15));

-- Location: LCCOMB_X19_Y3_N4
\counter_inst|cnt[16]~56\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[16]~56_combout\ = (\counter_inst|cnt\(16) & (!\counter_inst|cnt[15]~55\)) # (!\counter_inst|cnt\(16) & ((\counter_inst|cnt[15]~55\) # (GND)))
-- \counter_inst|cnt[16]~57\ = CARRY((!\counter_inst|cnt[15]~55\) # (!\counter_inst|cnt\(16)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(16),
	datad => VCC,
	cin => \counter_inst|cnt[15]~55\,
	combout => \counter_inst|cnt[16]~56_combout\,
	cout => \counter_inst|cnt[16]~57\);

-- Location: FF_X19_Y3_N5
\counter_inst|cnt[16]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[16]~56_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(16));

-- Location: LCCOMB_X19_Y3_N6
\counter_inst|cnt[17]~58\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[17]~58_combout\ = (\counter_inst|cnt\(17) & (\counter_inst|cnt[16]~57\ $ (GND))) # (!\counter_inst|cnt\(17) & (!\counter_inst|cnt[16]~57\ & VCC))
-- \counter_inst|cnt[17]~59\ = CARRY((\counter_inst|cnt\(17) & !\counter_inst|cnt[16]~57\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(17),
	datad => VCC,
	cin => \counter_inst|cnt[16]~57\,
	combout => \counter_inst|cnt[17]~58_combout\,
	cout => \counter_inst|cnt[17]~59\);

-- Location: FF_X19_Y3_N7
\counter_inst|cnt[17]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[17]~58_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(17));

-- Location: LCCOMB_X19_Y3_N8
\counter_inst|cnt[18]~60\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[18]~60_combout\ = (\counter_inst|cnt\(18) & (!\counter_inst|cnt[17]~59\)) # (!\counter_inst|cnt\(18) & ((\counter_inst|cnt[17]~59\) # (GND)))
-- \counter_inst|cnt[18]~61\ = CARRY((!\counter_inst|cnt[17]~59\) # (!\counter_inst|cnt\(18)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(18),
	datad => VCC,
	cin => \counter_inst|cnt[17]~59\,
	combout => \counter_inst|cnt[18]~60_combout\,
	cout => \counter_inst|cnt[18]~61\);

-- Location: FF_X19_Y3_N9
\counter_inst|cnt[18]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[18]~60_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(18));

-- Location: LCCOMB_X19_Y3_N10
\counter_inst|cnt[19]~62\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[19]~62_combout\ = (\counter_inst|cnt\(19) & (\counter_inst|cnt[18]~61\ $ (GND))) # (!\counter_inst|cnt\(19) & (!\counter_inst|cnt[18]~61\ & VCC))
-- \counter_inst|cnt[19]~63\ = CARRY((\counter_inst|cnt\(19) & !\counter_inst|cnt[18]~61\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(19),
	datad => VCC,
	cin => \counter_inst|cnt[18]~61\,
	combout => \counter_inst|cnt[19]~62_combout\,
	cout => \counter_inst|cnt[19]~63\);

-- Location: FF_X19_Y3_N11
\counter_inst|cnt[19]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[19]~62_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(19));

-- Location: LCCOMB_X19_Y3_N12
\counter_inst|cnt[20]~64\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[20]~64_combout\ = (\counter_inst|cnt\(20) & (!\counter_inst|cnt[19]~63\)) # (!\counter_inst|cnt\(20) & ((\counter_inst|cnt[19]~63\) # (GND)))
-- \counter_inst|cnt[20]~65\ = CARRY((!\counter_inst|cnt[19]~63\) # (!\counter_inst|cnt\(20)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(20),
	datad => VCC,
	cin => \counter_inst|cnt[19]~63\,
	combout => \counter_inst|cnt[20]~64_combout\,
	cout => \counter_inst|cnt[20]~65\);

-- Location: FF_X19_Y3_N13
\counter_inst|cnt[20]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[20]~64_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(20));

-- Location: LCCOMB_X19_Y3_N14
\counter_inst|cnt[21]~66\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[21]~66_combout\ = (\counter_inst|cnt\(21) & (\counter_inst|cnt[20]~65\ $ (GND))) # (!\counter_inst|cnt\(21) & (!\counter_inst|cnt[20]~65\ & VCC))
-- \counter_inst|cnt[21]~67\ = CARRY((\counter_inst|cnt\(21) & !\counter_inst|cnt[20]~65\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(21),
	datad => VCC,
	cin => \counter_inst|cnt[20]~65\,
	combout => \counter_inst|cnt[21]~66_combout\,
	cout => \counter_inst|cnt[21]~67\);

-- Location: FF_X19_Y3_N15
\counter_inst|cnt[21]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[21]~66_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(21));

-- Location: LCCOMB_X19_Y3_N16
\counter_inst|cnt[22]~68\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[22]~68_combout\ = (\counter_inst|cnt\(22) & (!\counter_inst|cnt[21]~67\)) # (!\counter_inst|cnt\(22) & ((\counter_inst|cnt[21]~67\) # (GND)))
-- \counter_inst|cnt[22]~69\ = CARRY((!\counter_inst|cnt[21]~67\) # (!\counter_inst|cnt\(22)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(22),
	datad => VCC,
	cin => \counter_inst|cnt[21]~67\,
	combout => \counter_inst|cnt[22]~68_combout\,
	cout => \counter_inst|cnt[22]~69\);

-- Location: FF_X19_Y3_N17
\counter_inst|cnt[22]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[22]~68_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(22));

-- Location: LCCOMB_X19_Y3_N18
\counter_inst|cnt[23]~70\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[23]~70_combout\ = (\counter_inst|cnt\(23) & (\counter_inst|cnt[22]~69\ $ (GND))) # (!\counter_inst|cnt\(23) & (!\counter_inst|cnt[22]~69\ & VCC))
-- \counter_inst|cnt[23]~71\ = CARRY((\counter_inst|cnt\(23) & !\counter_inst|cnt[22]~69\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(23),
	datad => VCC,
	cin => \counter_inst|cnt[22]~69\,
	combout => \counter_inst|cnt[23]~70_combout\,
	cout => \counter_inst|cnt[23]~71\);

-- Location: FF_X19_Y3_N19
\counter_inst|cnt[23]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[23]~70_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(23));

-- Location: IOIBUF_X20_Y0_N15
\button~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_button,
	o => \button~input_o\);

-- Location: LCCOMB_X19_Y3_N26
\counter_bus_mux_inst|result[0]~0\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_bus_mux_inst|result[0]~0_combout\ = (\button~input_o\ & ((\counter_inst|cnt\(21)))) # (!\button~input_o\ & (\counter_inst|cnt\(23)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111000011001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(23),
	datac => \counter_inst|cnt\(21),
	datad => \button~input_o\,
	combout => \counter_bus_mux_inst|result[0]~0_combout\);

-- Location: LCCOMB_X19_Y3_N20
\counter_inst|cnt[24]~72\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[24]~72_combout\ = (\counter_inst|cnt\(24) & (!\counter_inst|cnt[23]~71\)) # (!\counter_inst|cnt\(24) & ((\counter_inst|cnt[23]~71\) # (GND)))
-- \counter_inst|cnt[24]~73\ = CARRY((!\counter_inst|cnt[23]~71\) # (!\counter_inst|cnt\(24)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(24),
	datad => VCC,
	cin => \counter_inst|cnt[23]~71\,
	combout => \counter_inst|cnt[24]~72_combout\,
	cout => \counter_inst|cnt[24]~73\);

-- Location: FF_X19_Y3_N21
\counter_inst|cnt[24]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[24]~72_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(24));

-- Location: LCCOMB_X20_Y3_N0
\counter_bus_mux_inst|result[1]~1\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_bus_mux_inst|result[1]~1_combout\ = (\button~input_o\ & ((\counter_inst|cnt\(22)))) # (!\button~input_o\ & (\counter_inst|cnt\(24)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111000011001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(24),
	datac => \counter_inst|cnt\(22),
	datad => \button~input_o\,
	combout => \counter_bus_mux_inst|result[1]~1_combout\);

-- Location: LCCOMB_X19_Y3_N22
\counter_inst|cnt[25]~74\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[25]~74_combout\ = (\counter_inst|cnt\(25) & (\counter_inst|cnt[24]~73\ $ (GND))) # (!\counter_inst|cnt\(25) & (!\counter_inst|cnt[24]~73\ & VCC))
-- \counter_inst|cnt[25]~75\ = CARRY((\counter_inst|cnt\(25) & !\counter_inst|cnt[24]~73\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => \counter_inst|cnt\(25),
	datad => VCC,
	cin => \counter_inst|cnt[24]~73\,
	combout => \counter_inst|cnt[25]~74_combout\,
	cout => \counter_inst|cnt[25]~75\);

-- Location: FF_X19_Y3_N23
\counter_inst|cnt[25]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[25]~74_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(25));

-- Location: LCCOMB_X19_Y3_N28
\counter_bus_mux_inst|result[2]~2\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_bus_mux_inst|result[2]~2_combout\ = (\button~input_o\ & (\counter_inst|cnt\(23))) # (!\button~input_o\ & ((\counter_inst|cnt\(25))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100110011110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \counter_inst|cnt\(23),
	datac => \counter_inst|cnt\(25),
	datad => \button~input_o\,
	combout => \counter_bus_mux_inst|result[2]~2_combout\);

-- Location: LCCOMB_X19_Y3_N24
\counter_inst|cnt[26]~76\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_inst|cnt[26]~76_combout\ = \counter_inst|cnt[25]~75\ $ (\counter_inst|cnt\(26))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111111110000",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datad => \counter_inst|cnt\(26),
	cin => \counter_inst|cnt[25]~75\,
	combout => \counter_inst|cnt[26]~76_combout\);

-- Location: FF_X19_Y3_N25
\counter_inst|cnt[26]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \pll_inst|altpll_component|auto_generated|wire_pll1_clk[0]~clkctrl_outclk\,
	d => \counter_inst|cnt[26]~76_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \counter_inst|cnt\(26));

-- Location: LCCOMB_X19_Y3_N30
\counter_bus_mux_inst|result[3]~3\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \counter_bus_mux_inst|result[3]~3_combout\ = (\button~input_o\ & ((\counter_inst|cnt\(24)))) # (!\button~input_o\ & (\counter_inst|cnt\(26)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110111001000100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \button~input_o\,
	datab => \counter_inst|cnt\(26),
	datad => \counter_inst|cnt\(24),
	combout => \counter_bus_mux_inst|result[3]~3_combout\);

-- Location: UNVM_X0_Y40_N40
\~QUARTUS_CREATED_UNVM~\ : fiftyfivenm_unvm
-- pragma translate_off
GENERIC MAP (
	addr_range1_end_addr => -1,
	addr_range1_offset => -1,
	addr_range2_end_addr => -1,
	addr_range2_offset => -1,
	addr_range3_offset => -1,
	is_compressed_image => "false",
	is_dual_boot => "false",
	is_eram_skip => "false",
	max_ufm_valid_addr => -1,
	max_valid_addr => -1,
	min_ufm_valid_addr => -1,
	min_valid_addr => -1,
	part_name => "quartus_created_unvm",
	reserve_block => "true")
-- pragma translate_on
PORT MAP (
	nosc_ena => \~QUARTUS_CREATED_GND~I_combout\,
	xe_ye => \~QUARTUS_CREATED_GND~I_combout\,
	se => \~QUARTUS_CREATED_GND~I_combout\,
	busy => \~QUARTUS_CREATED_UNVM~~busy\);

-- Location: ADCBLOCK_X43_Y52_N0
\~QUARTUS_CREATED_ADC1~\ : fiftyfivenm_adcblock
-- pragma translate_off
GENERIC MAP (
	analog_input_pin_mask => 0,
	clkdiv => 1,
	device_partname_fivechar_prefix => "none",
	is_this_first_or_second_adc => 1,
	prescalar => 0,
	pwd => 1,
	refsel => 0,
	reserve_block => "true",
	testbits => 66,
	tsclkdiv => 1,
	tsclksel => 0)
-- pragma translate_on
PORT MAP (
	soc => \~QUARTUS_CREATED_GND~I_combout\,
	usr_pwd => VCC,
	tsen => \~QUARTUS_CREATED_GND~I_combout\,
	chsel => \~QUARTUS_CREATED_ADC1~_CHSEL_bus\,
	eoc => \~QUARTUS_CREATED_ADC1~~eoc\);

-- Location: ADCBLOCK_X43_Y51_N0
\~QUARTUS_CREATED_ADC2~\ : fiftyfivenm_adcblock
-- pragma translate_off
GENERIC MAP (
	analog_input_pin_mask => 0,
	clkdiv => 1,
	device_partname_fivechar_prefix => "none",
	is_this_first_or_second_adc => 2,
	prescalar => 0,
	pwd => 1,
	refsel => 0,
	reserve_block => "true",
	testbits => 66,
	tsclkdiv => 1,
	tsclksel => 0)
-- pragma translate_on
PORT MAP (
	soc => \~QUARTUS_CREATED_GND~I_combout\,
	usr_pwd => VCC,
	tsen => \~QUARTUS_CREATED_GND~I_combout\,
	chsel => \~QUARTUS_CREATED_ADC2~_CHSEL_bus\,
	eoc => \~QUARTUS_CREATED_ADC2~~eoc\);
END structure;


