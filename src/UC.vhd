library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UC is
    Port ( instr : in STD_LOGIC_VECTOR (67 downto 0);
           op_code : out STD_LOGIC_VECTOR (3 downto 0);
           a : out STD_LOGIC_VECTOR (31 downto 0);
           b : out STD_LOGIC_VECTOR (31 downto 0);
           cin : out STD_LOGIC;
           sub : out STD_LOGIC;
           neg : out STD_LOGIC);
end UC;

architecture Behavioral of UC is
signal op : std_logic_vector(3 downto 0) := "0000";
signal a_reg, b_reg : std_logic_vector(31 downto 0) := (others => '0');
signal cin_reg, sub_reg, neg_reg : std_logic;
signal b_instr : std_logic := '0';
begin
op <= instr(67 downto 64);
a_reg <= instr(63 downto 32);
b_reg <= instr(31 downto 0);

process(op)
begin
     cin_reg <= '0';
     sub_reg <= '0';
     neg_reg <= '0';
     b_instr <= '0';
    case op is
        when "0000" => --add
            null;
        when "0001" => --sub
            cin_reg <= '1';
            sub_reg <= '1';
        when "0010" | "0011" | "0100" => --and | not | or
           null;
        when "0101" => --negare
            neg_reg <= '1';
            b_instr <= '1';
        when "0110" => --increment
            b_instr <= '1';
        when "0111" => --decrement
            cin_reg <= '1'; --pentru neg b + 1
            sub_reg <= '1';
            b_instr <= '1';
        when "1000" | "1001" => --rol | ror
            null;
        when others =>
            null;
    end case;
end process;
a <= a_reg;
b <= X"00000001" when b_instr = '1' else b_reg;
cin <= cin_reg;
op_code <= op;
sub <= sub_reg;
neg <= neg_reg;

end Behavioral;
