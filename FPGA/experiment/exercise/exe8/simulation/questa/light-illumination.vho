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

-- DATE "09/15/2025 13:34:07"

-- 
-- Device: Altera 10M50DAF484C6GES Package FBGA484
-- 

-- 
-- This VHDL file should be used for QuestaSim (VHDL) only
-- 

LIBRARY FIFTYFIVENM;
LIBRARY IEEE;
USE FIFTYFIVENM.FIFTYFIVENM_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	hard_block IS
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic
	);
END hard_block;

-- Design Ports Information
-- ~ALTERA_TMS~	=>  Location: PIN_H2,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TCK~	=>  Location: PIN_G2,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TDI~	=>  Location: PIN_L4,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TDO~	=>  Location: PIN_M5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_CONFIG_SEL~	=>  Location: PIN_H10,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_nCONFIG~	=>  Location: PIN_H9,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_nSTATUS~	=>  Location: PIN_G9,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_CONF_DONE~	=>  Location: PIN_F8,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default


ARCHITECTURE structure OF hard_block IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL \~ALTERA_TMS~~padout\ : std_logic;
SIGNAL \~ALTERA_TCK~~padout\ : std_logic;
SIGNAL \~ALTERA_TDI~~padout\ : std_logic;
SIGNAL \~ALTERA_CONFIG_SEL~~padout\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~padout\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~padout\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~padout\ : std_logic;
SIGNAL \~ALTERA_TMS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TCK~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TDI~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_CONFIG_SEL~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~ibuf_o\ : std_logic;

BEGIN

ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
END structure;


LIBRARY ALTERA;
LIBRARY FIFTYFIVENM;
LIBRARY IEEE;
USE ALTERA.ALTERA_PRIMITIVES_COMPONENTS.ALL;
USE FIFTYFIVENM.FIFTYFIVENM_COMPONENTS.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	light_illumination IS
    PORT (
	clock : IN std_logic;
	reset : IN std_logic;
	counter_out : OUT IEEE.NUMERIC_STD.unsigned(31 DOWNTO 0)
	);
END light_illumination;

-- Design Ports Information
-- counter_out[0]	=>  Location: PIN_J4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[1]	=>  Location: PIN_K6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[2]	=>  Location: PIN_E1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[3]	=>  Location: PIN_K4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[4]	=>  Location: PIN_L9,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[5]	=>  Location: PIN_D2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[6]	=>  Location: PIN_P4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[7]	=>  Location: PIN_K8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[8]	=>  Location: PIN_K5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[9]	=>  Location: PIN_J3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[10]	=>  Location: PIN_D3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[11]	=>  Location: PIN_H4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[12]	=>  Location: PIN_F2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[13]	=>  Location: PIN_K9,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[14]	=>  Location: PIN_H3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[15]	=>  Location: PIN_G3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[16]	=>  Location: PIN_K1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[17]	=>  Location: PIN_D1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[18]	=>  Location: PIN_J8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[19]	=>  Location: PIN_L1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[20]	=>  Location: PIN_M3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[21]	=>  Location: PIN_L2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[22]	=>  Location: PIN_K2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[23]	=>  Location: PIN_G1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[24]	=>  Location: PIN_F1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[25]	=>  Location: PIN_H1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[26]	=>  Location: PIN_N4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[27]	=>  Location: PIN_C1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[28]	=>  Location: PIN_J9,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[29]	=>  Location: PIN_J1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[30]	=>  Location: PIN_M4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- counter_out[31]	=>  Location: PIN_P5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- reset	=>  Location: PIN_L8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- clock	=>  Location: PIN_M8,	 I/O Standard: 2.5 V,	 Current Strength: Default


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
SIGNAL ww_clock : std_logic;
SIGNAL ww_reset : std_logic;
SIGNAL ww_counter_out : std_logic_vector(31 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_ADC1~_CHSEL_bus\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_ADC2~_CHSEL_bus\ : std_logic_vector(4 DOWNTO 0);
SIGNAL \clock~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \~QUARTUS_CREATED_UNVM~~busy\ : std_logic;
SIGNAL \~QUARTUS_CREATED_ADC1~~eoc\ : std_logic;
SIGNAL \~QUARTUS_CREATED_ADC2~~eoc\ : std_logic;
SIGNAL \counter_out[0]~output_o\ : std_logic;
SIGNAL \counter_out[1]~output_o\ : std_logic;
SIGNAL \counter_out[2]~output_o\ : std_logic;
SIGNAL \counter_out[3]~output_o\ : std_logic;
SIGNAL \counter_out[4]~output_o\ : std_logic;
SIGNAL \counter_out[5]~output_o\ : std_logic;
SIGNAL \counter_out[6]~output_o\ : std_logic;
SIGNAL \counter_out[7]~output_o\ : std_logic;
SIGNAL \counter_out[8]~output_o\ : std_logic;
SIGNAL \counter_out[9]~output_o\ : std_logic;
SIGNAL \counter_out[10]~output_o\ : std_logic;
SIGNAL \counter_out[11]~output_o\ : std_logic;
SIGNAL \counter_out[12]~output_o\ : std_logic;
SIGNAL \counter_out[13]~output_o\ : std_logic;
SIGNAL \counter_out[14]~output_o\ : std_logic;
SIGNAL \counter_out[15]~output_o\ : std_logic;
SIGNAL \counter_out[16]~output_o\ : std_logic;
SIGNAL \counter_out[17]~output_o\ : std_logic;
SIGNAL \counter_out[18]~output_o\ : std_logic;
SIGNAL \counter_out[19]~output_o\ : std_logic;
SIGNAL \counter_out[20]~output_o\ : std_logic;
SIGNAL \counter_out[21]~output_o\ : std_logic;
SIGNAL \counter_out[22]~output_o\ : std_logic;
SIGNAL \counter_out[23]~output_o\ : std_logic;
SIGNAL \counter_out[24]~output_o\ : std_logic;
SIGNAL \counter_out[25]~output_o\ : std_logic;
SIGNAL \counter_out[26]~output_o\ : std_logic;
SIGNAL \counter_out[27]~output_o\ : std_logic;
SIGNAL \counter_out[28]~output_o\ : std_logic;
SIGNAL \counter_out[29]~output_o\ : std_logic;
SIGNAL \counter_out[30]~output_o\ : std_logic;
SIGNAL \counter_out[31]~output_o\ : std_logic;
SIGNAL \clock~input_o\ : std_logic;
SIGNAL \clock~inputclkctrl_outclk\ : std_logic;
SIGNAL \reset~input_o\ : std_logic;
SIGNAL \cnt[0]~31_combout\ : std_logic;
SIGNAL \cnt[1]~32_combout\ : std_logic;
SIGNAL \cnt[1]~33\ : std_logic;
SIGNAL \cnt[2]~34_combout\ : std_logic;
SIGNAL \cnt[2]~35\ : std_logic;
SIGNAL \cnt[3]~36_combout\ : std_logic;
SIGNAL \cnt[3]~37\ : std_logic;
SIGNAL \cnt[4]~38_combout\ : std_logic;
SIGNAL \cnt[4]~39\ : std_logic;
SIGNAL \cnt[5]~40_combout\ : std_logic;
SIGNAL \cnt[5]~41\ : std_logic;
SIGNAL \cnt[6]~42_combout\ : std_logic;
SIGNAL \cnt[6]~43\ : std_logic;
SIGNAL \cnt[7]~44_combout\ : std_logic;
SIGNAL \cnt[7]~45\ : std_logic;
SIGNAL \cnt[8]~46_combout\ : std_logic;
SIGNAL \cnt[8]~47\ : std_logic;
SIGNAL \cnt[9]~48_combout\ : std_logic;
SIGNAL \cnt[9]~49\ : std_logic;
SIGNAL \cnt[10]~50_combout\ : std_logic;
SIGNAL \cnt[10]~51\ : std_logic;
SIGNAL \cnt[11]~52_combout\ : std_logic;
SIGNAL \cnt[11]~53\ : std_logic;
SIGNAL \cnt[12]~54_combout\ : std_logic;
SIGNAL \cnt[12]~55\ : std_logic;
SIGNAL \cnt[13]~56_combout\ : std_logic;
SIGNAL \cnt[13]~57\ : std_logic;
SIGNAL \cnt[14]~58_combout\ : std_logic;
SIGNAL \cnt[14]~59\ : std_logic;
SIGNAL \cnt[15]~60_combout\ : std_logic;
SIGNAL \cnt[15]~61\ : std_logic;
SIGNAL \cnt[16]~62_combout\ : std_logic;
SIGNAL \cnt[16]~63\ : std_logic;
SIGNAL \cnt[17]~64_combout\ : std_logic;
SIGNAL \cnt[17]~65\ : std_logic;
SIGNAL \cnt[18]~66_combout\ : std_logic;
SIGNAL \cnt[18]~67\ : std_logic;
SIGNAL \cnt[19]~68_combout\ : std_logic;
SIGNAL \cnt[19]~69\ : std_logic;
SIGNAL \cnt[20]~70_combout\ : std_logic;
SIGNAL \cnt[20]~71\ : std_logic;
SIGNAL \cnt[21]~72_combout\ : std_logic;
SIGNAL \cnt[21]~73\ : std_logic;
SIGNAL \cnt[22]~74_combout\ : std_logic;
SIGNAL \cnt[22]~75\ : std_logic;
SIGNAL \cnt[23]~76_combout\ : std_logic;
SIGNAL \cnt[23]~77\ : std_logic;
SIGNAL \cnt[24]~78_combout\ : std_logic;
SIGNAL \cnt[24]~79\ : std_logic;
SIGNAL \cnt[25]~80_combout\ : std_logic;
SIGNAL \cnt[25]~81\ : std_logic;
SIGNAL \cnt[26]~82_combout\ : std_logic;
SIGNAL \cnt[26]~83\ : std_logic;
SIGNAL \cnt[27]~84_combout\ : std_logic;
SIGNAL \cnt[27]~85\ : std_logic;
SIGNAL \cnt[28]~86_combout\ : std_logic;
SIGNAL \cnt[28]~87\ : std_logic;
SIGNAL \cnt[29]~88_combout\ : std_logic;
SIGNAL \cnt[29]~89\ : std_logic;
SIGNAL \cnt[30]~90_combout\ : std_logic;
SIGNAL \cnt[30]~91\ : std_logic;
SIGNAL \cnt[31]~92_combout\ : std_logic;
SIGNAL cnt : std_logic_vector(31 DOWNTO 0);

COMPONENT hard_block
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic);
END COMPONENT;

BEGIN

ww_clock <= clock;
ww_reset <= reset;
counter_out <= IEEE.NUMERIC_STD.UNSIGNED(ww_counter_out);
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

\~QUARTUS_CREATED_ADC1~_CHSEL_bus\ <= (\~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\);

\~QUARTUS_CREATED_ADC2~_CHSEL_bus\ <= (\~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\ & \~QUARTUS_CREATED_GND~I_combout\);

\clock~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \clock~input_o\);
auto_generated_inst : hard_block
PORT MAP (
	devoe => ww_devoe,
	devclrn => ww_devclrn,
	devpor => ww_devpor);

-- Location: LCCOMB_X44_Y46_N16
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

-- Location: IOOBUF_X0_Y35_N16
\counter_out[0]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(0),
	devoe => ww_devoe,
	o => \counter_out[0]~output_o\);

-- Location: IOOBUF_X0_Y34_N23
\counter_out[1]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(1),
	devoe => ww_devoe,
	o => \counter_out[1]~output_o\);

-- Location: IOOBUF_X0_Y27_N2
\counter_out[2]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(2),
	devoe => ww_devoe,
	o => \counter_out[2]~output_o\);

-- Location: IOOBUF_X0_Y34_N2
\counter_out[3]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(3),
	devoe => ww_devoe,
	o => \counter_out[3]~output_o\);

-- Location: IOOBUF_X0_Y27_N23
\counter_out[4]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(4),
	devoe => ww_devoe,
	o => \counter_out[4]~output_o\);

-- Location: IOOBUF_X0_Y30_N9
\counter_out[5]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(5),
	devoe => ww_devoe,
	o => \counter_out[5]~output_o\);

-- Location: IOOBUF_X0_Y23_N2
\counter_out[6]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(6),
	devoe => ww_devoe,
	o => \counter_out[6]~output_o\);

-- Location: IOOBUF_X0_Y30_N16
\counter_out[7]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(7),
	devoe => ww_devoe,
	o => \counter_out[7]~output_o\);

-- Location: IOOBUF_X0_Y34_N16
\counter_out[8]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(8),
	devoe => ww_devoe,
	o => \counter_out[8]~output_o\);

-- Location: IOOBUF_X0_Y34_N9
\counter_out[9]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(9),
	devoe => ww_devoe,
	o => \counter_out[9]~output_o\);

-- Location: IOOBUF_X0_Y30_N2
\counter_out[10]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(10),
	devoe => ww_devoe,
	o => \counter_out[10]~output_o\);

-- Location: IOOBUF_X0_Y35_N2
\counter_out[11]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(11),
	devoe => ww_devoe,
	o => \counter_out[11]~output_o\);

-- Location: IOOBUF_X0_Y27_N9
\counter_out[12]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(12),
	devoe => ww_devoe,
	o => \counter_out[12]~output_o\);

-- Location: IOOBUF_X0_Y30_N23
\counter_out[13]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(13),
	devoe => ww_devoe,
	o => \counter_out[13]~output_o\);

-- Location: IOOBUF_X0_Y35_N23
\counter_out[14]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(14),
	devoe => ww_devoe,
	o => \counter_out[14]~output_o\);

-- Location: IOOBUF_X0_Y35_N9
\counter_out[15]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(15),
	devoe => ww_devoe,
	o => \counter_out[15]~output_o\);

-- Location: IOOBUF_X0_Y25_N2
\counter_out[16]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(16),
	devoe => ww_devoe,
	o => \counter_out[16]~output_o\);

-- Location: IOOBUF_X0_Y29_N9
\counter_out[17]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(17),
	devoe => ww_devoe,
	o => \counter_out[17]~output_o\);

-- Location: IOOBUF_X0_Y36_N16
\counter_out[18]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(18),
	devoe => ww_devoe,
	o => \counter_out[18]~output_o\);

-- Location: IOOBUF_X0_Y25_N9
\counter_out[19]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(19),
	devoe => ww_devoe,
	o => \counter_out[19]~output_o\);

-- Location: IOOBUF_X0_Y25_N23
\counter_out[20]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(20),
	devoe => ww_devoe,
	o => \counter_out[20]~output_o\);

-- Location: IOOBUF_X0_Y28_N9
\counter_out[21]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(21),
	devoe => ww_devoe,
	o => \counter_out[21]~output_o\);

-- Location: IOOBUF_X0_Y28_N2
\counter_out[22]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(22),
	devoe => ww_devoe,
	o => \counter_out[22]~output_o\);

-- Location: IOOBUF_X0_Y26_N2
\counter_out[23]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(23),
	devoe => ww_devoe,
	o => \counter_out[23]~output_o\);

-- Location: IOOBUF_X0_Y26_N9
\counter_out[24]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(24),
	devoe => ww_devoe,
	o => \counter_out[24]~output_o\);

-- Location: IOOBUF_X0_Y26_N16
\counter_out[25]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(25),
	devoe => ww_devoe,
	o => \counter_out[25]~output_o\);

-- Location: IOOBUF_X0_Y23_N16
\counter_out[26]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(26),
	devoe => ww_devoe,
	o => \counter_out[26]~output_o\);

-- Location: IOOBUF_X0_Y29_N2
\counter_out[27]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(27),
	devoe => ww_devoe,
	o => \counter_out[27]~output_o\);

-- Location: IOOBUF_X0_Y36_N23
\counter_out[28]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(28),
	devoe => ww_devoe,
	o => \counter_out[28]~output_o\);

-- Location: IOOBUF_X0_Y26_N23
\counter_out[29]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(29),
	devoe => ww_devoe,
	o => \counter_out[29]~output_o\);

-- Location: IOOBUF_X0_Y25_N16
\counter_out[30]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(30),
	devoe => ww_devoe,
	o => \counter_out[30]~output_o\);

-- Location: IOOBUF_X0_Y23_N9
\counter_out[31]~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => cnt(31),
	devoe => ww_devoe,
	o => \counter_out[31]~output_o\);

-- Location: IOIBUF_X0_Y18_N15
\clock~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_clock,
	o => \clock~input_o\);

-- Location: CLKCTRL_G3
\clock~inputclkctrl\ : fiftyfivenm_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \clock~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \clock~inputclkctrl_outclk\);

-- Location: IOIBUF_X0_Y27_N15
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

-- Location: LCCOMB_X1_Y30_N0
\cnt[0]~31\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[0]~31_combout\ = \reset~input_o\ $ (cnt(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \reset~input_o\,
	datac => cnt(0),
	combout => \cnt[0]~31_combout\);

-- Location: FF_X1_Y30_N1
\cnt[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[0]~31_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(0));

-- Location: LCCOMB_X1_Y30_N2
\cnt[1]~32\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[1]~32_combout\ = (cnt(0) & (cnt(1) $ (VCC))) # (!cnt(0) & (cnt(1) & VCC))
-- \cnt[1]~33\ = CARRY((cnt(0) & cnt(1)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0110011010001000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => cnt(0),
	datab => cnt(1),
	datad => VCC,
	combout => \cnt[1]~32_combout\,
	cout => \cnt[1]~33\);

-- Location: FF_X1_Y30_N3
\cnt[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[1]~32_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(1));

-- Location: LCCOMB_X1_Y30_N4
\cnt[2]~34\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[2]~34_combout\ = (cnt(2) & (!\cnt[1]~33\)) # (!cnt(2) & ((\cnt[1]~33\) # (GND)))
-- \cnt[2]~35\ = CARRY((!\cnt[1]~33\) # (!cnt(2)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(2),
	datad => VCC,
	cin => \cnt[1]~33\,
	combout => \cnt[2]~34_combout\,
	cout => \cnt[2]~35\);

-- Location: FF_X1_Y30_N5
\cnt[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[2]~34_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(2));

-- Location: LCCOMB_X1_Y30_N6
\cnt[3]~36\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[3]~36_combout\ = (cnt(3) & (\cnt[2]~35\ $ (GND))) # (!cnt(3) & (!\cnt[2]~35\ & VCC))
-- \cnt[3]~37\ = CARRY((cnt(3) & !\cnt[2]~35\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(3),
	datad => VCC,
	cin => \cnt[2]~35\,
	combout => \cnt[3]~36_combout\,
	cout => \cnt[3]~37\);

-- Location: FF_X1_Y30_N7
\cnt[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[3]~36_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(3));

-- Location: LCCOMB_X1_Y30_N8
\cnt[4]~38\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[4]~38_combout\ = (cnt(4) & (!\cnt[3]~37\)) # (!cnt(4) & ((\cnt[3]~37\) # (GND)))
-- \cnt[4]~39\ = CARRY((!\cnt[3]~37\) # (!cnt(4)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(4),
	datad => VCC,
	cin => \cnt[3]~37\,
	combout => \cnt[4]~38_combout\,
	cout => \cnt[4]~39\);

-- Location: FF_X1_Y30_N9
\cnt[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[4]~38_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(4));

-- Location: LCCOMB_X1_Y30_N10
\cnt[5]~40\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[5]~40_combout\ = (cnt(5) & (\cnt[4]~39\ $ (GND))) # (!cnt(5) & (!\cnt[4]~39\ & VCC))
-- \cnt[5]~41\ = CARRY((cnt(5) & !\cnt[4]~39\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(5),
	datad => VCC,
	cin => \cnt[4]~39\,
	combout => \cnt[5]~40_combout\,
	cout => \cnt[5]~41\);

-- Location: FF_X1_Y30_N11
\cnt[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[5]~40_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(5));

-- Location: LCCOMB_X1_Y30_N12
\cnt[6]~42\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[6]~42_combout\ = (cnt(6) & (!\cnt[5]~41\)) # (!cnt(6) & ((\cnt[5]~41\) # (GND)))
-- \cnt[6]~43\ = CARRY((!\cnt[5]~41\) # (!cnt(6)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(6),
	datad => VCC,
	cin => \cnt[5]~41\,
	combout => \cnt[6]~42_combout\,
	cout => \cnt[6]~43\);

-- Location: FF_X1_Y30_N13
\cnt[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[6]~42_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(6));

-- Location: LCCOMB_X1_Y30_N14
\cnt[7]~44\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[7]~44_combout\ = (cnt(7) & (\cnt[6]~43\ $ (GND))) # (!cnt(7) & (!\cnt[6]~43\ & VCC))
-- \cnt[7]~45\ = CARRY((cnt(7) & !\cnt[6]~43\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(7),
	datad => VCC,
	cin => \cnt[6]~43\,
	combout => \cnt[7]~44_combout\,
	cout => \cnt[7]~45\);

-- Location: FF_X1_Y30_N15
\cnt[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[7]~44_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(7));

-- Location: LCCOMB_X1_Y30_N16
\cnt[8]~46\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[8]~46_combout\ = (cnt(8) & (!\cnt[7]~45\)) # (!cnt(8) & ((\cnt[7]~45\) # (GND)))
-- \cnt[8]~47\ = CARRY((!\cnt[7]~45\) # (!cnt(8)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(8),
	datad => VCC,
	cin => \cnt[7]~45\,
	combout => \cnt[8]~46_combout\,
	cout => \cnt[8]~47\);

-- Location: FF_X1_Y30_N17
\cnt[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[8]~46_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(8));

-- Location: LCCOMB_X1_Y30_N18
\cnt[9]~48\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[9]~48_combout\ = (cnt(9) & (\cnt[8]~47\ $ (GND))) # (!cnt(9) & (!\cnt[8]~47\ & VCC))
-- \cnt[9]~49\ = CARRY((cnt(9) & !\cnt[8]~47\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(9),
	datad => VCC,
	cin => \cnt[8]~47\,
	combout => \cnt[9]~48_combout\,
	cout => \cnt[9]~49\);

-- Location: FF_X1_Y30_N19
\cnt[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[9]~48_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(9));

-- Location: LCCOMB_X1_Y30_N20
\cnt[10]~50\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[10]~50_combout\ = (cnt(10) & (!\cnt[9]~49\)) # (!cnt(10) & ((\cnt[9]~49\) # (GND)))
-- \cnt[10]~51\ = CARRY((!\cnt[9]~49\) # (!cnt(10)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(10),
	datad => VCC,
	cin => \cnt[9]~49\,
	combout => \cnt[10]~50_combout\,
	cout => \cnt[10]~51\);

-- Location: FF_X1_Y30_N21
\cnt[10]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[10]~50_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(10));

-- Location: LCCOMB_X1_Y30_N22
\cnt[11]~52\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[11]~52_combout\ = (cnt(11) & (\cnt[10]~51\ $ (GND))) # (!cnt(11) & (!\cnt[10]~51\ & VCC))
-- \cnt[11]~53\ = CARRY((cnt(11) & !\cnt[10]~51\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(11),
	datad => VCC,
	cin => \cnt[10]~51\,
	combout => \cnt[11]~52_combout\,
	cout => \cnt[11]~53\);

-- Location: FF_X1_Y30_N23
\cnt[11]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[11]~52_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(11));

-- Location: LCCOMB_X1_Y30_N24
\cnt[12]~54\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[12]~54_combout\ = (cnt(12) & (!\cnt[11]~53\)) # (!cnt(12) & ((\cnt[11]~53\) # (GND)))
-- \cnt[12]~55\ = CARRY((!\cnt[11]~53\) # (!cnt(12)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(12),
	datad => VCC,
	cin => \cnt[11]~53\,
	combout => \cnt[12]~54_combout\,
	cout => \cnt[12]~55\);

-- Location: FF_X1_Y30_N25
\cnt[12]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[12]~54_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(12));

-- Location: LCCOMB_X1_Y30_N26
\cnt[13]~56\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[13]~56_combout\ = (cnt(13) & (\cnt[12]~55\ $ (GND))) # (!cnt(13) & (!\cnt[12]~55\ & VCC))
-- \cnt[13]~57\ = CARRY((cnt(13) & !\cnt[12]~55\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(13),
	datad => VCC,
	cin => \cnt[12]~55\,
	combout => \cnt[13]~56_combout\,
	cout => \cnt[13]~57\);

-- Location: FF_X1_Y30_N27
\cnt[13]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[13]~56_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(13));

-- Location: LCCOMB_X1_Y30_N28
\cnt[14]~58\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[14]~58_combout\ = (cnt(14) & (!\cnt[13]~57\)) # (!cnt(14) & ((\cnt[13]~57\) # (GND)))
-- \cnt[14]~59\ = CARRY((!\cnt[13]~57\) # (!cnt(14)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(14),
	datad => VCC,
	cin => \cnt[13]~57\,
	combout => \cnt[14]~58_combout\,
	cout => \cnt[14]~59\);

-- Location: FF_X1_Y30_N29
\cnt[14]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[14]~58_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(14));

-- Location: LCCOMB_X1_Y30_N30
\cnt[15]~60\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[15]~60_combout\ = (cnt(15) & (\cnt[14]~59\ $ (GND))) # (!cnt(15) & (!\cnt[14]~59\ & VCC))
-- \cnt[15]~61\ = CARRY((cnt(15) & !\cnt[14]~59\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(15),
	datad => VCC,
	cin => \cnt[14]~59\,
	combout => \cnt[15]~60_combout\,
	cout => \cnt[15]~61\);

-- Location: FF_X1_Y30_N31
\cnt[15]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[15]~60_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(15));

-- Location: LCCOMB_X1_Y29_N0
\cnt[16]~62\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[16]~62_combout\ = (cnt(16) & (!\cnt[15]~61\)) # (!cnt(16) & ((\cnt[15]~61\) # (GND)))
-- \cnt[16]~63\ = CARRY((!\cnt[15]~61\) # (!cnt(16)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(16),
	datad => VCC,
	cin => \cnt[15]~61\,
	combout => \cnt[16]~62_combout\,
	cout => \cnt[16]~63\);

-- Location: FF_X1_Y29_N1
\cnt[16]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[16]~62_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(16));

-- Location: LCCOMB_X1_Y29_N2
\cnt[17]~64\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[17]~64_combout\ = (cnt(17) & (\cnt[16]~63\ $ (GND))) # (!cnt(17) & (!\cnt[16]~63\ & VCC))
-- \cnt[17]~65\ = CARRY((cnt(17) & !\cnt[16]~63\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(17),
	datad => VCC,
	cin => \cnt[16]~63\,
	combout => \cnt[17]~64_combout\,
	cout => \cnt[17]~65\);

-- Location: FF_X1_Y29_N3
\cnt[17]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[17]~64_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(17));

-- Location: LCCOMB_X1_Y29_N4
\cnt[18]~66\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[18]~66_combout\ = (cnt(18) & (!\cnt[17]~65\)) # (!cnt(18) & ((\cnt[17]~65\) # (GND)))
-- \cnt[18]~67\ = CARRY((!\cnt[17]~65\) # (!cnt(18)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(18),
	datad => VCC,
	cin => \cnt[17]~65\,
	combout => \cnt[18]~66_combout\,
	cout => \cnt[18]~67\);

-- Location: FF_X1_Y29_N5
\cnt[18]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[18]~66_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(18));

-- Location: LCCOMB_X1_Y29_N6
\cnt[19]~68\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[19]~68_combout\ = (cnt(19) & (\cnt[18]~67\ $ (GND))) # (!cnt(19) & (!\cnt[18]~67\ & VCC))
-- \cnt[19]~69\ = CARRY((cnt(19) & !\cnt[18]~67\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(19),
	datad => VCC,
	cin => \cnt[18]~67\,
	combout => \cnt[19]~68_combout\,
	cout => \cnt[19]~69\);

-- Location: FF_X1_Y29_N7
\cnt[19]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[19]~68_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(19));

-- Location: LCCOMB_X1_Y29_N8
\cnt[20]~70\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[20]~70_combout\ = (cnt(20) & (!\cnt[19]~69\)) # (!cnt(20) & ((\cnt[19]~69\) # (GND)))
-- \cnt[20]~71\ = CARRY((!\cnt[19]~69\) # (!cnt(20)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(20),
	datad => VCC,
	cin => \cnt[19]~69\,
	combout => \cnt[20]~70_combout\,
	cout => \cnt[20]~71\);

-- Location: FF_X1_Y29_N9
\cnt[20]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[20]~70_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(20));

-- Location: LCCOMB_X1_Y29_N10
\cnt[21]~72\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[21]~72_combout\ = (cnt(21) & (\cnt[20]~71\ $ (GND))) # (!cnt(21) & (!\cnt[20]~71\ & VCC))
-- \cnt[21]~73\ = CARRY((cnt(21) & !\cnt[20]~71\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(21),
	datad => VCC,
	cin => \cnt[20]~71\,
	combout => \cnt[21]~72_combout\,
	cout => \cnt[21]~73\);

-- Location: FF_X1_Y29_N11
\cnt[21]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[21]~72_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(21));

-- Location: LCCOMB_X1_Y29_N12
\cnt[22]~74\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[22]~74_combout\ = (cnt(22) & (!\cnt[21]~73\)) # (!cnt(22) & ((\cnt[21]~73\) # (GND)))
-- \cnt[22]~75\ = CARRY((!\cnt[21]~73\) # (!cnt(22)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(22),
	datad => VCC,
	cin => \cnt[21]~73\,
	combout => \cnt[22]~74_combout\,
	cout => \cnt[22]~75\);

-- Location: FF_X1_Y29_N13
\cnt[22]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[22]~74_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(22));

-- Location: LCCOMB_X1_Y29_N14
\cnt[23]~76\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[23]~76_combout\ = (cnt(23) & (\cnt[22]~75\ $ (GND))) # (!cnt(23) & (!\cnt[22]~75\ & VCC))
-- \cnt[23]~77\ = CARRY((cnt(23) & !\cnt[22]~75\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(23),
	datad => VCC,
	cin => \cnt[22]~75\,
	combout => \cnt[23]~76_combout\,
	cout => \cnt[23]~77\);

-- Location: FF_X1_Y29_N15
\cnt[23]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[23]~76_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(23));

-- Location: LCCOMB_X1_Y29_N16
\cnt[24]~78\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[24]~78_combout\ = (cnt(24) & (!\cnt[23]~77\)) # (!cnt(24) & ((\cnt[23]~77\) # (GND)))
-- \cnt[24]~79\ = CARRY((!\cnt[23]~77\) # (!cnt(24)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(24),
	datad => VCC,
	cin => \cnt[23]~77\,
	combout => \cnt[24]~78_combout\,
	cout => \cnt[24]~79\);

-- Location: FF_X1_Y29_N17
\cnt[24]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[24]~78_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(24));

-- Location: LCCOMB_X1_Y29_N18
\cnt[25]~80\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[25]~80_combout\ = (cnt(25) & (\cnt[24]~79\ $ (GND))) # (!cnt(25) & (!\cnt[24]~79\ & VCC))
-- \cnt[25]~81\ = CARRY((cnt(25) & !\cnt[24]~79\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100001100",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(25),
	datad => VCC,
	cin => \cnt[24]~79\,
	combout => \cnt[25]~80_combout\,
	cout => \cnt[25]~81\);

-- Location: FF_X1_Y29_N19
\cnt[25]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[25]~80_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(25));

-- Location: LCCOMB_X1_Y29_N20
\cnt[26]~82\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[26]~82_combout\ = (cnt(26) & (!\cnt[25]~81\)) # (!cnt(26) & ((\cnt[25]~81\) # (GND)))
-- \cnt[26]~83\ = CARRY((!\cnt[25]~81\) # (!cnt(26)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(26),
	datad => VCC,
	cin => \cnt[25]~81\,
	combout => \cnt[26]~82_combout\,
	cout => \cnt[26]~83\);

-- Location: FF_X1_Y29_N21
\cnt[26]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[26]~82_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(26));

-- Location: LCCOMB_X1_Y29_N22
\cnt[27]~84\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[27]~84_combout\ = (cnt(27) & (\cnt[26]~83\ $ (GND))) # (!cnt(27) & (!\cnt[26]~83\ & VCC))
-- \cnt[27]~85\ = CARRY((cnt(27) & !\cnt[26]~83\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(27),
	datad => VCC,
	cin => \cnt[26]~83\,
	combout => \cnt[27]~84_combout\,
	cout => \cnt[27]~85\);

-- Location: FF_X1_Y29_N23
\cnt[27]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[27]~84_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(27));

-- Location: LCCOMB_X1_Y29_N24
\cnt[28]~86\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[28]~86_combout\ = (cnt(28) & (!\cnt[27]~85\)) # (!cnt(28) & ((\cnt[27]~85\) # (GND)))
-- \cnt[28]~87\ = CARRY((!\cnt[27]~85\) # (!cnt(28)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(28),
	datad => VCC,
	cin => \cnt[27]~85\,
	combout => \cnt[28]~86_combout\,
	cout => \cnt[28]~87\);

-- Location: FF_X1_Y29_N25
\cnt[28]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[28]~86_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(28));

-- Location: LCCOMB_X1_Y29_N26
\cnt[29]~88\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[29]~88_combout\ = (cnt(29) & (\cnt[28]~87\ $ (GND))) # (!cnt(29) & (!\cnt[28]~87\ & VCC))
-- \cnt[29]~89\ = CARRY((cnt(29) & !\cnt[28]~87\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010100001010",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(29),
	datad => VCC,
	cin => \cnt[28]~87\,
	combout => \cnt[29]~88_combout\,
	cout => \cnt[29]~89\);

-- Location: FF_X1_Y29_N27
\cnt[29]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[29]~88_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(29));

-- Location: LCCOMB_X1_Y29_N28
\cnt[30]~90\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[30]~90_combout\ = (cnt(30) & (!\cnt[29]~89\)) # (!cnt(30) & ((\cnt[29]~89\) # (GND)))
-- \cnt[30]~91\ = CARRY((!\cnt[29]~89\) # (!cnt(30)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000111111",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	datab => cnt(30),
	datad => VCC,
	cin => \cnt[29]~89\,
	combout => \cnt[30]~90_combout\,
	cout => \cnt[30]~91\);

-- Location: FF_X1_Y29_N29
\cnt[30]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[30]~90_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(30));

-- Location: LCCOMB_X1_Y29_N30
\cnt[31]~92\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \cnt[31]~92_combout\ = cnt(31) $ (!\cnt[30]~91\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010010110100101",
	sum_lutc_input => "cin")
-- pragma translate_on
PORT MAP (
	dataa => cnt(31),
	cin => \cnt[30]~91\,
	combout => \cnt[31]~92_combout\);

-- Location: FF_X1_Y29_N31
\cnt[31]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clock~inputclkctrl_outclk\,
	d => \cnt[31]~92_combout\,
	ena => \reset~input_o\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => cnt(31));

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

ww_counter_out(0) <= \counter_out[0]~output_o\;

ww_counter_out(1) <= \counter_out[1]~output_o\;

ww_counter_out(2) <= \counter_out[2]~output_o\;

ww_counter_out(3) <= \counter_out[3]~output_o\;

ww_counter_out(4) <= \counter_out[4]~output_o\;

ww_counter_out(5) <= \counter_out[5]~output_o\;

ww_counter_out(6) <= \counter_out[6]~output_o\;

ww_counter_out(7) <= \counter_out[7]~output_o\;

ww_counter_out(8) <= \counter_out[8]~output_o\;

ww_counter_out(9) <= \counter_out[9]~output_o\;

ww_counter_out(10) <= \counter_out[10]~output_o\;

ww_counter_out(11) <= \counter_out[11]~output_o\;

ww_counter_out(12) <= \counter_out[12]~output_o\;

ww_counter_out(13) <= \counter_out[13]~output_o\;

ww_counter_out(14) <= \counter_out[14]~output_o\;

ww_counter_out(15) <= \counter_out[15]~output_o\;

ww_counter_out(16) <= \counter_out[16]~output_o\;

ww_counter_out(17) <= \counter_out[17]~output_o\;

ww_counter_out(18) <= \counter_out[18]~output_o\;

ww_counter_out(19) <= \counter_out[19]~output_o\;

ww_counter_out(20) <= \counter_out[20]~output_o\;

ww_counter_out(21) <= \counter_out[21]~output_o\;

ww_counter_out(22) <= \counter_out[22]~output_o\;

ww_counter_out(23) <= \counter_out[23]~output_o\;

ww_counter_out(24) <= \counter_out[24]~output_o\;

ww_counter_out(25) <= \counter_out[25]~output_o\;

ww_counter_out(26) <= \counter_out[26]~output_o\;

ww_counter_out(27) <= \counter_out[27]~output_o\;

ww_counter_out(28) <= \counter_out[28]~output_o\;

ww_counter_out(29) <= \counter_out[29]~output_o\;

ww_counter_out(30) <= \counter_out[30]~output_o\;

ww_counter_out(31) <= \counter_out[31]~output_o\;
END structure;


