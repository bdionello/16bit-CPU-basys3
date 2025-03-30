-- datapath
library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.cpu_types.all;

entity datapath is
    port (
        -- system ports
        sys_clk        : in std_logic;
        sys_rst        : in std_logic;
        in_port        : in word_t; 
        dip_switches   : in word_t;        
        -- controller signal ports
        boot_mode      : in boot_mode_type;
        decode_ctl     : in decode_type;
        execute_ctl    : in execute_type; 
        memory_ctl     : in memory_type;   
        write_back_ctl : in write_back_type;
        -- outputs
        
        
        ctl_wr_enable     : out std_logic;
        out_port          : out word_t;
        op_code_out       : out op_code_t;
        led_7seg_data     : out word_t;
        video_data        : out word_t;
        display_data_addr : out word_t;
        display_enable    : out std_logic;
        
        -- console display signals
        display_fetch  : out display_fetch_type;
        display_decode : out display_decode_type;
        display_execute: out display_execute_type;
        display_memory : out display_memory_type;
        display_register : out display_register_type
        );        
end datapath;

architecture data_path_arch of datapath is
    -- Internal signals -- Denoted by: '_i' = Not stage specific
    signal flush_f_reg_i      :  std_logic;
    signal flush_d_reg_i      :  std_logic;
    signal flush_ex_reg_i     :  std_logic;
    signal stall_pipeline_low_i   :  std_logic;
    -- Fetch Stage signals -- Denoted by: "_f'  
    signal pc_in_f            : word_t;
    signal pc_out_f           : word_t;
    signal inst_addr_f        : word_t;
    signal pc_next_f          : word_t;    
    signal instruction_f      : word_t;
    signal rst_fetch_reg_f    : std_logic;   
    -- Decode stage signals -- Denoted by:'_d'
    signal instruction_d      : word_t;
    signal instruction_fwd_d      : word_t;
    signal instr_decoded_d    : instruction_type;
    signal pc_current_d          : word_t;
    signal extended_disp_d    : word_t;    
    signal decode_ctl_d       : decode_type; -- pass through
    signal execute_ctl_d      : execute_type; -- used in execute stage
    signal memory_ctl_d       : memory_type;    -- pass through
    signal write_back_ctl_d   : write_back_type; -- pass through 
     
    -- Signals for register_file
    signal rd_data1_d         : word_t; -- Read data 1 from register file
    signal rd_data2_d         : word_t; -- Read data 2 from register file
    signal wr_data_d          : word_t; -- Data to write to register file    
    signal wr_enable_d        : std_logic;                     -- Write enable for register file
    signal wr_index_d         : std_logic_vector(2 downto 0);
    signal rd_index1_d        : std_logic_vector(2 downto 0);
    signal rd_index2_d        : std_logic_vector(2 downto 0);      
    signal imm_fwd_d          : word_t;    
    signal inport_fwd_d       : word_t;
    signal alu_shift_d        : std_logic_vector(3 downto 0);
    signal rst_decode_reg_d   : std_logic; 
    signal reg_7_d : word_t;  
     
    -- Execute stage signals -- Denoted by:'_ex'
    signal instruction_ex     : word_t;
    signal execute_ctl_ex     : execute_type; -- used in execute stage
    signal memory_ctl_ex      : memory_type;    -- pass through
    signal write_back_ctl_ex  : write_back_type; -- pass through
    signal pc_current_ex      : word_t;
    signal rd_data1_ex        : word_t; -- Read data 1 from register file
    signal rd_data2_ex        : word_t; -- Read data 2 from register file
    signal wr_index_ex        : std_logic_vector(2 downto 0);
    signal imm_fwd_ex         : word_t;
    signal m_1_ex             : std_logic;
    signal inport_fwd_ex      : word_t;
    signal alu_shift_ex       : std_logic_vector(3 downto 0);
    signal pc_branch_addr_ex  : word_t;
    signal extended_disp_ex   : word_t;
    -- alu
    signal alu_result_ex      : word_t;
    signal alu_z_ex           : std_logic;
    signal alu_n_ex           : std_logic;
    signal alu_o_ex           : std_logic;
    signal pc_src_ex          : std_logic; -- signal to select pc mux  
    
    -- Memory stage signals -- Denoted by:'_mem'
    signal instruction_mem    : word_t;
    signal memory_ctl_mem     : memory_type; -- used in memory stage
    signal write_back_ctl_mem : write_back_type; -- pass through
    signal pc_current_mem     : word_t; -- UNUSED
    -- alu
    signal alu_result_mem     : word_t;
    signal alu_z_mem          : std_logic;
    signal alu_n_mem          : std_logic;
    signal alu_o_mem           : std_logic;    
    signal rd_data1_mem       : word_t;
    signal rd_data2_mem       : word_t;
    signal memory_data_mem     : word_t;    
    signal wr_data_fwd_mem    : word_t; -- Data to write to register file
    signal wr_index_mem       : std_logic_vector(2 downto 0); 
    signal imm_fwd_mem        : word_t;
    signal m_1_mem            : std_logic;
    signal inport_fwd_mem     : word_t;    
    signal extended_disp_mem  : word_t;
    signal out_port_enable_mem  : std_logic;
    signal seg7_enable_mem    : std_logic;
    signal led_7seg_data_mem  :  word_t;
    -- Write back stage signals -- Denoted by:'_wb'
    signal alu_o_wb           : std_logic;
    signal instruction_wb     : word_t;
    signal write_back_ctl_wb  : write_back_type; -- used in wb stage
    signal pc_current_wb      : word_t;
    signal rd_data1_wb        : word_t;
    signal memory_data_wb     : word_t;
    signal wr_data_fwd_wb     : word_t; -- Data to write to register file
    signal wr_index_wb        : std_logic_vector(2 downto 0); 
    signal imm_fwd_wb         : word_t;
    signal imm_cat_wb         : word_t;
    signal m_1_wb             : std_logic;
    signal inport_fwd_wb      : word_t;    
    signal alu_result_wb      : word_t; -- Data to write to register file
    
    begin
        --------------- Internal signal logic ----------------
        -- send NOP to controller when pipeline stalled
        ctl_wr_enable <= stall_pipeline_low_i;
        -- flush controller when branch taken      
        op_code_out <=  NOP when flush_f_reg_i = '1' else 
                        instruction_f(15 downto 9);                        
        ---------- Fetch
        -- program counter mux
        inst_addr_f <= X"0000" when boot_mode = BOOT_EXECUTE else
                       X"0002" when boot_mode = BOOT_LOAD else
                       pc_out_f;
                       
        -- pc source mux
        pc_in_f <= pc_branch_addr_ex when (pc_src_ex = '1') else 
                   pc_next_f;
                       
        ---------- Decode
        -- Write index mux       
        wr_index_d <=   instr_decoded_d.r_dest when (instr_decoded_d.opcode = LOAD or instr_decoded_d.opcode = MOV) else
                        instr_decoded_d.ra when decode_ctl_d.reg_dst = '0' else
                        "111";
      
        -- register index mux                    
        rd_index1_d <= instr_decoded_d.r_src when (instr_decoded_d.opcode = LOAD or instr_decoded_d.opcode = MOV) else
                       instr_decoded_d.r_dest when (instr_decoded_d.opcode = STORE) else
                       instr_decoded_d.rb when decode_ctl_d.reg_src = '0' else
                       "111" when (decode_ctl_d.reg_src = '1') and (instr_decoded_d.opcode = RETURN_OP) else
                       instr_decoded_d.ra;
                                                    
        rd_index2_d <=  instr_decoded_d.r_src when (instr_decoded_d.opcode = STORE) else
                        instr_decoded_d.rc when decode_ctl_d.reg_src = '0' else "000";  
                          
        inport_fwd_d <= in_port when instr_decoded_d.opcode = IN_OP else
                        X"0000";                                    
         
        alu_shift_d <= instr_decoded_d.shift when (instr_decoded_d.opcode = SHL_OP or instr_decoded_d.opcode = SHR_OP) else
                       "0000";
                       
        -- Inject NOP control signals to decode register
        decode_ctl_d <= decode_type_init_c when (flush_d_reg_i = '1') or (stall_pipeline_low_i = '0') else decode_ctl;        
        execute_ctl_d <= execute_type_init_c when (flush_d_reg_i = '1') or (stall_pipeline_low_i = '0') else execute_ctl;        
        memory_ctl_d <= memory_type_init_c when (flush_d_reg_i = '1') or (stall_pipeline_low_i = '0') else memory_ctl;        
        write_back_ctl_d <= write_back_type_init_c when (flush_d_reg_i = '1') or (stall_pipeline_low_i = '0') else write_back_ctl;   
        
        instruction_fwd_d <= instruction_d when stall_pipeline_low_i = '1' else 
                             X"0000"; 
                             
        imm_fwd_d <= (instr_decoded_d.imm & X"00") when (instr_decoded_d.m_1 = '1') and (write_back_ctl_d.imm_op = '1') else
                     (X"00" & instr_decoded_d.imm) when (instr_decoded_d.m_1 = '0') and (write_back_ctl_d.imm_op = '1') else
                       X"0000"; 
                       
        ---------- Execute  
        ---------- Memory         
        out_port_enable_mem <= '1' when memory_ctl_mem.op_code_mem = OUT_OP else -- Ra to outport 
                               '0';
                               
        seg7_enable_mem <= '1' when memory_ctl_mem.op_code_mem = STORE and rd_data1_mem = x"FFF2" else -- Ra to outport 
                           '0';
        ---------- Write back 
        -- register file write data mux
        wr_data_d <= memory_data_wb when write_back_ctl_wb.wb_src = MEMORY_DATA else
                     alu_result_wb when write_back_ctl_wb.wb_src = ALU_RES else
                     imm_cat_wb when write_back_ctl_wb.wb_src = IMM_FWD else
                     std_logic_vector(unsigned(pc_current_wb) + 2) when write_back_ctl_wb.wb_src = RETURN_PC else
                     inport_fwd_wb when write_back_ctl_wb.wb_src = INPORT_FWD else
                     rd_data1_wb when write_back_ctl_wb.wb_src = MOV_REG else
                     X"0000";
                     
        --------------- Fetch/Memory Stage Modules -------------------                                     
        -- Fetch/Memory
        -- map display console signals
        display_fetch.s1_pc <= inst_addr_f;
        display_fetch.s1_inst <= instruction_f;
        mem: entity work.mem_manager
            port map (
                -- Shared ports
                clock => sys_clk,
                reset => sys_rst,
                -- Data memory - read/write  
                write_enable => memory_ctl_mem.memory_write,
                read_data_enable => memory_ctl_mem.memory_read,
                data_addr => rd_data1_mem,
                data_in => rd_data2_mem,
                data_out => memory_data_mem, 
                -- Instruction memory - read only
                inst_addr => inst_addr_f,
                inst_out => instruction_f, 
                -- Memory Mapped ports
                dip_switches => dip_switches,
                led_7seg_out => led_7seg_data_mem,
                video_data => video_data,
                display_data_addr => display_data_addr,
                display_enable => display_enable       
            ); 
            

                    
        -- Fetch          
        pc: entity work.program_counter
            port map (
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => stall_pipeline_low_i, 
                --write signals
                wr_instr_addr => pc_in_f, --: in std_logic_vector(15 downto 0);                
                --read signals
                rd_instr_addr => pc_out_f --: out std_logic_vector(15 downto 0);          
        );        

        -- Fetch
        adder_pc: entity work.adder
            port map (
                A => inst_addr_f,
                B => step_size_c,
                C => pc_next_f
            );
        
        rst_fetch_reg_f <= '1' when (sys_rst = '1') or (flush_f_reg_i = '1') else '0';
        -- Fetch    
        fetch_r: entity work.fetch_register
            port map ( 
                rst => rst_fetch_reg_f,
                clk => sys_clk,
                wr_enable => stall_pipeline_low_i,
                -- inputs
                wr_instruction => instruction_f, --: in std_logic_vector(15 downto 0);
                wr_pc => inst_addr_f,               
                -- outputs               
                rd_instruction => instruction_d, --: out std_logic_vector(15 downto 0);
                rd_pc => pc_current_d          
            ); 
            
        --------------- Decode Stage Modules ------------------- 
        display_decode.s2_pc <= pc_current_d;
        display_decode.s2_inst <= instruction_d;
        display_decode.s2_reg_a <= wr_index_d;
        display_decode.s2_reg_b <= rd_index1_d;
        display_decode.s2_reg_c <= rd_index2_d;
        -- display_decode.s2_reg_a_data <=
        display_decode.s2_reg_b_data <= rd_data1_d;
        display_decode.s2_reg_c_data <= rd_data2_d;
        display_decode.s2_immediate <= imm_fwd_d;       
        hazard_detect: entity work.hazard_detect_unit 
            port map (
                -- inputs 
                clk => sys_clk,
                rst => sys_rst, 
                -- Decode stage signals
                source_reg1 => rd_index1_d, 
                source_reg2 => rd_index2_d,
                op_code => instr_decoded_d.opcode,
                -- Execute stage signals
                branch_decision => pc_src_ex, -- active if taken
                mem_read => memory_ctl_ex.memory_read, 
                reg_write => write_back_ctl_ex.reg_write,
                dest_reg => wr_index_ex,                
                -- outputs
                flush_f_reg => flush_f_reg_i, --  : out std_logic := '0';
                flush_d_reg => flush_d_reg_i, --  : out std_logic := '0';
                flush_ex_reg => flush_ex_reg_i, --  : out std_logic := '0';
                stall_pipeline_low => stall_pipeline_low_i --  : out std_logic := '0'           
            );
                                      
        decoder: entity work.decoder
            port map (
                instr => instruction_d,   -- Input instruction
                instr_decoded => instr_decoded_d 
        );   
        
         
        -- Decode
        -- Instantiate the register_file
        Register_File_inst: entity work.register_file
            port map(
                -- inputs
                rst       => sys_rst,         -- Reset signal
                clk       => sys_clk,         -- Clock signal
                rd_index1 => rd_index1_d,          -- Read index 1 (rb from Decoder)
                rd_index2 => rd_index2_d,          -- Read index 2 (rc from Decoder)
                wr_index  => wr_index_wb,          -- Write index (ra from Decoder)
                wr_data   => wr_data_d,     -- Write data (ALU result or INPUT)
                wr_enable => write_back_ctl_wb.reg_write,    -- Write enable (controlled by op_code_f)
                -- outputs
                rd_data1  => rd_data1_d,    -- Read data 1 (rb value)
                rd_data2  => rd_data2_d,    -- Read data 2 (rc value)
                register_0 => display_register.register_0,
                register_1 => display_register.register_1, 
                register_2 => display_register.register_2, 
                register_3 => display_register.register_3, 
                register_4 => display_register.register_4, 
                register_5 => display_register.register_5, 
                register_6 => display_register.register_6, 
                register_7 => reg_7_d,
                
                o_flag_0 => display_register.register_0_of,
                o_flag_1 => display_register.register_1_of,
                o_flag_2 => display_register.register_2_of,
                o_flag_3 => display_register.register_3_of,
                o_flag_4 => display_register.register_4_of,
                o_flag_5 => display_register.register_5_of,
                o_flag_6 => display_register.register_6_of,
                o_flag_7 => display_register.register_7_of,
                
                of_flag => alu_o_wb
            );
                         
            display_register.register_7 <= reg_7_d;            
        -- Decode
        -- select, extend, and shift the displacement
        sign_extender: entity work.sign_extend
            port map(
                   op_code         =>  instr_decoded_d.opcode,  -- Opcode from Decode Stage
                   disp_l          =>  instr_decoded_d.disp_l,  -- Long displacement (for BRR)
                   disp_s          =>  instr_decoded_d.disp_s,  -- Short displacement (for BR)
                   extended_disp   =>  extended_disp_d  -- Short displacement (for BR)
            );
            
        rst_decode_reg_d <= '1' when sys_rst = '1' or flush_d_reg_i ='1' else '0';            
        -- Decode
        decode_r: entity work.decode_register
            port map (
                -- register control inputs 
                rst => rst_decode_reg_d,
                clk => sys_clk,
                wr_enable => '1', -- TODO hazard control 
                -- inputs
                wr_instruction => instruction_fwd_d,
                wr_pc => pc_current_d,
                -- register file
                wr_reg_data1 => rd_data1_d,
                wr_reg_data2 => rd_data2_d,
                wr_reg_write_index => wr_index_d,
                wr_extended_disp => extended_disp_d,
                wr_immidate => imm_fwd_d,
                wr_m_1 => instr_decoded_d.m_1,
                wr_inport_data => inport_fwd_d,
                wr_alu_shift => alu_shift_d,          
                -- contorller records
                wr_execute_ctl => execute_ctl_d,
                wr_memory_ctl => memory_ctl_d,
                wr_write_back_ctl => write_back_ctl_d,                
                -- outputs
                rd_instruction => instruction_ex,
                rd_pc => pc_current_ex,
                -- register file
                rd_reg_data1 => rd_data1_ex, -- to alu in1
                rd_reg_data2 => rd_data2_ex, -- to alu in2
                rd_reg_write_index => wr_index_ex,
                rd_extended_disp => extended_disp_ex,
                rd_immidate => imm_fwd_ex,
                rd_m_1 => m_1_ex,
                rd_inport_data => inport_fwd_ex,
                rd_alu_shift => alu_shift_ex,
                -- contorller records 
                rd_execute_ctl => execute_ctl_ex,
                rd_memory_ctl => memory_ctl_ex,
                rd_write_back_ctl => write_back_ctl_ex             
            );    -- instr_decoded_d.m_1 std_logic_vector(7 downto 0);
            
        --------------- Execute Stage Modules -------------------
        display_execute.s3_pc <= pc_current_ex;
        display_execute.s3_inst <= instruction_ex;
        display_execute.s3_reg_a <= wr_index_ex;
      -- display_execute.s3_reg_b <= 
      -- display_execute.s3_reg_c <=
      -- display_execute.s3_reg_a_data <= alu_result_ex;
        display_execute.s3_reg_b_data <= rd_data1_ex;
        display_execute.s3_reg_c_data <= rd_data2_ex;
        display_execute.s3_immediate <= imm_fwd_ex;
        display_execute.s3_r_wb <= write_back_ctl_ex.reg_write;
        display_execute.s3_r_wb_data <= alu_result_ex;
        display_execute.s3_br_wb <= pc_src_ex;
        display_execute.s3_br_wb_address <= pc_branch_addr_ex;
        display_execute.s3_mr_wr <= memory_ctl_ex.memory_write;
        display_execute.s3_mr_wr_address <= rd_data1_ex;
        display_execute.s3_mr_wr_data <= rd_data2_ex;
        display_execute.s3_mr_rd <= memory_ctl_ex.memory_read;
        display_execute.s3_mr_rd_address <= rd_data1_ex;
        display_execute.zero_flag <= alu_z_ex;
        display_execute.negative_flag <= alu_n_ex;
        display_execute.overflow_flag <= alu_o_ex; -- todo IMPLEMENT
        -- Execute
        -- Instantiate the ALU
        ALU_inst: entity work.ALU
            port map(
                -- inputs
                in1          => rd_data1_ex,      -- ALU input 1 
                in2          => rd_data2_ex,      -- ALU input 2 
                shift        => alu_shift_ex,        -- Shift amount (from Decoder)
                alu_mode     => execute_ctl_ex.alu_op,       -- ALU opcode (from Decoder)
                -- outputs
                alu_out      => alu_result_ex,      -- ALU result                               
                negative_flag => alu_n_ex, -- Negative flag
                zero_flag    => alu_z_ex,    -- Zero flag
                overflow_flag => alu_o_ex
            );
        -- Execute     
        branch_unit: entity work.branch_unit
                port map(
                -- Inputs
                op_code         => memory_ctl_ex.op_code_mem,--in std_logic_vector(6 downto 0);  -- Opcode from Decode Stage
                pc_current      => pc_current_ex,--in word_t;  -- Current PC value
                reg_data        => rd_data1_ex,--in word_t;  -- Data from register (for BR instructions)
                displacement    => extended_disp_ex,
                alu_n           => alu_n_mem,--in std_logic;  -- Negative flag from ALU
                alu_z           => alu_z_mem,--in std_logic;  -- Zero flag from ALU        
                -- Outputs
                branch_taken    => pc_src_ex,--out std_logic;  -- Branch taken signal
                branch_target   => pc_branch_addr_ex--out word_t  -- Calculated branch target address            
                );
        -- Execute   
        execute_r: entity work.execute_register
            port map(
            rst => sys_rst,
            clk => sys_clk,
            wr_enable => '1', -- TODO hazard control
            wr_instruction => instruction_ex,
            wr_pc => pc_current_ex,
            -- alu
            wr_alu_result => alu_result_ex,
            wr_alu_z => alu_z_ex,
            wr_alu_n => alu_n_ex,
            wr_alu_o => alu_o_ex,
            -- register file
            wr_reg_data1 => rd_data1_ex,
            wr_reg_data2 => rd_data2_ex,
            wr_reg_write_index => wr_index_ex,
            wr_immidate => imm_fwd_ex,
            wr_m_1 => m_1_ex,
            wr_inport_data => inport_fwd_ex,           
            -- contorller records
            wr_memory_ctl => memory_ctl_ex,
            wr_write_back_ctl => write_back_ctl_ex,
            
            -- outputs
            rd_instruction => instruction_mem,
            rd_pc => pc_current_mem,
            -- alu
            rd_alu_result => alu_result_mem,
            rd_alu_z => alu_z_mem,
            rd_alu_n => alu_n_mem,
            rd_alu_o => alu_o_mem,
            -- register file
            rd_reg_data1 => rd_data1_mem, -- to alu in1
            rd_reg_data2 => rd_data2_mem, -- to alu in2
            rd_reg_write_index => wr_index_mem,
            rd_immidate => imm_fwd_mem,
            rd_m_1 => m_1_mem,
            rd_inport_data => inport_fwd_mem,
            -- contorller records 
            rd_memory_ctl => memory_ctl_mem,
            rd_write_back_ctl => write_back_ctl_mem            
            );
            
        --------------- Memory Stage Modules ---------------- 
        display_memory.s4_pc <= pc_current_mem;
        display_memory.s4_inst <= instruction_mem;
        display_memory.s4_reg_a <= wr_index_mem;
        display_memory.s4_r_wb <= write_back_ctl_mem.reg_write;
        display_memory.s4_r_wb_data <=  memory_data_mem when write_back_ctl_mem.wb_src = MEMORY_DATA else
                                        alu_result_mem when write_back_ctl_mem.wb_src = ALU_RES else
                                        imm_fwd_mem when write_back_ctl_mem.wb_src = IMM_FWD else
                                        std_logic_vector(unsigned(pc_current_mem) + 2) when write_back_ctl_mem.wb_src = RETURN_PC else
                                        inport_fwd_mem when write_back_ctl_mem.wb_src = INPORT_FWD else
                                        rd_data1_mem when write_back_ctl_mem.wb_src = MOV_REG else
                                        X"0000";
        
        out_r: entity work.out_register
            port map (                
                clk => sys_clk,
                rst => sys_rst,
                wr_data => rd_data1_mem,
                wr_enable => out_port_enable_mem,
                -- out puts
                rd_data => out_port           
            );
            
        seg7_r: entity work.out_register
            port map (                
                clk => sys_clk,
                rst => sys_rst,
                wr_data => led_7seg_data_mem,
                wr_enable => seg7_enable_mem,
                -- out puts
                rd_data => led_7seg_data           
            );                                                      
        mem_r: entity work.memory_register
            port map(
                -- inputs
                rst => sys_rst,
                clk => sys_clk,
                wr_enable => '1', -- TODO hazard control
                wr_pc => pc_current_mem,
                -- alu
                wr_alu_result => alu_result_mem,
                wr_alu_o => alu_o_mem,
                -- register file
                wr_reg_data1 => rd_data1_mem,
                wr_mem_data => memory_data_mem,
                wr_reg_write_index => wr_index_mem,
                -- TODO add displacement
                wr_immidate => imm_fwd_mem,
                wr_m_1 => m_1_mem, 
                wr_inport_data => inport_fwd_mem,          
                -- contorller records
                wr_write_back_ctl => write_back_ctl_mem, 
                          
                -- outputs
                rd_pc => pc_current_wb,
                -- alu
                rd_alu_result => alu_result_wb,
                rd_alu_o => alu_o_wb,
                -- register file
                rd_reg_data1 => rd_data1_wb,
                rd_mem_data => memory_data_wb,       
                rd_reg_write_index => wr_index_wb,
                -- 
                rd_immidate => imm_fwd_wb,
                rd_m_1 => m_1_wb,
                rd_inport_data => inport_fwd_wb,
                -- contorller records 
                rd_write_back_ctl => write_back_ctl_wb            
            );
            --------------- Write back Stage Modules ----------------
            -- wb
            -- concatonate imm_upper and imm_lower    
            immconcat: entity work.immediate_concatenator 
                port map(
                    rst          => sys_rst,         -- Reset signal
                    clk          => sys_clk,         -- Clock signal
--                    wr_enable    => write_back_ctl_wb.reg_write,
--                    imm_wb_index => wr_index_wb,
                    imm_r7_in    => reg_7_d,
                    imm_op       => write_back_ctl_wb.imm_op,
                    imm_mode     => m_1_wb, 
                    imm_in       => imm_fwd_wb,
                    imm_out      => imm_cat_wb          
                );
                
end data_path_arch ;