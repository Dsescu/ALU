library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rotate_left_32 is
    Port ( din : in STD_LOGIC_VECTOR (31 downto 0);
           dout : out STD_LOGIC_VECTOR (31 downto 0));
end rotate_left_32;

architecture Behavioral of rotate_left_32 is

begin

gen_ror : for i in 0 to 31 generate
    dout(i) <= din(i - 1) when i > 0 else din(31);
end generate;

end Behavioral;
