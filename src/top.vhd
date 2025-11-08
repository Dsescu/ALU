library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( clk : in STD_LOGIC;
           btn_next : in STD_LOGIC;
           btn_load : in STD_LOGIC;
           btn_rst : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(3 downto 0); 
           ledOver : out STD_LOGIC;
           ledIlligalOp : out STD_LOGIC;
           ledDivByZero : out STD_LOGIC;
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end top;

architecture Behavioral of top is
--COMPONENTE
component MEM is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (3 downto 0);
           instr : out STD_LOGIC_VECTOR (67 downto 0));
end component;

component UC is
    Port ( instr : in STD_LOGIC_VECTOR (67 downto 0);
           op_code : out STD_LOGIC_VECTOR (3 downto 0);
           a : out STD_LOGIC_VECTOR (31 downto 0);
           b : out STD_LOGIC_VECTOR (31 downto 0);
           cin : out STD_LOGIC;
           sub : out STD_LOGIC;
           neg : out STD_LOGIC);
end component;

component Alu_32bit is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           cin : in STD_LOGIC;
           sub : in STD_LOGIC;
           neg : in STD_LOGIC;
           op : in STD_LOGIC_VECTOR (3 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0);
           overFlow : out STD_LOGIC);
end component;

component multiplier is
    Port ( a : in signed (31 downto 0);
           b : in signed (31 downto 0);
           p : out signed (63 downto 0));
end component;

component div32 is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           quotient : out STD_LOGIC_VECTOR (31 downto 0);
           remainder : out STD_LOGIC_VECTOR (31 downto 0);
           done : out STD_LOGIC );
end component;

component accumulator is
    Port ( clk : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (31 downto 0);
           a_out : out STD_LOGIC_VECTOR (31 downto 0);
           load : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;



--SEMNALE INTERNE
signal addr : std_logic_vector(3 downto 0) := (others => '0');
signal instr : std_logic_vector(67 downto 0);
signal op_code : std_logic_vector(3 downto 0);
signal mem_a, mem_b : std_logic_vector(31 downto 0);
signal sel_a : std_logic_vector(31 downto 0);
signal cin_uc, sub_uc, neg_uc : std_logic;

signal alu_result : std_logic_vector(31 downto 0);
signal alu_of : std_logic;

signal mul_p : signed(63 downto 0);
signal div_q, div_r : std_logic_vector(31 downto 0);
signal div_start, div_done : std_logic;

signal acc_load : std_logic := '0';
signal acc_out : std_logic_vector ( 31 downto 0);

signal en, en_rst, en_load : std_logic := '0';
signal led_div0_reg, led_illigal_reg,led_over_reg : std_logic := '0';
signal sw2_sync : std_logic := '0';
signal div_zero_s : std_logic := '0';

signal acc_input : std_logic_vector(31 downto 0) := (others => '0');
signal ssd_data, result_mux : std_logic_vector(31 downto 0) := (others => '0');

--FSM
type state_t is (IDLE, FETCH, EXEC, LOAD_ACC, SHOW_RES, WAIT_DIV);
signal state : state_t := IDLE;
signal result_ready : std_logic := '0';
signal zero : std_logic_vector(31 downto 0) := (others => '0');

begin

--sincronizam sw(2) la ciclul de ceas
process(clk)
begin
    if rising_edge(clk) then
        sw2_sync <= sw(2);
    end if;
end process;    
        
--INSTANTIERE COMPONENTE
mpg1: MPG port map(
    enable => en,
    btn => btn_next,
    clk => clk
);
mpg2: MPG port map(
    enable => en_load,
    btn => btn_load,
    clk => clk
);

mpg3: MPG port map(
    enable => en_rst,
    btn => btn_rst,
    clk => clk
);

mem1: MEM port map( 
    clk => clk, 
    addr => addr, 
    instr => instr
);

uc1: UC port map(
    instr => instr,
    op_code => op_code,
    a => mem_a,
    b => mem_b,
    cin => cin_uc, 
    sub => sub_uc,
    neg => neg_uc
);

--selectam cu ce valoare vrem sa facem operatia: din memorie sau acumulator in functie de un sw
sel_a <= mem_a when sw2_sync = '0' else acc_out;

alu1: Alu_32bit port map(
    a => sel_a,
    b => mem_b,
    cin => cin_uc,
    sub => sub_uc,
    neg => neg_uc,
    op => op_code,
    result => alu_result,
    overFlow => alu_of
);

mult1: multiplier port map(
    a => signed(sel_a),
    b => signed(mem_b),
    p => mul_p
);

div1: div32 port map(
    clk => clk,
    start => div_start,
    a => sel_a,
    b => mem_b,
    quotient => div_q,
    remainder => div_r,
    done => div_done
);

acc1: accumulator port map(
    clk => clk,
    data => acc_input,
    a_out => acc_out,
    load => acc_load
);

--FSM
process(clk)
begin
    if rising_edge(clk) then
        --default
        acc_load <= '0';
        div_start <= '0';
        
        
        case state is
            when IDLE =>
                if en_rst = '1' then
                    addr <= "0000";
                    acc_input <= (others => '0');
                    acc_load <= '1';
                    led_div0_reg <= '0';
                    led_illigal_reg <= '0';
                    led_over_reg <= '0';
                    result_ready <= '0';
                    state <= IDLE;
                end if;
                if en = '1' then
                --procesam urmatoarea instructiune
                    addr <= std_logic_vector(unsigned(addr) + 1);
                    state <= FETCH;
                end if;
                
            when FETCH =>
                led_div0_reg <= '0';
                led_illigal_reg <= '0';
                led_over_reg <= '0';
                result_ready <= '0';
                state <= EXEC;
            
            when EXEC =>
                
                if op_code /= "0000" and op_code /= "0001" and op_code /= "0010" and op_code /= "0011" and
                   op_code /= "0100" and op_code /= "0101" and op_code /= "0110" and op_code /= "0111" and
                   op_code /= "1000" and op_code /= "1001" and op_code /= "1010" and op_code /= "1011" then 
                        led_illigal_reg <= '1';
                end if;
                if alu_of = '1' then 
                    led_over_reg <= '1';
                end if;
                if op_code = "1010" then --mul
                    if sw(3) = '0' then
                        acc_input <= std_logic_vector(mul_p(31 downto 0));
                    else
                        acc_input <= std_logic_vector(mul_p(63 downto 32));
                    end if;
                    state <= SHOW_RES;
                    
                elsif op_code = "1011" then --div
                    if mem_b = zero then
                        led_div0_reg <= '1';
                        acc_input <= (others => '0');
                        state <= SHOW_RES;
                    else
                        --start div
                        div_start <= '1';
                        state <= WAIT_DIV;
                    end if;
                else 
                    acc_input <= alu_result;
                    state <= SHOW_RES;
                end  if;
            when WAIT_DIV =>
                if div_done = '1' then
                    if sw(3) = '0' then
                        acc_input <= div_q;
                    else
                        acc_input <= div_r;
                    end if;
                    state <= SHOW_RES;
                end if;
            when SHOW_RES => 
                 result_ready <= '1';
                 if en_rst = '1' then
                    addr <= "0000";
                    acc_input <= (others => '0');
                    acc_load <= '1';
                    led_div0_reg <= '0';
                    led_illigal_reg <= '0';
                    led_over_reg <= '0';
                    result_ready <= '0';
                    state <= IDLE;
                 elsif en_load = '1' then
                    state <= LOAD_ACC;
                 elsif en = '1' then 
                    result_ready <= '0';
                    addr <= std_logic_vector(unsigned (addr) +1);
                    state <= FETCH;
                 --elsif result_ready = '1' then
--                   - state <= IDLE;
                 else
                    state <= SHOW_RES;
                 end if;
            when LOAD_ACC =>
                    acc_load <= '1';
                    result_ready <= '0';
                    state <= IDLE;
            when others =>
                state <= IDLE;
        end case;
    end if;
end process;

--selectam ce se afiseaza pe ssd
process(op_code, alu_result, mul_p, div_q, div_r, sw)
begin
    if op_code = "1010" then --mul
        if sw(3) = '0' then
            result_mux <= std_logic_vector(mul_p(31 downto 0));
        else 
            result_mux <= std_logic_vector(mul_p(63 downto 32));
        end if;
    elsif op_code = "1011" then --div
        if sw(3) = '0' then
            result_mux <= div_q;
        else 
            result_mux <= div_r;
        end if;
    else
        result_mux <= alu_result;
    end if;
end process;

--ssd data selection
process(sw, sel_a, mem_b, op_code, result_mux)
begin
    case sw(1 downto 0) is
        when "00" =>
            ssd_data <= sel_a;
        when "01" => 
            ssd_data <= mem_b;
        when "10" =>
            ssd_data <= (31 downto 4 => '0') & op_code;
        when others =>
            ssd_data <= result_mux;
    end case;
end process;
                            
            

ssd1: SSD port map(
    clk => clk,
    digits => ssd_data,
    an => an,
    cat => cat
);

ledOver <= led_over_reg;      
ledIlligalOp <= led_illigal_reg;    
ledDivByZero <= led_div0_reg;    
end Behavioral;
