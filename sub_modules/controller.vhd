-- controller
library ieee ;
use ieee.std_logic_1164.all ;
use work.cpu_types.all;

entity controller is
    port (
    -- inputs    
    clk : in std_logic;
    reset_ex: in std_logic;
    reset_ld: in std_logic;
    op_code : in op_code_t;
    -- outputs
    sys_rst : out std_logic;
    boot_mode : out boot_mode_type := BOOT_LOAD;
    decode_ctl : out decode_type := decode_type_init_c;
    execute_ctl : out execute_type := execute_type_init_c; 
    memory_ctl : out memory_type := memory_type_init_c;   
    write_back_ctl : out write_back_type := write_back_type_init_c 
    );
    end controller ;
-- RESET_STATE, BOOT_STATE, NOP_STATE, A1_STATE, A2_STATE, A3_STATE, B1_STATE, B2_STATE, RETURN_STATE, L1_LOAD_IMM_STATE, L2_LOAD_STATE, L2_STORE_STATE
architecture controller_arch of controller is    
    signal state : ctrl_state_type := RESET_STATE;
    signal nextstate : ctrl_state_type := BOOT_STATE;
    signal op_code_i : op_code_t := (others=>'1'); -- start at an invalid op code   
begin
    -- Update state
    nextstate <=    BOOT_STATE when state = RESET_STATE else
                    NOP_STATE when  op_code_i = NOP else
                    A1_STATE when ( op_code_i = ADD or
                                    op_code_i = SUB or
                                    op_code_i = MUL or
                                    op_code_i = NAND_OP )else
                    A2_STATE when ( op_code_i = SHL_OP or
                                    op_code_i = SHR_OP ) else
                    A3_STATE when ( op_code_i = TEST or
                                    op_code_i = IN_OP or
                                    op_code_i = OUT_OP ) else                                                
                    B1_STATE when ( op_code_i = BRR or
                                    op_code_i = BRR_N or 
                                    op_code_i = BRR_Z ) else 
                    B2_STATE when ( op_code_i = BR or
                                    op_code_i = BR_N or
                                    op_code_i = BR_Z or
                                    op_code_i = BR_SUB) else 
                    RETURN_STATE when op_code_i = RETURN_OP else                    
                    L1_LOAD_IMM_STATE when op_code_i = LOADIMM else
                    L2_LOAD_STATE when op_code_i = LOAD else
                    L2_STORE_STATE when op_code_i = STORE else
                    RESET_STATE; -- Clear all outputs
    -- state register    
    process (clk, reset_ex, reset_ld)
        begin
        -- check reset
        if (reset_ld = '1') or (reset_ex  = '1') then state <= RESET_STATE; -- Asynchronous
        -- update state    
        elsif rising_edge(clk) then    
            state <= nextstate; -- Synchronous  
        end if;    
    end process;
  
    -- controller outputs  
    -- RESET STATE        
    sys_rst <= '1' when state = RESET_STATE else
            '0';
    op_code_i <= (others=>'1') when state = RESET_STATE else
                  op_code;
    decode_ctl <= decode_type_init_c when state = RESET_STATE;  
    execute_ctl <= execute_type_init_c when state = RESET_STATE;
    memory_ctl <= memory_type_init_c when state = RESET_STATE;  
    write_back_ctl <= write_back_type_init_c when state = RESET_STATE;
    -- BOOT STATE
    boot_mode <= BOOT_EXECUTE when (state = RESET_STATE) and (reset_ex = '1') else
                 BOOT_LOAD when (state = RESET_STATE) and (reset_ld = '1') else
                 RUN;
   -- RESET_STATE, BOOT_STATE, NOP_STATE, A1_STATE, A2_STATE, A3_STATE, B1_STATE, B2_STATE, RETURN_STATE, L1_LOAD_IMM_STATE, L2_LOAD_STATE, L2_STORE_STATE
     
    decode_ctl.reg_src <= '0' when state = A1_STATE else
                          '0' when state = A2_STATE else
                          '0' when state = A3_STATE else
                          '0' when state = B1_STATE else                              
                          '0' when state = B2_STATE else
                          '0' when state = RETURN_STATE else
                          '0' when state = L1_LOAD_IMM_STATE else
                          '0' when state = L2_LOAD_STATE else
                          '0' when state = L2_STORE_STATE else
                          '0';
                              
    decode_ctl.reg_dst <= '0' when state = A1_STATE else
                            '0' when state = A2_STATE else
                            '0' when state = A3_STATE else
                            '0' when state = B1_STATE else                              
                            '0' when state = B2_STATE else
                            '0' when state = RETURN_STATE else
                            '0' when state = L1_LOAD_IMM_STATE else
                            '0' when state = L2_LOAD_STATE else
                            '0' when state = L2_STORE_STATE else
                            '0';
    
    execute_ctl.alu_op <= "0" when state = A1_STATE else
                          "0" when state = A2_STATE else
                          "0" when state = A3_STATE else
                          "0" when state = B1_STATE else                              
                          "0" when state = B2_STATE else
                          "0" when state = RETURN_STATE else
                          "0" when state = L1_LOAD_IMM_STATE else
                          "0" when state = L2_LOAD_STATE else
                          "0" when state = L2_STORE_STATE else
                          "0";
    
    execute_ctl.alu_src <= '0' when state = A1_STATE else
                              '0' when state = A2_STATE else
                              '0' when state = A3_STATE else
                              '0' when state = B1_STATE else                              
                              '0' when state = B2_STATE else
                              '0' when state = RETURN_STATE else
                              '0' when state = L1_LOAD_IMM_STATE else
                              '0' when state = L2_LOAD_STATE else
                              '0' when state = L2_STORE_STATE else
                              '0';
    
    memory_ctl.branch_n <= '0' when state = A1_STATE else
                            '0' when state = A2_STATE else
                            '0' when state = A3_STATE else
                            '0' when state = B1_STATE else                              
                            '0' when state = B2_STATE else
                            '0' when state = RETURN_STATE else
                            '0' when state = L1_LOAD_IMM_STATE else
                            '0' when state = L2_LOAD_STATE else
                            '0' when state = L2_STORE_STATE else
                            '0';
    memory_ctl.branch_z <= '0' when state = A1_STATE else
                              '0' when state = A2_STATE else
                              '0' when state = A3_STATE else
                              '0' when state = B1_STATE else                              
                              '0' when state = B2_STATE else
                              '0' when state = RETURN_STATE else
                              '0' when state = L1_LOAD_IMM_STATE else
                              '0' when state = L2_LOAD_STATE else
                              '0' when state = L2_STORE_STATE else
                              '0';
    memory_ctl.memory_read <='0' when state = A1_STATE else
                                '0' when state = A2_STATE else
                                '0' when state = A3_STATE else
                                '0' when state = B1_STATE else                              
                                '0' when state = B2_STATE else
                                '0' when state = RETURN_STATE else
                                '0' when state = L1_LOAD_IMM_STATE else
                                '0' when state = L2_LOAD_STATE else
                                '0' when state = L2_STORE_STATE else
                                '0';
    memory_ctl.memory_write <= '0' when state = A1_STATE else
                                  '0' when state = A2_STATE else
                                  '0' when state = A3_STATE else
                                  '0' when state = B1_STATE else                              
                                  '0' when state = B2_STATE else
                                  '0' when state = RETURN_STATE else
                                  '0' when state = L1_LOAD_IMM_STATE else
                                  '0' when state = L2_LOAD_STATE else
                                  '0' when state = L2_STORE_STATE else
                                  '0';
    
    write_back_ctl.mem_to_reg <= '0' when state = A1_STATE else
                                    '0' when state = A2_STATE else
                                    '0' when state = A3_STATE else
                                    '0' when state = B1_STATE else                              
                                    '0' when state = B2_STATE else
                                    '0' when state = RETURN_STATE else
                                    '0' when state = L1_LOAD_IMM_STATE else
                                    '0' when state = L2_LOAD_STATE else
                                    '0' when state = L2_STORE_STATE else
                                    '0';
    write_back_ctl.reg_write <= '0' when state = A1_STATE else
                                  '0' when state = A2_STATE else
                                  '0' when state = A3_STATE else
                                  '0' when state = B1_STATE else                              
                                  '0' when state = B2_STATE else
                                  '0' when state = RETURN_STATE else
                                  '0' when state = L1_LOAD_IMM_STATE else
                                  '0' when state = L2_LOAD_STATE else
                                  '0' when state = L2_STORE_STATE else
                                  '0'; 

end controller_arch ;