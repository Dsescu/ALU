library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Alu_8bit is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           sub : in STD_LOGIC;
           neg : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end Alu_8bit;

architecture Behavioral of Alu_8bit is
 
signal carry : std_logic_vector(8 downto 0);

component Alu_1bit is
   Port ( a : in STD_LOGIC;
           b : in STD_LOGIC; 
           cin : in STD_LOGIC; 
           sub : in STD_LOGIC;
           neg : in STD_LOGIC; 
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC;
           cout : out STD_LOGIC);
end component;

begin

carry(0) <= cin; 

gen_alu : for i in 0 to 7 generate
    u : Alu_1bit port map(
        a => a(i),
        b => b(i),
        cin => carry(i),
        sub => sub,
        neg => neg,
        op => op,
        result => result(i),
        cout => carry(i + 1) );
    end generate;
cout <= carry(8);

end Behavioral;
