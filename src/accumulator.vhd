library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity accumulator is
    Port ( clk : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (31 downto 0);
           a_out : out STD_LOGIC_VECTOR (31 downto 0);
           load : in STD_LOGIC);
end accumulator;

architecture Behavioral of accumulator is
signal regA : std_logic_vector(31 downto 0) := (others => '0');
begin
process(clk)
begin
    if rising_edge(clk) then
        if load = '1' then
            regA <= data;
        end if;
    end if;
end process;
a_out <= regA;


end Behavioral;
