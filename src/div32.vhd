library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity div32 is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           quotient : out STD_LOGIC_VECTOR (31 downto 0);
           remainder : out STD_LOGIC_VECTOR (31 downto 0);
           done : out STD_LOGIC );
end div32;

architecture Behavioral of div32 is

signal a_reg : signed(32 downto 0) := (others => '0'); --se repeta de 32 de ori => 33 de biti
signal b_reg : signed(31 downto 0) := (others => '0');
signal q_reg : signed(31 downto 0) := (others => '0');
signal a_abs, b_abs, q_abs : signed(31 downto 0) := (others => '0');


signal count : integer range 0 to 32 := 0; --numara iteratiile, trebuie 32
signal running : std_logic := '0';


signal signA, signB : std_logic;


begin
process(clk)

variable temp_a : signed(32 downto 0);
variable temp_q : signed(31 downto 0);
variable diff : signed(32 downto 0);
begin
    if rising_edge(clk) then
        if start = '1' and running = '0' then
            --INITIALIZARE
            signA <= a(31);
            signB <= b(31);
            a_reg <= (others => '0');
            b_reg <= abs(signed(b));
            q_reg <= abs(signed(a));
           
            count <= 0;
            done <= '0';
            running <= '1';
            
        elsif running = '1' then
            if count < 32 then
                --shift stanga combinat
                temp_a := shift_left(a_reg, 1);
                temp_a(0) := q_reg(31);
                temp_q := shift_left(q_reg, 1);
                
                --scadere rest <- rest - divizor
                diff := temp_a -  resize(b_reg, 33);
                
                --verifica semnalul rezultat
                if diff(32) = '1' then
                    --rest negativ -> restaurare
                    temp_q(0) := '0';
                    temp_a := temp_a;
                else
                    temp_a := diff;
                    temp_q(0) := '1';
                end if;
                
                a_reg <= temp_a;
                q_reg <= temp_q;
                count <= count +1;
            else
                running <= '0';
                done <= '1';
                
                --ajustare semne
                if(signA xor signB) = '1' then
                    q_abs <= -q_reg;
                else
                    q_abs <= q_reg;
                end if;
                
                if signA = '1' then
                    a_reg <= -a_reg;
                end if;
            end if;
        end if;
    end if;
end process;
quotient <= std_logic_vector(q_abs);
remainder <= std_logic_vector(a_reg(31 downto 0));

end Behavioral;
