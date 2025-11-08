library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
    Port ( a : in signed (31 downto 0);
           b : in signed (31 downto 0);
           p : out signed (63 downto 0));
end multiplier;

architecture Behavioral of multiplier is
--matrice de produse partiale
type matrix32 is array (0 to 31) of signed(31 downto 0);
signal pp : matrix32;

--vectorii shiftati si partiali
type vec64 is array (0 to 31) of signed(63 downto 0);
signal shifted : vec64;

--sume intermediare
signal sums : vec64;
signal c : std_logic;

signal a_abs, b_abs : signed(31 downto 0);
signal p_abs : signed(63 downto 0);
signal result_sign : std_logic;
begin

--DETERMINARE SEMN REZULTAT
result_sign <= a(31) xor b(31);

--OBTINEREA VALORILOR ABSOLUTE ALE OPERANZILOR
a_abs <= -a when a(31) = '1' else a;
b_abs <= -b when b(31) = '1' else b;


--GENERARE PRODUSE PARTIALE
gen_rows : for i in 0 to 31 generate
    gen_cols : for j in 0 to 31 generate
        and_g : entity work.and_cell
            port map (
                a => a_abs(j),
                b => b_abs(i),
                y => pp(i)(j)
            );
    end generate;
end generate;

--SHIFTARE FIECARE LINIE IN POZITIA CORECTA
gen_shift : for i in 0 to 31 generate
    shifted(i) <= shift_left(resize(pp(i), 64), i);
end generate;

--ADUNAREA STRUCTURALA A LINIILOR
---prima linie
sums(0) <= shifted(0);

--urmatoarele: adunam in lant toate cele 32 de randuri
gen_adders : for i in 1 to 31 generate
    add_stage : entity work.ripple_adder
        generic map(n => 64)
        port map(
            a => sums(i-1),
            b => shifted(i),
            sum => sums(i),
            cin => '0',
            cout => c
        );
end generate;

--REZULTATUL FINAL
p_abs <= sums(31);

--APLICARE SEMN LA REZULTAT
p <= -p_abs when result_sign = '1' else p_abs;

end Behavioral;
