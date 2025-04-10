-- subtype and constants used in design
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

package cpu_types is
    type alu_op_type is (alu_NOP, alu_ADD, alu_SUB, alu_MUL, alu_NAND, alu_SHL, alu_SHR, alu_TEST); 
    type wb_src_type is (ALU_RES, MEMORY_DATA, RETURN_PC, IMM_FWD, INPORT_FWD, MOV_REG, NONE);
    type boot_mode_type is (BOOT_LOAD, BOOT_EXECUTE, RUN);
    type ctrl_state_type is (IDLE_STATE, RESET_LD_STATE, RESET_EX_STATE, BOOT_LD_STATE, BOOT_EX_STATE, NOP_STATE, A1_STATE, A2_STATE, A3_STATE, B1_STATE, B2_STATE, RETURN_STATE, L1_LOAD_IMM_STATE, L2_LOAD_STATE, L2_STORE_STATE, L2_MOV_STATE);
    subtype word_t is std_logic_vector(15 downto 0); -- 2 bytes word = 16 bits
    subtype op_code_t is std_logic_vector(6 downto 0);
    subtype alu_op_t is std_logic_vector(2 downto 0);
    
    -- Record types
    type decode_type is record
        reg_src : std_logic;
        reg_dst : std_logic;                
    end record decode_type;
        
    type execute_type is record
        alu_op : alu_op_type;
       -- alu_src : std_logic;        
    end record execute_type;

    type memory_type is record
        op_code_mem : op_code_t;  
        memory_read : std_logic;
        memory_write : std_logic;  
    end record memory_type;

    type write_back_type is record
        wb_src : wb_src_type;    
        reg_write : std_logic;
        imm_op : std_logic;   
    end record write_back_type;
    
    type instruction_type is record
        opcode       :  std_logic_vector(6 downto 0);  -- Opcode
        ra           :  std_logic_vector(2 downto 0);  -- Register A
        rb           :  std_logic_vector(2 downto 0);  -- Register B
        rc           :  std_logic_vector(2 downto 0);  -- Register C
        shift        :  std_logic_vector(3 downto 0);  -- Shift amount
        
        disp_s       :  std_logic_vector(5 downto 0);  -- Displacement (short)
        disp_l       :  std_logic_vector(8 downto 0);  -- Displacement (long)
        
        m_1          :  std_logic;                     -- Mode bit
        in_port_ctl  :  std_logic;                     -- Control line for IN inst. mux
        out_port_ctl :  std_logic;                     -- Control line for OUT inst. mux
        imm          :  std_logic_vector(7 downto 0);  -- Immediate value
        
        r_dest       :  std_logic_vector(2 downto 0);  -- Destination register
        r_src        :  std_logic_vector(2 downto 0);  -- Source register    
    end record instruction_type;
    
    type display_fetch_type is record
        s1_pc   :  STD_LOGIC_VECTOR ( 15 downto 0 );
        s1_inst :  STD_LOGIC_VECTOR ( 15 downto 0 );    
    end record display_fetch_type;
    
    constant display_fetch_type_init_c : display_fetch_type := ( s1_pc => (others => '0'),
                                                               s1_inst => (others => '0')
                                                               );                                                               
    type display_decode_type is record
        s2_pc         :  STD_LOGIC_VECTOR ( 15 downto 0 );
        s2_inst       :  STD_LOGIC_VECTOR ( 15 downto 0 );      
        s2_reg_a      :  STD_LOGIC_VECTOR( 2 downto 0 );
        s2_reg_b      :  STD_LOGIC_VECTOR( 2 downto 0 );
        s2_reg_c      :  STD_LOGIC_VECTOR( 2 downto 0 );      
       -- s2_reg_a_data :  STD_LOGIC_VECTOR( 15 downto 0 );
        s2_reg_b_data :  STD_LOGIC_VECTOR( 15 downto 0 );
        s2_reg_c_data :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s2_immediate  :  STD_LOGIC_VECTOR( 15 downto 0 );    
    end record display_decode_type;
    
    type display_execute_type is record
        s3_pc         :  STD_LOGIC_VECTOR ( 15 downto 0 );
        s3_inst       :  STD_LOGIC_VECTOR ( 15 downto 0 );      
        s3_reg_a      :  STD_LOGIC_VECTOR( 2 downto 0 );
    --  s3_reg_b      :  STD_LOGIC_VECTOR( 2 downto 0 );
    --  s3_reg_c      :  STD_LOGIC_VECTOR( 2 downto 0 );      
    --  s3_reg_a_data :  STD_LOGIC_VECTOR( 15 downto 0 );
        s3_reg_b_data :  STD_LOGIC_VECTOR( 15 downto 0 );
        s3_reg_c_data :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s3_immediate  :  STD_LOGIC_VECTOR( 15 downto 0 );
        s3_r_wb          :  STD_LOGIC;
        s3_r_wb_data     :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s3_br_wb         :  STD_LOGIC;
        s3_br_wb_address :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s3_mr_wr         :  STD_LOGIC;
        s3_mr_wr_address :  STD_LOGIC_VECTOR( 15 downto 0 );
        s3_mr_wr_data    :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s3_mr_rd         :  STD_LOGIC;
        s3_mr_rd_address :  STD_LOGIC_VECTOR( 15 downto 0 );
        zero_flag     :  STD_LOGIC;
        negative_flag :  STD_LOGIC;
        overflow_flag :  STD_LOGIC;
    end record display_execute_type;
        
    type display_memory_type is record
        s4_pc        :  STD_LOGIC_VECTOR( 15 downto 0 );
        s4_inst      :  STD_LOGIC_VECTOR( 15 downto 0 );      
        s4_reg_a     :  STD_LOGIC_VECTOR( 2 downto 0 );      
        s4_r_wb      :  STD_LOGIC;
        s4_r_wb_data :  STD_LOGIC_VECTOR( 15 downto 0 );  
    end record display_memory_type;    
    
    type display_register_type is record
        register_0    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_1    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_2    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_3    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_4    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_5    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_6    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_7    :  STD_LOGIC_VECTOR ( 15 downto 0 );
        register_0_of :  STD_LOGIC;
        register_1_of :  STD_LOGIC;
        register_2_of :  STD_LOGIC;
        register_3_of :  STD_LOGIC;
        register_4_of :  STD_LOGIC;
        register_5_of :  STD_LOGIC;
        register_6_of :  STD_LOGIC;
        register_7_of :  STD_LOGIC;   
    end record display_register_type;
    
    
    -- Initalization constants for record types
    constant instruction_type_init_c : instruction_type := (opcode => (others => '0'),
                                                            ra => (others => '0'),
                                                            rb => (others => '0'),
                                                            rc => (others => '0'),
                                                            shift => (others => '0'),
                                                            disp_s => (others => '0'),
                                                            disp_l => (others => '0'),
                                                            in_port_ctl => '0',
                                                            out_port_ctl => '0',
                                                            m_1 => '0',
                                                            imm => (others => '0'),
                                                            r_dest => (others => '0'),
                                                            r_src => (others => '0') );
                                                            
    constant decode_type_init_c : decode_type := ( reg_src => '0',
                                                   reg_dst => '0');
                                                        
    constant execute_type_init_c : execute_type := ( alu_op => alu_NOP ) ;                                                     
                                                     --alu_src => '0');
                                                     
    constant memory_type_init_c : memory_type := ( op_code_mem => (others => '0'),  
                                                   memory_read => '0', 
                                                   memory_write => '0');
                                                     
    constant write_back_type_init_c : write_back_type := ( wb_src  => NONE,    
                                                           reg_write  => '0',
                                                           imm_op => '0');  
                                                             
    constant step_size_c : word_t := X"0002";           
    -- ALU Operations
    constant NOP      : op_code_t := "0000000";
    constant ADD      : op_code_t := "0000001";
    constant SUB      : op_code_t := "0000010";
    constant MUL      : op_code_t := "0000011";
    constant NAND_OP  : op_code_t := "0000100";
    constant SHL_OP   : op_code_t := "0000101";
    constant SHR_OP   : op_code_t := "0000110";
    constant TEST     : op_code_t := "0000111";
    constant OUT_OP   : op_code_t := "0100000";
    constant IN_OP    : op_code_t := "0100001";
    
    -- Branch Operations
    constant BRR      : op_code_t := "1000000";
    constant BRR_N    : op_code_t := "1000001";
    constant BRR_Z    : op_code_t := "1000010";
    constant BR       : op_code_t := "1000011";
    constant BR_N     : op_code_t := "1000100";
    constant BR_Z     : op_code_t := "1000101";
    constant BR_SUB   : op_code_t := "1000110";
    constant RETURN_OP: op_code_t := "1000111";

    -- Load/Store Operations
    constant LOAD     : op_code_t := "0010000";
    constant STORE    : op_code_t := "0010001";
    constant LOADIMM  : op_code_t := "0010010";
    constant MOV      : op_code_t := "0010011";

end cpu_types ;