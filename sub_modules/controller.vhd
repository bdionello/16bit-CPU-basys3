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
    execute_ctl : out execute_type := execute_type_init_c; 
    memory_ctl : out memory_type := memory_type_init_c;   
    write_back_ctl : out write_back_type := write_back_type_init_c 
    );
    end controller ;
-- RESET_STATE, NOP_STATE, ALU_STATE, BRANCH_STATE, RETURN_OP_STATE, LOAD_STATE, STORE_STATE
architecture controller_arch of controller is    
    signal state, nextstate: ctrl_state_type;
        
begin
    -- state register
    process (clk, reset_ex, reset_ld)
        begin
        -- Reset load means ROM mode
        -- Reset Execute means RAM mode
        if (reset_ld = '1') or (reset_ex  = '1') then state <= RESET_STATE;    
        elsif clk'event and clk = '1' then    
            state <= nextstate;    
        end if;    
    end process;
    -- Update state
    nextstate <= NOP_STATE when op_code = NOP else
                 ALU_STATE when (op_code = ADD or
                                 op_code = SUB or
                                 op_code = MUL or
                                 op_code = NAND_OP or
                                 op_code = SHL_OP or
                                 op_code = TEST) else
                 BRANCH_STATE when (op_code = BRR or
                                    op_code = BRR_N or 
                                    op_code = BRR_Z or
                                    op_code = BR or
                                    op_code = BR_N or
                                    op_code = BR_Z or
                                    op_code = BR_SUB) else 
                 RETURN_OP_STATE when op_code = RETURN_OP else
                 LOAD_STATE when op_code = LOAD else
                 STORE_STATE when op_code = STORE else
                 RESET_STATE;
     -- controller outputs
          
     sys_rst <= '1' when state = RESET_STATE else
                '0'; 
     execute_ctl <= execute_type_init_c when state = RESET_STATE;
     memory_ctl <= memory_type_init_c when state = RESET_STATE;  
     write_back_ctl <= write_back_type_init_c when state = RESET_STATE;
     
end controller_arch ;