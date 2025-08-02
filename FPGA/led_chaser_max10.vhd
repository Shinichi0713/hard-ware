-- LED Chaser using MAX10 Internal PLL
-- Target: MAX10 FPGA
-- Description: Uses internal PLL to generate slower clock for LED chasing pattern

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_chaser_max10 is
    Port (
        clk_50mhz    : in  STD_LOGIC;                    -- 50MHz input clock
        reset_n      : in  STD_LOGIC;                    -- Active low reset
        led_out      : out STD_LOGIC_VECTOR(7 downto 0) -- 8 LEDs output
    );
end led_chaser_max10;

architecture Behavioral of led_chaser_max10 is

    -- PLL component declaration
    component pll_led_chaser
        port (
            refclk   : in  std_logic;
            rst      : in  std_logic;
            outclk_0 : out std_logic;  -- 1MHz output clock
            locked   : out std_logic
        );
    end component;

    -- Internal signals
    signal clk_1mhz     : STD_LOGIC;                    -- 1MHz clock from PLL
    signal pll_locked   : STD_LOGIC;                    -- PLL lock status
    signal reset        : STD_LOGIC;                    -- Active high reset
    signal system_reset : STD_LOGIC;                    -- System reset (until PLL locked)
    
    -- LED chaser signals
    signal led_counter  : unsigned(19 downto 0) := (others => '0'); -- Counter for timing
    signal led_position : unsigned(2 downto 0) := (others => '0');  -- LED position (0-7)
    signal led_enable   : STD_LOGIC;                    -- LED update enable
    
    -- Constants
    constant COUNT_MAX  : unsigned(19 downto 0) := to_unsigned(1000000-1, 20); -- 1 second at 1MHz

begin

    -- Reset logic
    reset <= not reset_n;
    system_reset <= reset or (not pll_locked);

    -- PLL instantiation
    pll_inst : pll_led_chaser
        port map (
            refclk   => clk_50mhz,
            rst      => reset,
            outclk_0 => clk_1mhz,
            locked   => pll_locked
        );

    -- Counter process for timing control
    timing_counter_proc : process(clk_1mhz, system_reset)
    begin
        if system_reset = '1' then
            led_counter <= (others => '0');
            led_enable <= '0';
        elsif rising_edge(clk_1mhz) then
            if led_counter = COUNT_MAX then
                led_counter <= (others => '0');
                led_enable <= '1';
            else
                led_counter <= led_counter + 1;
                led_enable <= '0';
            end if;
        end if;
    end process;

    -- LED position control process
    led_position_proc : process(clk_1mhz, system_reset)
    begin
        if system_reset = '1' then
            led_position <= (others => '0');
        elsif rising_edge(clk_1mhz) then
            if led_enable = '1' then
                if led_position = 7 then
                    led_position <= (others => '0');
                else
                    led_position <= led_position + 1;
                end if;
            end if;
        end if;
    end process;

    -- LED output decoder process
    led_decoder_proc : process(led_position)
    begin
        led_out <= (others => '0'); -- Default all LEDs off
        
        case to_integer(led_position) is
            when 0 => led_out(0) <= '1';
            when 1 => led_out(1) <= '1';
            when 2 => led_out(2) <= '1';
            when 3 => led_out(3) <= '1';
            when 4 => led_out(4) <= '1';
            when 5 => led_out(5) <= '1';
            when 6 => led_out(6) <= '1';
            when 7 => led_out(7) <= '1';
            when others => led_out <= (others => '0');
        end case;
    end process;

end Behavioral;
