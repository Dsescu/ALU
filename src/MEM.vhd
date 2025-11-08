library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (3 downto 0);
           instr : out STD_LOGIC_VECTOR (67 downto 0));
end MEM;

architecture Behavioral of MEM is

type rom_type is array (0 to 15) of std_logic_vector(67 downto 0);
signal rom : rom_type := (
     0 => "0000" & X"00000005" & X"00000003", -- add ; 00000005 + 00000003 = 00000008
     1 => "0001" & X"00000009" & X"00000002", -- sub ; 00000009 - 00000002 = 00000007
     2 => "0010" & X"FFFFFFFF" & X"00000001", -- and ; FFFFFFFF && 00000001 = 00000001
     3 => "0011" & X"0000000F" & X"00000001", -- or ; 0000000F || 00000001 = 0000000f
     4 => "0100" & X"0000000F" & X"00000003", -- not ; ~0000000F = FFFFFFF0
     5 => "0101" & X"FFFFFFF0" & X"00000000", -- neg ; FFFFFFF0 => 00000010
     6 => "0110" & X"0000000A" & X"00000000", -- inc ; 0000000A++ = 0000000B
     7 => "0111" & X"0000000A" & X"00000000", -- dec ; 0000000A-- = 00000009
     8 => "1000" & X"00000001" & X"00000000", -- rol ; rol 00000001 = 00000002
     9 => "1001" & X"00000001" & X"00000000", -- ror ; ror 00000001 = 80000000
    10 => "1010" & X"00000006" & X"00000007", -- mul ; 00000006 * 00000007 = 0000002A
    11 => "1011" & X"00000021" & X"FFFFFFFE", -- div ; 00000021 / FFFFFFFE = FFFFFFF0, 00000001
    12 => "1010" & X"00000006" & X"FFFFFFFE", -- mul cu operand negativ ; 00000006 * FFFFFFFE = FFFFFFFF FFFFFFF4
    13 => "0000" & X"7FFFFFFF" & X"00000001", -- overflow
    14 => "1011" & X"23000000" & X"00000000", --divByZero
    15 => "1111" & X"12345678" & X"98765432"  --illigalOp
    );
begin
process(clk)
begin
    if rising_edge(clk) then
        instr <= rom(to_integer(unsigned(addr)));
    end if;
end process;

end Behavioral;
