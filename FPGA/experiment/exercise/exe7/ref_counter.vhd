library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        en  : in  STD_LOGIC;
        q   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end counter;

architecture Behavioral of counter is
    signal count : unsigned(3 downto 0) := (others => '0');
begin

process(clk, rst)
begin
    if rst = '1' then
        count <= (others => '0');
    elsif rising_edge(clk) then
        if en = '1' then
            count <= count + 1;
        end if;
    end if;
end process;

q <= std_logic_vector(count);

end Behavioral;
