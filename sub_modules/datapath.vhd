-- datapath
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all;

entity datapath is
    port (
        -- system ports
        sys_clk : in std_logic;
        sys_rst : in std_logic;
        in_port : in word_t;        
        -- controller signal ports
        execute_ctl : out execute_type := execute_type_init_c; 
        memory_ctl : out memory_type := memory_type_init_c;   
        write_back_ctl : out write_back_type := write_back_type_init_c;
        -- outputs
        out_port : out word_t;
        op_code_out : out op_code_t
        );        
end datapath;

architecture data_path_arch of datapath is
    -- Internal signals -- Denoted by: '_i' = Not stage specific 
    -- Controller signals
    -- Fetch Stage signals -- Denoted by: "_f'  
    signal pc_in_f : word_t := (others => '0');
    signal pc_out_f : word_t := (others => '0');
    signal pc_next_f : word_t := (others => '0');    
    signal instruction_f : word_t := (others => '0');
    signal instr_decoded_f : instruction_type := instruction_type_init_c;
    -- Signals for register_file
    signal rd_data1_f    : std_logic_vector(15 downto 0); -- Read data 1 from register file
    signal rd_data2_f    : std_logic_vector(15 downto 0); -- Read data 2 from register file
    signal wr_data_f     : std_logic_vector(15 downto 0); -- Data to write to register file
    signal wr_data_mux_f : std_logic_vector(15 downto 0); -- Data to write to register file
    signal wr_enable_f   : std_logic;                     -- Write enable for register file
    signal wr_index_f  : std_logic_vector(2 downto 0);
    signal rd_index1_f : std_logic_vector(2 downto 0);
    signal rd_index2_f : std_logic_vector(2 downto 0);
    
    -- Decode stage signals -- Denoted by:'_d'
    signal instruction_d : word_t := (others => '0');
    signal pc_next_d : word_t := (others => '0');
            
    -- Execute stage signals -- Denoted by:'_ex'
    signal stage_ctl_ex :  execute_type := execute_type_init_c;
       
    -- Memory stage signals -- Denoted by:'_mem'
    signal stage_ctl_mem :  memory_type := memory_type_init_c;    
    signal pc_branch_mem : word_t := (others => '0');
    signal data_address_mem : word_t := (others => '0');
    signal write_data_mem : word_t := (others => '0');
    signal memory_data_mem : word_t := (others => '0');
    
    -- Write back stage signals -- Denoted by:'_wb'
    signal stage_ctl_wb :  write_back_type := write_back_type_init_c; 
        
    begin
        -- Internal signal logic
        pc_in_f <= pc_branch_mem when stage_ctl_mem.branch = '1' else pc_next_f; -- TODO AND with alu flag condition
                -- Write index logic
        wr_index_f <= instr_decoded_f.ra when (instr_decoded_f.opcode = ADD or  
                             instr_decoded_f.opcode = SUB or
                             instr_decoded_f.opcode = MUL or  
                             instr_decoded_f.opcode = NAND_OP or 
                             instr_decoded_f.opcode = SHL_OP or  
                             instr_decoded_f.opcode = SHR_OP or 
                             instr_decoded_f.opcode = IN_OP)
                             else "000";    
                             
        rd_index1_f <= instr_decoded_f.ra when (instr_decoded_f.opcode = SHL_OP or 
                              instr_decoded_f.opcode = SHR_OP or  
                              instr_decoded_f.opcode = TEST or 
                              instr_decoded_f.opcode = OUT_OP)                               
                              else instr_decoded_f.rb;   
                              
        rd_index2_f <= instr_decoded_f.rc when (instr_decoded_f.opcode = ADD or 
                              instr_decoded_f.opcode = SUB or  
                              instr_decoded_f.opcode = MUL or  
                              instr_decoded_f.opcode = NAND_OP or  
                              instr_decoded_f.opcode = SHL_OP or
                              instr_decoded_f.opcode = SHR_OP)
                              else "000"; 
                
        mem: entity work.mem_manager
            port map (
                -- Shared ports
                clock => sys_clk,
                reset => sys_rst,
                -- Data memory - read/write  
                write_enable => stage_ctl_mem.memory_write,
                read_data_enable => stage_ctl_mem.memory_read,
                data_addr => data_address_mem,
                data_in => write_data_mem,
                data_out => memory_data_mem, 
                -- Instruction memory - read only
                inst_addr => pc_out_f,
                inst_out => instruction_f, 
                -- Memory Mapped ports
                in_port => in_port,
                out_port => out_port --: out STD_LOGIC_VECTOR (15 downto 0) := X"0000"            
            );         
                   
        pc: entity work.program_counter
            port map (
                rst => sys_rst,
                clk => sys_clk,
                --read signals
                rd_instruction => pc_in_f, --: out std_logic_vector(15 downto 0);
                --write signals
                wr_instruction => pc_out_f, --: in std_logic_vector(15 downto 0); 
                wr_enable => '1' -- TODO: connect for hazard control          
        );
        adder_pc: entity work.adder
            port map (
                A => pc_out_f,
                B => step_size_c,
                C => pc_next_f
            );
            
        fetch: entity work.fetch_register
            port map ( 
                rst => sys_rst,
                clk => sys_clk,
                --read signals               
                rd_instruction => instruction_d, --: out std_logic_vector(15 downto 0);
                rd_pc => pc_next_d,
                --write signals
                wr_instruction => instruction_f, --: in std_logic_vector(15 downto 0);
                wr_pc => pc_next_f,  
                wr_enable => '1' -- TODO: connect for hazard control            
            );
                   
        decoder: entity work.decoder
            port map (
                instr => instruction_d,   -- Input instruction
                instr_decoded => instr_decoded_f 
        );       
        -- Instantiate the register_file
        Register_File_inst: entity work.register_file
            port map(
                rst       => sys_rst,         -- Reset signal
                clk       => sys_clk,         -- Clock signal
                rd_index1 => rd_index1_f,          -- Read index 1 (rb from Decoder)
                rd_index2 => rd_index2_f,          -- Read index 2 (rc from Decoder)
                rd_data1  => rd_data1_f,    -- Read data 1 (rb value)
                rd_data2  => rd_data2_f,    -- Read data 2 (rc value)
                wr_index  => wr_index_f,          -- Write index (ra from Decoder)
                wr_data   => wr_data_mux_f,     -- Write data (ALU result or INPUT)
                wr_enable => wr_enable_f    -- Write enable (controlled by op_code_f)
            );
    

end data_path_arch ;