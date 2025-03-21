library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types.all;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detect_unit is
    port (
        -- inputs    
        clk             : in std_logic := '0'; 
        -- decode stage signals       
        source_reg1     : in std_logic_vector(2 downto 0) := (others=>'0'); 
        source_reg2     : in std_logic_vector(2 downto 0) := (others=>'0'); 
        op_code         : in op_code_t;
        -- execute stage signals
        mem_read        : in std_logic := '0';        
        reg_write       : in std_logic := '0';
        branch_decision : in std_logic := '0'; -- from execute stage 
        dest_reg        : in std_logic_vector(2 downto 0) := (others=>'0');
        -- outputs
        flush_f_reg : out std_logic := '0';
        flush_d_reg : out std_logic := '0';
        flush_ex_reg : out std_logic := '0';                        
        stall_pipeline_low : out std_logic := '1' -- active Low               
        );
        
end hazard_detect_unit;

architecture Behavioral of hazard_detect_unit is
   
begin 
  
    hazard_control: process (clk, branch_decision, op_code)
        variable count : natural range 0 to 10 := 0;           
    begin
        -- branch taken, flush pipeline
        if (branch_decision = '1') then
          stall_pipeline_low <= '1';
          flush_f_reg <= '1';
          flush_d_reg <= '1';          
        end if;
        -- stall counter control
        if rising_edge(clk) then                                              
            if count <= 0 then -- resume 
                stall_pipeline_low <= '1';
                flush_f_reg <= '0';
                flush_d_reg <= '0';
            end if; 
            
            if (count > 0) then
                count := count - 1;         
            end if;                        
        else        
            case op_code is
                -- Operations that read a register and are suseptable to read after load hazard, require stalls 
                when ADD | SUB | MUL | NAND_OP  =>
                    if (mem_read = '1') and ( dest_reg = source_reg1 or dest_reg = source_reg2 )then
                        stall_pipeline_low <= '0';
                        count := 1; -- Stall 1 cycle
                    elsif (reg_write = '1') and ( dest_reg = source_reg1 or dest_reg = source_reg2 )then
                        stall_pipeline_low <= '0';
                        count := 1; -- Stall 1 cycle                 
                    end if;
                
                when  SHL_OP | SHR_OP | STORE | MOV | TEST | BRR_N | BRR_Z | BR_N | BR_Z | RETURN_OP | LOADIMM | LOAD | OUT_OP =>
                    if (mem_read = '1') and ( dest_reg = source_reg1 )then
                        stall_pipeline_low <= '0';
                        count := 1; -- Stall 1 cycle
                    elsif (reg_write = '1') and ( dest_reg = source_reg1 )then
                        stall_pipeline_low <= '0';
                        count := 1; -- Stall 1 cycle                 
                    end if;                           
                when others => NULL;                     
            end case;        
        end if;               
    end process;
end Behavioral;
