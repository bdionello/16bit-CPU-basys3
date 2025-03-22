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
    shared variable stall : std_logic := '0';
    shared variable flush : std_logic := '0';
    shared variable flush_count : natural range 0 to 10 := 0;
    shared variable stall_count : natural range 0 to 10 := 0;
         
begin
    stall_counter: process (clk)
        begin
            if rising_edge(clk) then       
                if stall = '1' and (stall_count > 0) then       
                 stall_count := stall_count - 1;
                else 
                 stall_count := 2; -- stall 2 cycles
                end if;                         
                if flush = '1' and (flush_count > 0) then       
                 flush_count := flush_count - 1;
                else 
                 flush_count := 1; -- one cycle delay to flush
                end if;                     
            end if;        
        end process; 
  
    hazard_control: process (clk, source_reg1, source_reg2, mem_read, reg_write, dest_reg,  branch_decision, op_code)         
    begin
        if (flush_count <= 0) and (flush = '1') then
            flush := '0';
            flush_f_reg <= '0';
            flush_d_reg <= '0';
                
        elsif (branch_decision = '1') then
                flush := '1';
                flush_f_reg <= '1';
                flush_d_reg <= '1';
        end if;       
        
        if (stall_count <= 0) and (stall = '1') then
            stall_pipeline_low <= '1';
            stall := '0';
        else         
            case op_code is
                    -- Operations that read a register and are suseptable to read after load hazard, require stalls 
                    when ADD | SUB | MUL | NAND_OP  =>
                        if (mem_read = '1') and ( dest_reg = source_reg1 or dest_reg = source_reg2 )then
                            stall := '1';
                        elsif (reg_write = '1') and ( dest_reg = source_reg1 or dest_reg = source_reg2 )then
                            stall := '1';
--                        else 
--                            stall := '0';               
                        end if; 
                                       
                    when  SHL_OP | SHR_OP | STORE | MOV | TEST | BRR_N | BRR_Z | BR_N | BR_Z | RETURN_OP | LOADIMM | LOAD | OUT_OP =>
                        if (mem_read = '1') and ( dest_reg = source_reg1 )then
                            stall := '1';
                        elsif (reg_write = '1') and ( dest_reg = source_reg1 )then
                            stall := '1';
--                        else 
--                            stall := '0';             
                        end if;
                                                     
                    when others => NULL;                     
                end case;            
                if stall = '1' then
                    stall_pipeline_low <= '0';
                end if;
          end if;                                   
    end process;
end Behavioral;
