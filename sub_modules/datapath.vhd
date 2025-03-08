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
        boot_mode : in boot_mode_type := BOOT_LOAD;
        decode_ctl : in decode_type := decode_type_init_c;
        execute_ctl : in execute_type := execute_type_init_c; 
        memory_ctl : in memory_type := memory_type_init_c;   
        write_back_ctl : in write_back_type := write_back_type_init_c;
        -- outputs
        out_port : out word_t;
        op_code_out : out op_code_t
        );        
end datapath;

architecture data_path_arch of datapath is
    -- Internal signals -- Denoted by: '_i' = Not stage specific 
    
    -- Fetch Stage signals -- Denoted by: "_f'  
    signal pc_in_f : word_t := (others => '0');
    signal pc_out_f : word_t := (others => '0');
    signal inst_addr_f : word_t := (others => '0');
    signal pc_next_f : word_t := (others => '0');    
    signal instruction_f : word_t := (others => '0');
    signal instr_decoded_f : instruction_type := instruction_type_init_c;
  
    
    -- Decode stage signals -- Denoted by:'_d'
    signal decode_ctl_d :  decode_type := decode_type_init_c; -- used in decode stage
    signal instruction_d : word_t := (others => '0');
    signal pc_next_d : word_t := (others => '0');
    -- Signals for register_file
    signal rd_data1_d    : word_t; -- Read data 1 from register file
    signal rd_data2_d    : word_t; -- Read data 2 from register file
    signal wr_data_d     : word_t; -- Data to write to register file
    
    signal wr_enable_d   : std_logic;                     -- Write enable for register file
    signal wr_index_d  : std_logic_vector(2 downto 0);
    signal rd_index1_d : std_logic_vector(2 downto 0);
    signal rd_index2_d : std_logic_vector(2 downto 0);      
      
    -- Execute stage signals -- Denoted by:'_ex'
    signal execute_ctl_ex :  execute_type := execute_type_init_c; -- used in execute stage
    signal memory_ctl_ex :  memory_type := memory_type_init_c;    -- pass through
    signal writeback_ctl_ex :  write_back_type := write_back_type_init_c; -- pass through
    signal wr_index_ex  : std_logic_vector(2 downto 0);
        
    -- Memory stage signals -- Denoted by:'_mem'
    signal memory_ctl_mem :  memory_type := memory_type_init_c; -- used in memory stage
    signal writeback_ctl_mem :  write_back_type := write_back_type_init_c; -- pass through
    signal alu_z_mem : std_logic := '0';
    signal alu_n_mem : std_logic := '0';
    signal pc_src_mem : std_logic := '0'; -- signal to select pc mux        
    signal pc_branch_mem : word_t := (others => '0');    
    signal data_address_mem : word_t := (others => '0');
    signal write_data_mem : word_t := (others => '0');
    signal memory_data_mem : word_t := (others => '0');
    signal wr_index_mem  : std_logic_vector(2 downto 0); 
    
    -- Write back stage signals -- Denoted by:'_wb'
    signal writeback_ctl_wb :  write_back_type := write_back_type_init_c; -- used in wb stage
    signal memory_data_wb : word_t := (others => '0');
    signal wr_index_wb  : std_logic_vector(2 downto 0); 
    
    signal alu_result_wb : word_t; -- Data to write to register file
       
    begin
        ---- Internal signal logic ----
        ---------- Fetch
        -- program counter mux
        pc_src_mem <= (memory_ctl_mem.branch_n and alu_n_mem) when memory_ctl_mem.branch_n = '1' else
                      (memory_ctl_mem.branch_z and alu_z_mem) when memory_ctl_mem.branch_z = '1' else
                       '0'; -- TODO Fix logic to handle z vs n cases
        -- pc source mux
        pc_in_f <= pc_branch_mem when pc_src_mem = '1' else pc_next_f; -- TODO AND with alu flag condition
        inst_addr_f <= X"0000" when boot_mode = BOOT_EXECUTE else
                       X"0002" when boot_mode = BOOT_LOAD else
                       pc_out_f;
        ---------- Decode
        -- Write index mux       
        wr_index_d <= instr_decoded_f.ra when decode_ctl_d.reg_dst = '0' else "111"; -- Write to ra or r7 for LOADIMM     
        -- register index mux                    
        rd_index1_d <= instr_decoded_f.rb when decode_ctl_d.reg_src = '0' else 
                       instr_decoded_f.ra;                             
        rd_index2_d <= instr_decoded_f.rc when decode_ctl_d.reg_src = '0' else "000";        
        ---------- Write back 
        -- register file write data mux
        wr_data_d <= memory_data_wb when writeback_ctl_wb.mem_to_reg = '1' else alu_result_wb;         
             
        mem: entity work.mem_manager
            port map (
                -- Shared ports
                clock => sys_clk,
                reset => sys_rst,
                -- Data memory - read/write  
                write_enable => memory_ctl_mem.memory_write,
                read_data_enable => memory_ctl_mem.memory_read,
                data_addr => data_address_mem,
                data_in => write_data_mem,
                data_out => memory_data_mem, 
                -- Instruction memory - read only
                inst_addr => inst_addr_f,
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
                A => inst_addr_f,
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
                rd_index1 => rd_index1_d,          -- Read index 1 (rb from Decoder)
                rd_index2 => rd_index2_d,          -- Read index 2 (rc from Decoder)
                rd_data1  => rd_data1_d,    -- Read data 1 (rb value)
                rd_data2  => rd_data2_d,    -- Read data 2 (rc value)
                wr_index  => wr_index_wb,          -- Write index (ra from Decoder)
                wr_data   => wr_data_d,     -- Write data (ALU result or INPUT)
                wr_enable => writeback_ctl_wb.reg_write    -- Write enable (controlled by op_code_f)
            );   

end data_path_arch ;