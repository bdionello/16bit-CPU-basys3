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
    wr_enable: in std_logic;
    op_code : in op_code_t;
    -- outputs
    sys_rst : out std_logic;
    boot_mode : out boot_mode_type;
    decode_ctl : out decode_type;
    execute_ctl : out execute_type; 
    memory_ctl : out memory_type;   
    write_back_ctl : out write_back_type 
    );
    end controller ;
-- RESET_STATE, BOOT_STATE, NOP_STATE, A1_STATE, A2_STATE, A3_STATE, B1_STATE, B2_STATE, RETURN_STATE, L1_LOAD_IMM_STATE, L2_LOAD_STATE, L2_STORE_STATE, L2_MOV_STATE
architecture controller_arch of controller is    
    signal state       : ctrl_state_type := IDLE_STATE;
    signal nextstate   : ctrl_state_type;
    signal op_code_i   : op_code_t;
    signal state_code  : op_code_t := (others=>'0');

begin
    op_code_i <= op_code; -- connect port to internal
    -- Update state
    nextstate <=    IDLE_STATE when state = IDLE_STATE else
                    BOOT_LD_STATE when (state = RESET_LD_STATE) else
                    BOOT_EX_STATE when (state = RESET_EX_STATE) else
                    NOP_STATE when  (op_code_i = NOP) else
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
                    L2_MOV_STATE when op_code_i = MOV else
                    IDLE_STATE; -- Clear all outputs
    -- state register    
    process (clk, reset_ex, reset_ld)
        begin
            -- update state    
            if rising_edge(clk) then
                -- check reset
                if (reset_ex = '1') then
                    state <= RESET_EX_STATE;
                    state_code <= (others=> '0');
                elsif (reset_ld = '1') then
                    state <= RESET_LD_STATE;
                    state_code <= (others=> '0');
                elsif(wr_enable='1') then    
                    state <= nextstate; -- Synchronous 
                    state_code <= op_code_i;  
                end if;                
            end if;           
    end process;  
    -- controller outputs  
    -- RESET STATE        
    sys_rst <= '1' when (state = RESET_LD_STATE) OR (state = RESET_EX_STATE) OR (state = IDLE_STATE) else '0';
                                                                          
    boot_mode <= BOOT_LOAD when state = BOOT_LD_STATE else
                 BOOT_EXECUTE when state = BOOT_EX_STATE else
                 RUN;
                 
   -- All states: RESET_STATE, BOOT_STATE, NOP_STATE, A1_STATE, A2_SATE, A3_STATE, B1_STATE, B2_STATE, RETURN_STATE, L1_LOAD_IMM_STATE, L2_LOAD_STATE, L2_STORE_STATE
    -- 0 for (ra <- rb op rc), 1 for (ra <- ra op rb)  
    decode_ctl.reg_src <= '0' when state = A1_STATE else
                          '1' when state = A2_STATE else
                          '1' when state = A3_STATE else
                          '1' when state = B1_STATE else                              
                          '1' when state = B2_STATE else
                          '1' when state = RETURN_STATE else
                          '1' when state = L1_LOAD_IMM_STATE else
                          '1' when state = L2_LOAD_STATE else
                          '1' when state = L2_STORE_STATE else
                          '1' when state = L2_MOV_STATE else
                          '1';
                          
    -- 0 for (ra <- data) 1 for ( r7 <- data)                         
    decode_ctl.reg_dst <=   '0' when state = A1_STATE else
                            '0' when state = A2_STATE else
                            '0' when state = A3_STATE else
                            '0' when state = B1_STATE else                              
                            '1' when state = B2_STATE and (state_code = BR_SUB) else
                            '0' when state = RETURN_STATE else
                            '1' when state = L1_LOAD_IMM_STATE else
                            '0' when state = L2_LOAD_STATE else
                            '0' when state = L2_STORE_STATE else
                            '0' when state = L2_MOV_STATE else
                            '0';
                            
    decode_ctl.imm_op  <= '0' when state = A1_STATE else
                          '0' when state = A2_STATE else
                          '0' when state = A3_STATE else
                          '0' when state = B1_STATE else                              
                          '0' when state = B2_STATE else
                          '0' when state = RETURN_STATE else
                          '1' when state = L1_LOAD_IMM_STATE else
                          '0' when state = L2_LOAD_STATE else
                          '0' when state = L2_STORE_STATE else
                          '0' when state = L2_MOV_STATE else
                          '0';
                                                      
    -- alu_NOP, alu_ADD, alu_SUB, alu_MUL, alu_NAND, alu_SHL, alu_SHR, alu_TEST
    execute_ctl.alu_op <= alu_NOP when state = NOP_STATE else
                          alu_ADD when state = A1_STATE AND (state_code = ADD) else
                          alu_SUB when state = A1_STATE AND (state_code = SUB) else
                          alu_MUL when state = A1_STATE AND (state_code = MUL) else
                          alu_NAND when state = A1_STATE AND (state_code = NAND_OP) else
                          alu_SHL when state = A2_STATE AND (state_code = SHL_OP) else
                          alu_SHR when state = A2_STATE AND (state_code = SHR_OP) else
                          alu_TEST when state = A3_STATE AND (state_code = TEST) else
                          alu_NOP when state = B1_STATE else                              
                          alu_NOP when state = B2_STATE else
                          alu_NOP when state = RETURN_STATE else
                          alu_NOP when state = L1_LOAD_IMM_STATE else
                          alu_NOP when state = L2_LOAD_STATE else
                          alu_NOP when state = L2_STORE_STATE else
                          alu_NOP when state = L2_MOV_STATE else
                          alu_NOP;
                          
   -- do we need this? switch the input to alu IN2 ( based on MIPS ) alu_shift
--    execute_ctl.alu_src <= '0' when state = A1_STATE else
--                           '0' when state = A2_STATE else
--                           '0' when state = A3_STATE else
--                           '0' when state = B1_STATE else                              
--                           '0' when state = B2_STATE else
--                           '0' when state = RETURN_STATE else
--                           '0' when state = L1_LOAD_IMM_STATE else
--                           '0' when state = L2_LOAD_STATE else
--                           '0' when state = L2_STORE_STATE else
--                           '0';       
                           
    memory_ctl.op_code_mem <= (others => '0') when (state = RESET_LD_STATE) OR (state = RESET_EX_STATE) else
                              state_code;                              
                           
    memory_ctl.memory_read <= '0' when state = A1_STATE else
                              '0' when state = A2_STATE else
                              '0' when state = A3_STATE else
                              '0' when state = B1_STATE else                              
                              '0' when state = B2_STATE else
                              '0' when state = RETURN_STATE else
                              '0' when state = L1_LOAD_IMM_STATE else
                              '1' when state = L2_LOAD_STATE else
                              '0' when state = L2_STORE_STATE else
                              '0' when state = L2_MOV_STATE else
                              '0';
                              
    memory_ctl.memory_write <= '0' when state = A1_STATE else
                               '0' when state = A2_STATE else
                               '0' when state = A3_STATE else
                               '0' when state = B1_STATE else                              
                               '0' when state = B2_STATE else
                               '0' when state = RETURN_STATE else
                               '0' when state = L1_LOAD_IMM_STATE else
                               '0' when state = L2_LOAD_STATE else
                               '1' when state = L2_STORE_STATE else
                               '0' when state = L2_MOV_STATE else
                               '0';
                               
    -- ALU_RES, MEMORY_DATA, RETURN_PC, IMM_FWD
    write_back_ctl.wb_src <= ALU_RES when state = A1_STATE else
                             ALU_RES when state = A2_STATE else
                             ALU_RES when state = A3_STATE and (state_code = TEST) else
                             INPORT_FWD when state = A3_STATE and (state_code = IN_OP) else
                             NONE when state = B1_STATE else                              
                             RETURN_PC when state = B2_STATE and (state_code = BR_SUB) else
                             NONE when state = RETURN_STATE else
                             IMM_FWD when state = L1_LOAD_IMM_STATE else
                             MEMORY_DATA when state = L2_LOAD_STATE else
                             NONE when state = L2_STORE_STATE else
                             MOV_REG when state = L2_MOV_STATE else 
                             NONE;
                             
    write_back_ctl.reg_write <= '1' when state = A1_STATE else
                                '1' when state = A2_STATE else
                                '1' when state = A3_STATE and (state_code = IN_OP) else
                                '0' when state = B1_STATE else                              
                                '1' when state = B2_STATE and (state_code = BR_SUB) else
                                '0' when state = RETURN_STATE else
                                '1' when state = L1_LOAD_IMM_STATE else
                                '1' when state = L2_LOAD_STATE else
                                '0' when state = L2_STORE_STATE else
                                '1' when state = L2_MOV_STATE else
                                '0'; 
end controller_arch ;