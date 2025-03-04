library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CPU_Top_TB is
end CPU_Top_TB;

architecture Behavioral of CPU_Top_TB is
    -- Constants
    constant CLK_PERIOD : time := 10 ns; -- Clock period (100 MHz)

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1'; -- Active high reset
    signal instr       : std_logic_vector(15 downto 0) := (others => '0'); -- Instruction
    signal in_data     : std_logic_vector(15 downto 0) := (others => '0'); -- IN port
    signal out_data       : std_logic_vector(15 downto 0) := (others => '0'); -- OUT port
    signal alu_result  : std_logic_vector(15 downto 0); -- ALU result (for debugging)
    signal n_flag : std_logic := '0';
    signal z_flag : std_logic := '0';

    -- Instantiate the CPU_Top module
    component CPU_Top
        port(
            clk         : in std_logic;
            rst         : in std_logic;
            instr       : in std_logic_vector(15 downto 0);
            input_port  : in std_logic_vector(15 downto 0);
            output_port : out std_logic_vector(15 downto 0);
            alu_result  : out std_logic_vector(15 downto 0);
            n_flag : out std_logic;
            z_flag : out std_logic
        );
    end component;

begin
    -- Instantiate the CPU_Top module
    uut: CPU_Top
        port map(
            clk => clk,
            rst => rst,
            instr => instr,
            input_port => in_data,
            output_port => out_data,
            alu_result => alu_result,
            n_flag => n_flag,
            z_flag => z_flag
        );

    -- Clock generation process
    clk_process: process
    begin
        while now < 210 ns loop -- Run simulation for 200 ns
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        -- Initialize reset
        rst <= '1';
        wait for CLK_PERIOD * 2; -- Hold reset for 2 clock cycles
        rst <= '0'; -- Release reset
                
        instr <= X"4240"; -- IN r1 ; 03
        wait for CLK_PERIOD; 
        instr <= X"4280"; -- IN r2 ; 05
        wait for CLK_PERIOD; 
        instr <= X"02D1"; -- ADD r3, r2, r1
        wait for CLK_PERIOD; 
        instr <= X"0AC2"; -- SHL r3, 2
        wait for CLK_PERIOD; 
        instr <= X"068B"; -- MUL r2, r1, r3
        wait for CLK_PERIOD; 
        instr <= X"4080";  -- OUT r2
        wait for CLK_PERIOD;
        -- End simulation
        wait;
    end process;
end Behavioral;