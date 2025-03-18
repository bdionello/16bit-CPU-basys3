library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types.all;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detect_unit is
    port (
        -- inputs    
        clk            : in std_logic := '0';
        mem_write      : in std_logic := '0';
        reg_write      : in std_logic := '0';
        dest_reg       : in std_logic_vector(2 downto 0) := (others=>'0');
        source_reg1    : in std_logic_vector(2 downto 0) := (others=>'0'); 
        source_reg2    : in std_logic_vector(2 downto 0) := (others=>'0'); 
        op_code        : in op_code_t; 
        
        flush_f_reg : out std_logic := '0';
        flush_d_reg : out std_logic := '0';
        flush_ex_reg : out std_logic := '0';
                        
        stall_pipeline : out std_logic := '1' -- active Low
               
        );
end hazard_detect_unit;

architecture Behavioral of hazard_detect_unit is
     
begin
    process (clk, op_code)
        variable count : natural range 0 to 2 := 0;
    begin
                               
        case op_code is
            when BRR | BR | BR_SUB => 
               count := 2;            
            when BRR_N | BRR_Z | BR_N | BR_Z =>
               count := 2;            
            when others =>
                flush_f_reg <= '0';
                flush_d_reg <= '0';
                flush_ex_reg <= '0';
                stall_pipeline <= '1'; 
        end case; 
        
        if count > 0 then
            stall_pipeline <= '0';
            flush_f_reg <= '1';
            flush_d_reg <= '1';             
        else
            stall_pipeline <= '1';
            flush_f_reg <= '0';
            flush_d_reg <= '0';
        end if;   
        
         if rising_edge(clk) then
             count := count - 1;
         end if; 
                
    end process;
end Behavioral;
