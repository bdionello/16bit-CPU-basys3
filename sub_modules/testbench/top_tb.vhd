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

        -- Test ADD instruction: ADD R1, R2, R3 (R1 = R2 + R3)
        -- Instruction format: opcode (7 bits) | ra (3 bits) | rb (3 bits) | rc (3 bits)
        -- ADD opcode = "0000001"
        instr <= "0000001" & "001" & "010" & "011"; -- ADD R1, R2, R3
        wait for CLK_PERIOD;


        -- Test SUB instruction: SUB R4, R5, R6 (R4 = R5 - R6)
        -- SUB opcode = "0000010"
        instr <= "0000010" & "100" & "101" & "110"; -- SUB R4, R5, R6
        wait for CLK_PERIOD;
  
        -- Test MUL instruction: MUL R7, R0, R1 (R7 = R0 * R1)
        -- MUL opcode = "0000011"
        instr <= "0000011" & "111" & "000" & "001"; -- MUL R7, R0, R1
        wait for CLK_PERIOD;
        
        -- Test NAND instruction: NAND R5, R2, R3 (R5 = R2 NAND R3)
        -- NAND opcode = "0000100"
        instr <= "0000100" & "101" & "010" & "011"; -- NAND R5, R2, R3 
        wait for CLK_PERIOD;
        
        -- Test SHL instruction: SHL R1, #2 (R1 = R1 << 2)
        -- SHL opcode = "0000101"
        instr <= "0000101" & "001" & "00" & "0010"; -- SHL R1, #2
        wait for CLK_PERIOD;
        
        -- Test SHR instruction: SHR R1, #1 (R1 = R1 >> 1)
        -- SHR opcode = "0000110
        instr <= "0000110" & "001" & "00" & "0001"; -- SHR R1, #1
        wait for CLK_PERIOD;
        
        -- ADDED FLAG TEST
        -- Test TEST instruction: TEST R0 (Check if R0 is zero or negative)
        -- TEST opcode = "0000111"
        instr <= "0000111" & "000" & "000" & "000"; -- TEST R0
        wait for CLK_PERIOD;
        
        -- Test SHL instruction: SHL R0, #15 (R0 = R0 << 15)
        -- SHL opcode = "0000101"
        instr <= "0000101" & "000" & "00" & X"f"; -- SHL R0, #15
        wait for CLK_PERIOD;
        
        -- Test TEST instruction: TEST R1 (Check if R1 is zero or negative)
        -- TEST opcode = "0000111"
        instr <= "0000111" & "000" & "000" & "000"; -- TEST R0
        wait for CLK_PERIOD;
        
        -- Test SHL instruction: SHL R0, #1 (R0 = R0 << 1)
        -- SHL opcode = "0000101"
        instr <= "0000101" & "000" & "00" & "0001"; -- SHL R0, #1
        wait for CLK_PERIOD; 
  
        -- Test TEST instruction: TEST R1 (Check if R1 is zero or negative)
        -- TEST opcode = "0000111"
        instr <= "0000111" & "000" & "000" & "000"; -- TEST R0
        wait for CLK_PERIOD;
        
        -- Test IN  F7CF = 65404
        in_data <= X"F7CF";
        instr <= "0100001" & "111" & "000" & "000"; -- 
        wait for CLK_PERIOD;
                
        -- Test OUT
        instr <= "0100000" & "111" & "000" & "000"; -- 
        wait for CLK_PERIOD;        
        
        -- constant OUT_OP   : std_logic_vector(6 downto 0) := "0100000";
        -- constant IN_OP    : std_logic_vector(6 downto 0) := "0100001";        

        -- End simulation
        wait;
    end process;
end Behavioral;