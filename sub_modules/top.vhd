library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity CPU_Top is
    port(
        clk         : in std_logic;  -- Clock signal
        rst         : in std_logic;  -- Reset signal
        instr       : in std_logic_vector(15 downto 0);  -- Input instruction
        input_port  : in std_logic_vector(15 downto 0);  -- Inport for IN inst
        output_port : out std_logic_vector(15 downto 0);  -- Outport for OUT inst
        alu_result  : out std_logic_vector(15 downto 0);  -- ALU result (for debugging)           
        n_flag      : out std_logic;
        z_flag      : out std_logic
    );
end CPU_Top;

architecture Structural of CPU_Top is
    -- ALU Operations
    constant NOP      : std_logic_vector(6 downto 0) := "0000000";
    constant ADD      : std_logic_vector(6 downto 0) := "0000001";
    constant SUB      : std_logic_vector(6 downto 0) := "0000010";
    constant MUL      : std_logic_vector(6 downto 0) := "0000011";
    constant NAND_OP  : std_logic_vector(6 downto 0) := "0000100";
    constant SHL_OP   : std_logic_vector(6 downto 0) := "0000101";
    constant SHR_OP   : std_logic_vector(6 downto 0) := "0000110";
    constant TEST     : std_logic_vector(6 downto 0) := "0000111";
    constant OUT_OP   : std_logic_vector(6 downto 0) := "0100000";
    constant IN_OP    : std_logic_vector(6 downto 0) := "0100001";

    -- Branch Operations
    constant BRR      : std_logic_vector(6 downto 0) := "1000000";
    constant BRR_N    : std_logic_vector(6 downto 0) := "1000001";
    constant BRR_Z    : std_logic_vector(6 downto 0) := "1000010";
    constant BR       : std_logic_vector(6 downto 0) := "1000011";
    constant BR_N     : std_logic_vector(6 downto 0) := "1000100";
    constant BR_Z     : std_logic_vector(6 downto 0) := "1000101";
    constant BR_SUB   : std_logic_vector(6 downto 0) := "1000110";
    constant RETURN_OP: std_logic_vector(6 downto 0) := "1000111";

    -- Load/Store Operations
    constant LOAD     : std_logic_vector(6 downto 0) := "0010000";
    constant STORE    : std_logic_vector(6 downto 0) := "0010001";
    constant LOADIMM  : std_logic_vector(6 downto 0) := "0010010";
    constant MOV      : std_logic_vector(6 downto 0) := "0010011";
    
    -- Signals for connecting Decoder and register_file
    signal opcode     : std_logic_vector(6 downto 0);  -- Opcode from Decoder
    signal ra         : std_logic_vector(2 downto 0);  -- Register A from Decoder
    signal rb         : std_logic_vector(2 downto 0);  -- Register B from Decoder
    signal rc         : std_logic_vector(2 downto 0);  -- Register C from Decoder
    signal shift      : std_logic_vector(3 downto 0);  -- Shift amount from Decoder
    signal disp_s     : std_logic_vector(5 downto 0);  -- Displacement (short) from Decoder
    signal disp_l     : std_logic_vector(8 downto 0);  -- Displacement (long) from Decoder
    signal m_1        : std_logic;                     -- Mode bit from Decoder
    signal in_port_ctl : std_logic;
    signal out_port_ctl : std_logic;                 
    signal imm        : std_logic_vector(7 downto 0);  -- Immediate value from Decoder
    signal r_dest     : std_logic_vector(2 downto 0);  -- Destination register from Decoder
    signal r_src      : std_logic_vector(2 downto 0);  -- Source register from Decoder

    -- Signals for register_file
    signal rd_data1    : std_logic_vector(15 downto 0); -- Read data 1 from register file
    signal rd_data2    : std_logic_vector(15 downto 0); -- Read data 2 from register file
    signal wr_data     : std_logic_vector(15 downto 0); -- Data to write to register file
    signal wr_data_mux : std_logic_vector(15 downto 0); -- Data to write to register file
    signal wr_enable   : std_logic;                     -- Write enable for register file

    -- Signals for ALU
    signal alu_in1    : std_logic_vector(15 downto 0); -- ALU input 1 (rb value)
    signal alu_in2    : std_logic_vector(15 downto 0); -- ALU input 2 (rc value)
    signal alu_out    : std_logic_vector(15 downto 0); -- ALU output (result)
    signal zero_flag  : std_logic;                     -- Zero flag from ALU
    signal negative_flag : std_logic;                  -- Negative flag from ALU
    
    signal wr_index  : std_logic_vector(2 downto 0);
    signal rd_index1 : std_logic_vector(2 downto 0);
    signal rd_index2 : std_logic_vector(2 downto 0);

begin
    --Instatiate Mux
    wrt_bck_mux: entity work.mux
        port map(
            A => wr_data,
            B => input_port,
            Selector => in_port_ctl,
            C => wr_data_mux
        ); 
           
        --Instatiate Mux
    out_port_mux: entity work.mux
    port map(
            A => x"0000",
            B => rd_data1,
            Selector => out_port_ctl,
            C => output_port
        );
    
    -- Instantiate the Decoder
    Decoder_inst: entity work.Decoder
        port map(
            instr  => instr,   -- Input instruction
            opcode => opcode,  -- Opcode
            ra     => ra,      -- Register A
            rb     => rb,      -- Register B
            rc     => rc,      -- Register C
            shift  => shift,   -- Shift amount
            disp_s => disp_s,  -- Displacement (short)
            disp_l => disp_l,  -- Displacement (long)
            m_1    => m_1,     -- Mode bit
            in_port_ctl => in_port_ctl, -- Control write back mux
            out_port_ctl => out_port_ctl, -- Control mux to output ra or 0
            imm    => imm,     -- Immediate value
            r_dest => r_dest,  -- Destination register
            r_src  => r_src    -- Source register
        );

    -- Instantiate the register_file
    Register_File_inst: entity work.register_file
        port map(
            rst       => rst,         -- Reset signal
            clk       => clk,         -- Clock signal
            rd_index1 => rd_index1,          -- Read index 1 (rb from Decoder)
            rd_index2 => rd_index2,          -- Read index 2 (rc from Decoder)
            rd_data1  => rd_data1,    -- Read data 1 (rb value)
            rd_data2  => rd_data2,    -- Read data 2 (rc value)
            wr_index  => wr_index,          -- Write index (ra from Decoder)
            wr_data   => wr_data_mux,     -- Write data (ALU result or INPUT)
            wr_enable => wr_enable    -- Write enable (controlled by opcode)
        );

        -- Write index logic
        wr_index <= ra when (opcode = ADD or  
                             opcode = SUB or
                             opcode = MUL or  
                             opcode = NAND_OP or 
                             opcode = SHL_OP or  
                             opcode = SHR_OP or 
                             opcode = IN_OP)
                             else "000";    
                             
        rd_index1 <= ra when (opcode = SHL_OP or 
                              opcode = SHR_OP or  
                              opcode = TEST or 
                              opcode = OUT_OP)                               
                              else rb;   
                              
        rd_index2 <= rc when (opcode = ADD or 
                              opcode = SUB or  
                              opcode = MUL or  
                              opcode = NAND_OP or  
                              opcode = SHL_OP or
                              opcode = SHR_OP)
                              else "000";   
                              
    -- Connect ALU inputs
    alu_in1 <= rd_data1; -- ALU input 1
    alu_in2 <= rd_data2; -- ALU input 2

    -- Instantiate the ALU
    ALU_inst: entity work.ALU
        port map(
            in1          => alu_in1,      -- ALU input 1 
            in2          => alu_in2,      -- ALU input 2 
            alu_mode     => opcode,       -- ALU opcode (from Decoder)
            alu_out      => alu_out,      -- ALU result
            shift        => shift,        -- Shift amount (from Decoder)
            zero_flag    => zero_flag,    -- Zero flag
            negative_flag => negative_flag, -- Negative flag
            clk          => clk,         -- Clock signal
            rst          => rst          -- Reset signal
        );

    -- Write data logic
    wr_data <= alu_out; -- Write ALU result to register file
    wr_enable <= '1' when (opcode = "0000001" or opcode = "0000010" or opcode = "0000011" or opcode = "0000100" or opcode = "0000101" or opcode = "0000110" or opcode = "0100001") else '0'; -- Enable write for ALU operations

    -- Output ALU result for debugging
    alu_result <= alu_out;
    n_flag <= negative_flag;
    z_flag <= zero_flag;
end Structural;