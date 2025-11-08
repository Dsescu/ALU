library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Alu_32bit is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           cin : in STD_LOGIC;
           sub : in STD_LOGIC;
           neg : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0);
           overFlow : out STD_LOGIC);
end Alu_32bit;

architecture Behavioral of Alu_32bit is

signal carry : std_logic_vector(4 downto 0);
signal alu_out : std_logic_vector(31 downto 0);
signal rotate_l : std_logic_vector(31 downto 0);
signal rotate_r : std_logic_vector(31 downto 0);
signal res : std_logic_vector(31 downto 0);

component Alu_8bit is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           sub : in STD_LOGIC;
           neg : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end component;

component rotate_right_32 is
    Port ( din : in STD_LOGIC_VECTOR (31 downto 0);
           dout : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component rotate_left_32 is
    Port ( din : in STD_LOGIC_VECTOR (31 downto 0);
           dout : out STD_LOGIC_VECTOR (31 downto 0));
end component;
begin
carry(0) <= cin;
 
 --Instante Alu_8bit
alu0: ALU_8bit port map(
    a => a(7 downto 0),
    b => b(7 downto 0),
    cin => carry(0),
    sub => sub,
    neg => neg,
    op => op,
    result => alu_out(7 downto 0),
    cout => carry(1));
    
alu1: ALU_8bit port map(
    a => a(15 downto 8),
    b => b(15 downto 8),
    cin => carry(1),
    sub => sub,
    neg => neg,
    op => op,
    result => alu_out(15 downto 8),
    cout => carry(2));
    
alu2: ALU_8bit port map(
    a => a(23 downto 16),
    b => b(23 downto 16),
    cin => carry(2),
    sub => sub,
    neg => neg,
    op => op,
    result => alu_out(23 downto 16),
    cout => carry(3));
    
alu3: ALU_8bit port map(
    a => a(31 downto 24),
    b => b(31 downto 24),
    cin => carry(3),
    sub => sub,
    neg => neg,
    op => op,
    result => alu_out(31 downto 24),
    cout => carry(4)); 
    
r1: rotate_left_32 port map( 
    din => a,
    dout => rotate_l);
    
r2: rotate_right_32 port map(
    din => a,
    dout => rotate_r);    
process(a,b,op,alu_out, rotate_l, rotate_r)
begin
    case op is
        when "1000" => --rotate left
            res <= rotate_l;
        when "1001" => --rotate right
            res <= rotate_r;
        when others => 
            res <= alu_out;
    end case;
end process;

--flaguri
process(a, b, res, op)
begin
    overFlow <= '0';
    case op is
        when "0000" | "0110"  => --add|inc
            overflow <= (a(31) and b(31) and ( not res(31) )) or ((not a(31)) and (not b(31)) and res(31));
        when "0001" | "0111"  => --sub|dec
            overflow <= (a(31) and (not b(31)) and ( not res(31) )) or ((not a(31)) and b(31) and res(31));
        when others =>
            overFlow <= '0';
    end case;
end process;
result <= res;
end Behavioral;
