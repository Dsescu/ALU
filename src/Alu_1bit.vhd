library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Alu_1bit is
    Port ( a : in STD_LOGIC;
           b : in STD_LOGIC; 
           cin : in STD_LOGIC; 
           sub : in STD_LOGIC; 
           neg : in STD_LOGIC; 
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC;
           cout : out STD_LOGIC);
end Alu_1bit;

architecture Behavioral of Alu_1bit is

signal temp_carry : std_logic;
signal a_new : std_logic;
signal b_new : std_logic;
signal sum_bit : std_logic;
signal res : std_logic;

begin
a_new <= a xor neg; 
b_new <= b xor sub; 

sum_bit <= a_new xor b_new xor cin;
temp_carry <= (a_new and b_new) or (a_new and cin) or (b_new and cin);

process(op, b, a, cin, sum_bit, b_new, a_new)
begin
    res <= '0';
    
    case op is
        when "0000" | "0001" | "0101" | "0110" | "0111"  => --add | sub | negare | increment | decrement
            res <= sum_bit;
        when "0010" => --and
            res <= a and b;
        when "0011" =>  --or
            res <= a or b;
        when "0100" => --not
            res <= not a;
    
        when others => res <= '0';
     end case;
end process;
result <= res;
cout <= temp_carry;
end Behavioral;
