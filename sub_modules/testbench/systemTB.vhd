library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

entity test_System is end test_System;

architecture behavioural of test_System is
    signal clk : std_logic;
    signal reset_execute : std_logic;
    signal reset_load : std_logic;
    signal input_data : std_logic_vector (15 downto 0);
    signal output_data : std_logic_vector (15 downto 0);
begin 
    cpu0 : ENTITY work.cpu_top PORT MAP(
    stm_sys_clk => clk,
    rst_ex => reset_execute, 
    rst_ld => reset_load, 
    IN_port => input_data,
    OUT_port => output_data
    );
    -- system test clock
    process begin
        clk <= '0'; wait for 10 us;
        clk <= '1'; wait for 10 us;
    end process;
    
    --system test process       
    process begin    
    -- Start reading ROM
    reset_execute <= '0';
    reset_load <= '1';
    
    -- Do something?
    input_data <= X"ffff";
    wait until (clk='0' and clk'event);
    wait until (clk='1' and clk'event);
    input_data <= X"0000";       
    end process;    
    
end behavioural;