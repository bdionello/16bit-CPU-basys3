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
-- RESET_STATE, NOP, ALU_OP, BRANCH, RETURN_OP, LOAD, STORE
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
     -- controller outputs
--    case state is
     
--        when RESET =>         
--            reg_dst <= '0';
--            branch <= '0';
--            ram_mem_rd <= '0';
--            ram_mem_to_reg <= '0';
--            rom_mem_rd <=  '0';
--            rom_mem_to_reg <= '0';
--            alu_op <= "000";
--            ram_mem_wr <= '0';
--            rom_mem_wr <= '0';
--            alu_src <= '0';
--            reg_wr <= '0';
--            nextstate <= DECODE;            
--            when DECODE =>
--                nextstate <= RESET;
--            when others =>
--                nextstate <= RESET;                           
--    end case;
end controller_arch ;