library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Alu_8bit is
end tb_Alu_8bit;

architecture Behavioral of tb_Alu_8bit is

    -- Componenta testatã
    component Alu_8bit is
        Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
               b : in STD_LOGIC_VECTOR (7 downto 0);
               cin : in STD_LOGIC;
               op : in STD_LOGIC_VECTOR (3 downto 0);
               result : out STD_LOGIC_VECTOR (7 downto 0);
               cout : out STD_LOGIC);
    end component;

    -- semnale de test
    signal a, b, result : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal cin, cout : STD_LOGIC := '0';
    signal op : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin

    -- Instan?ierea ALU
    uut: Alu_8bit
        port map (
            a => a,
            b => b,
            cin => cin,
            op => op,
            result => result,
            cout => cout
        );

    -- Proces de stimulare (stimulus)
    stim_proc: process
    begin
        -- Test 1: ADD (0000)
        a <= "00000101";  -- 5
        b <= "00000011";  -- 3
        cin <= '0';
        op <= "0000";
        wait for 10 ns;

        -- Test 2: SUB (0001)
        a <= "00001010";  -- 10
        b <= "00000100";  -- 4
        cin <= '1';       -- de obicei pentru 2's complement subtractor
        op <= "0001";
        wait for 10 ns;

        -- Test 3: AND (0010)
        a <= "10101010";
        b <= "11110000";
        op <= "0010";
        wait for 10 ns;

        -- Test 4: OR (0011)
        a <= "10101010";
        b <= "00001111";
        op <= "0011";
        wait for 10 ns;

        -- Test 5: NOT (0111)
        a <= "10101010";
        op <= "0111";
        wait for 10 ns;

        -- Încheie simularea
        wait;
    end process;

end Behavioral;
