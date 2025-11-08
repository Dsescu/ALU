library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ripple_adder is
    generic (n : integer := 32);
    Port ( a : in signed (n-1 downto 0);
           b : in signed (n-1 downto 0);
           sum : out signed (n-1 downto 0);
           cin : in STD_LOGIC ;
           cout : out STD_LOGIC);
end ripple_adder;

architecture Behavioral of ripple_adder is
signal c : std_logic_vector(n downto 0);
signal s : signed(n-1 downto 0); 
begin
c(0) <= cin;
gen_adders : for i in 0 to n-1 generate
    fa: entity work.full_adder 
        port map(
            a => a(i),
            b => b(i),
            cin => c(i),
            sum => s(i),
            cout => c(i+1)
        );
    end generate;
cout <= c(n);
sum <= s;
    
end Behavioral;
