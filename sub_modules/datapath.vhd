-- datapath
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.cpu_types.all;

entity datapath is
    port (
        -- system ports
        sys_clk        : in std_logic := '0';
        sys_rst        : in std_logic := '0';
        in_port        : in word_t := (others => '0');        
        -- controller signal ports
        boot_mode      : in boot_mode_type := BOOT_LOAD;
        decode_ctl     : in decode_type := decode_type_init_c;
        execute_ctl    : in execute_type := execute_type_init_c; 
        memory_ctl     : in memory_type := memory_type_init_c;   
        write_back_ctl : in write_back_type := write_back_type_init_c;
        -- outputs
        out_port       : out word_t := (others => '0');
        op_code_out    : out op_code_t
        );        
end datapath;

architecture data_path_arch of datapath is
    -- Internal signals -- Denoted by: '_i' = Not stage specific 
    -- Fetch Stage signals -- Denoted by: "_f'  
    signal pc_in_f            : word_t := (others => '0');
    signal pc_out_f           : word_t := (others => '0');
    signal inst_addr_f        : word_t := (others => '0');
    signal pc_next_f          : word_t := (others => '0');    
    signal instruction_f      : word_t := (others => '0');      
    
    -- Decode stage signals -- Denoted by:'_d'
    signal instruction_d      : word_t := (others => '0');
    signal instr_decoded_d    : instruction_type := instruction_type_init_c;
    signal pc_next_d          : word_t := (others => '0');
    -- Signals for register_file
    signal rd_data1_d         : word_t := (others => '0'); -- Read data 1 from register file
    signal rd_data2_d         : word_t := (others => '0'); -- Read data 2 from register file
    signal wr_data_d          : word_t := (others => '0'); -- Data to write to register file    
    signal wr_enable_d        : std_logic;                     -- Write enable for register file
    signal wr_index_d         : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_index1_d        : std_logic_vector(2 downto 0) := (others => '0');
    signal rd_index2_d        : std_logic_vector(2 downto 0) := (others => '0');      
    signal imm_temp_d         : word_t := (others => '0');
    signal imm_fwd_d          : word_t := (others => '0');    
    signal inport_fwd_d      : word_t := (others => '0');
    signal alu_shift_d       : std_logic_vector(3 downto 0) := (others => '0');
    -- Execute stage signals -- Denoted by:'_ex'
    signal execute_ctl_ex     : execute_type := execute_type_init_c; -- used in execute stage
    signal memory_ctl_ex      : memory_type := memory_type_init_c;    -- pass through
    signal write_back_ctl_ex  : write_back_type := write_back_type_init_c; -- pass through
    signal pc_next_ex         : word_t := (others => '0');
    signal rd_data1_ex        : word_t := (others => '0'); -- Read data 1 from register file
    signal rd_data2_ex        : word_t := (others => '0'); -- Read data 2 from register file
    signal wr_index_ex        : std_logic_vector(2 downto 0);
    signal imm_fwd_ex         : word_t := (others => '0');
    signal inport_fwd_ex      : word_t := (others => '0');
    signal alu_shift_ex       : std_logic_vector(3 downto 0) := (others => '0');
    signal pc_branch_addr_ex  : word_t := (others => '0');
    -- alu
    signal alu_in1_ex         : word_t := (others => '0'); 
    signal alu_in2_ex         : word_t := (others => '0');
    signal alu_result_ex      : word_t:= (others => '0');
    signal alu_z_ex           : std_logic := '0';
    signal alu_n_ex           : std_logic := '0';     
    -- Memory stage signals -- Denoted by:'_mem'
    signal memory_ctl_mem     : memory_type := memory_type_init_c; -- used in memory stage
    signal write_back_ctl_mem : write_back_type := write_back_type_init_c; -- pass through
    signal pc_next_mem        : word_t := (others => '0');
    -- alu
    signal alu_result_mem     : word_t := (others => '0');
    signal alu_z_mem          : std_logic := '0';
    signal alu_n_mem          : std_logic := '0';
    signal pc_src_mem         : std_logic := '0'; -- signal to select pc mux        
    signal pc_branch_addr_mem : word_t := (others => '0');    
    signal data_address_mem   : word_t := (others => '0');
    signal write_data_mem     : word_t := (others => '0');
    signal memory_data_mem    : word_t := (others => '0');
    signal wr_data_fwd_mem    : word_t := (others => '0'); -- Data to write to register file
    signal wr_index_mem       : std_logic_vector(2 downto 0) := (others => '0'); 
    signal imm_fwd_mem        : word_t := (others => '0');
    signal inport_fwd_mem      : word_t := (others => '0'); 
    -- Write back stage signals -- Denoted by:'_wb'
    signal write_back_ctl_wb  : write_back_type := write_back_type_init_c; -- used in wb stage
    signal pc_next_wb     : word_t := (others => '0');
    signal memory_data_wb     : word_t := (others => '0');
    signal wr_data_fwd_wb     : word_t := (others => '0'); -- Data to write to register file
    signal wr_index_wb        : std_logic_vector(2 downto 0)  := (others => '0'); 
    signal imm_fwd_wb         : word_t := (others => '0');
    signal inport_fwd_wb      : word_t := (others => '0');
    signal alu_result_wb      : word_t := (others => '0'); -- Data to write to register file
       
    begin
        --------------- Internal signal logic ----------------
        op_code_out <= instr_decoded_d.opcode;
        ---------- Fetch
        -- program counter mux

        -- pc source mux
        pc_in_f <= pc_branch_addr_mem when (pc_src_mem = '1') and (boot_mode = RUN) else                   
                   X"0000" when boot_mode = BOOT_EXECUTE else
                   X"0002" when boot_mode = BOOT_LOAD else
                   pc_next_mem;
                       
        ---------- Decode
        -- Write index mux       
        wr_index_d <= instr_decoded_d.ra when decode_ctl.reg_dst = '0' else "111"; -- Write to ra or r7 for LOADIMM and BR.SUB     
        -- register index mux                    
        rd_index1_d <= instr_decoded_d.rb when decode_ctl.reg_src = '0' else 
                       instr_decoded_d.ra;                             
        rd_index2_d <= instr_decoded_d.rc when decode_ctl.reg_src = '0' else "000";
        
        imm_temp_d <=   (instr_decoded_d.imm & X"00") when (instr_decoded_d.m_1 = '1') and (decode_ctl.imm_op = '1') else
                        (X"00" & instr_decoded_d.imm) when (instr_decoded_d.m_1 = '0') and (decode_ctl.imm_op = '1') else
                         X"0000";
        inport_fwd_d <= in_port when instr_decoded_d.opcode = IN_OP else
                        X"0000";
        out_port <= rd_data1_d when instr_decoded_d.opcode = OUT_OP; 
        alu_shift_d <= instr_decoded_d.shift when (instr_decoded_d.opcode = SHL_OP or instr_decoded_d.opcode = SHR_OP) else
                       "0000";
        ---------- Execute
                
        ---------- Memory
        pc_src_mem <= (memory_ctl_mem.branch_n and alu_n_mem) when memory_ctl_mem.branch_n = '1' else
                  (memory_ctl_mem.branch_z and alu_z_mem) when memory_ctl_mem.branch_z = '1' else
                   '0';
                        
        ---------- Write back 
        -- register file write data mux
        wr_data_d <= memory_data_wb when write_back_ctl_wb.wb_src = MEMORY_DATA else
                     alu_result_wb when write_back_ctl_wb.wb_src = ALU_RES else
                     imm_fwd_wb when write_back_ctl_wb.wb_src = IMM_FWD else
                     pc_next_wb when write_back_ctl_wb.wb_src = RETURN_PC else
                     inport_fwd_wb when write_back_ctl_wb.wb_src = INPORT_FWD else
                     X"0000";
                     
        --------------- Fetch/Memory Stage Modules -------------------                                     
        -- Fetch/Memory
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
        -- Fetch          
        pc: entity work.program_counter
            port map (
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => '1', -- TODO: connect for hazard control
                --write signals
                wr_instruction => pc_in_f, --: in std_logic_vector(15 downto 0);                
                --read signals
                rd_instruction => inst_addr_f --: out std_logic_vector(15 downto 0);          
        );
        -- Fetch
        adder_pc: entity work.adder
            port map (
                A => inst_addr_f,
                B => step_size_c,
                C => pc_next_f
            );
        -- Fetch    
        fetch_r: entity work.fetch_register
            port map ( 
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => '1', -- TODO: connect for hazard control
                -- inputs
                wr_instruction => instruction_f, --: in std_logic_vector(15 downto 0);
                wr_pc => pc_next_f,               
                -- outputs               
                rd_instruction => instruction_d, --: out std_logic_vector(15 downto 0);
                rd_pc => pc_next_d          
            );
            
        --------------- Decode Stage Modules -------------------                               
        decoder: entity work.decoder
            port map (
                instr => instruction_d,   -- Input instruction
                instr_decoded => instr_decoded_d 
        );       
        -- Decode
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
                wr_enable => write_back_ctl_wb.reg_write    -- Write enable (controlled by op_code_f)
            ); 
        -- Decode
        -- concatonate imm_upper and imm_lower    
        immconcat: entity work.immediate_concatenator 
            port map(
                clear_low => decode_ctl.imm_op, -- clear when not a LOADIMM op  
                imm_in => imm_temp_d,
                imm_out => imm_fwd_d          
            );
        -- Decode
        decode_r: entity work.decode_register
            port map (
                -- register control inputs 
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => '1', -- TODO hazard control 
                -- inputs
                wr_pc => pc_next_d,
                -- register file
                wr_reg_data1 => rd_data1_d,
                wr_reg_data2 => rd_data2_d,
                wr_reg_write_index => wr_index_d,
                -- TODO add displacement
                wr_immidate => imm_fwd_d,
                wr_inport_data => inport_fwd_d,
                wr_alu_shift => alu_shift_d,          
                -- contorller records
                wr_execute_ctl => execute_ctl,
                wr_memory_ctl => memory_ctl,
                wr_write_back_ctl => write_back_ctl,                
                -- outputs
                rd_pc => pc_next_ex,
                -- register file
                rd_reg_data1 => alu_in1_ex, -- to alu in1
                rd_reg_data2 => alu_in2_ex, -- to alu in2
                rd_reg_write_index => wr_index_ex,
                -- 
                rd_immidate => imm_fwd_ex,
                rd_inport_data => inport_fwd_ex,
                rd_alu_shift => alu_shift_ex,
                -- contorller records 
                rd_execute_ctl => execute_ctl_ex,
                rd_memory_ctl => memory_ctl_ex,
                rd_write_back_ctl => write_back_ctl_ex             
            );   
        --------------- Execute Stage Modules ------------------- 
        -- Execute
        -- Instantiate the ALU
        ALU_inst: entity work.ALU
            port map(
                in1          => alu_in1_ex,      -- ALU input 1 
                in2          => alu_in2_ex,      -- ALU input 2 
                alu_mode     => execute_ctl_ex.alu_op,       -- ALU opcode (from Decoder)
                alu_out      => alu_result_ex,      -- ALU result
                shift        => alu_shift_ex,        -- Shift amount (from Decoder)
                negative_flag => alu_n_ex, -- Negative flag
                zero_flag    => alu_z_ex    -- Zero flag
            );
        -- Execute    
        adder_pc_branch: entity work.adder
            port map (
                A => pc_next_ex,
                B => X"0000", -- TODO  2* (sign extended displacement )
                C => pc_branch_addr_ex
            );
        -- Execute   
        execute_r: entity work.execute_register
            port map(
            rst => sys_rst,
            clk => sys_clk,
            wr_enable => '1', -- TODO hazard control
            wr_branch_address => pc_branch_addr_ex,
            -- alu
            wr_alu_result => alu_result_ex,
            wr_alu_n => alu_n_ex,
            wr_alu_z => alu_z_ex,
            -- register file
            wr_reg_data1 => rd_data1_ex,
            wr_reg_data2 => rd_data2_ex,
            wr_reg_write_index => wr_index_ex,
            wr_immidate => imm_fwd_ex,
            wr_inport_data => inport_fwd_ex,           
            -- contorller records
            wr_memory_ctl => memory_ctl_ex,
            wr_write_back_ctl => write_back_ctl_ex,
            
            -- outputs
            rd_branch_address => pc_branch_addr_mem,
            -- alu
            rd_alu_result => alu_result_mem,
            rd_alu_n => alu_n_mem,
            rd_alu_z => alu_z_mem,
            -- register file
            rd_reg_data1 => data_address_mem, -- to alu in1
            rd_reg_data2 => write_data_mem, -- to alu in2
            rd_reg_write_index => wr_index_mem,
            -- 
            rd_immidate => imm_fwd_mem,
            rd_inport_data => inport_fwd_mem,
            -- contorller records 
            rd_memory_ctl => memory_ctl_mem,
            rd_write_back_ctl => write_back_ctl_mem            
            );
            
        --------------- Write Back Stage Modules ----------------                                   
        mem_r: entity work.memory_register
            port map(
                -- inputs
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => '1', -- TODO hazard control
                -- alu
                wr_alu_result => alu_result_mem,
               -- register file
                wr_reg_write_index => wr_index_mem,
                -- TODO add displacement
                wr_immidate => imm_fwd_mem, 
                wr_inport_data => inport_fwd_mem,          
                -- contorller records
                wr_write_back_ctl => write_back_ctl_mem,           
                -- outputs
                -- alu
                rd_alu_result => alu_result_wb,
                -- register file       
                rd_reg_write_index => wr_index_wb,
                -- 
                rd_immidate => imm_fwd_wb,
                rd_inport_data => inport_fwd_wb,
                -- contorller records 
                rd_write_back_ctl => write_back_ctl_wb            
            );

end data_path_arch ;