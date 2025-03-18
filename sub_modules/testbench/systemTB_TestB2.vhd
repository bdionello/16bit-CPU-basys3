library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

entity test_System is end test_System;

architecture behavioural of test_System is
    constant memory_size : integer := 1024;
    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz; -- 1/T = 100MHz
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
    in_port => input_data,
    out_port => output_data
    );
    -- system test clock
     CLK_PROC : process
        begin
            wait for clk_period / 2;
            if clk = '1' then
                clk <= '0';
            else
                clk <= '1';
            end if;
     end process;
    
    --system test process       
    process begin    
--        reset_execute <= '1';
--        reset_load <= '0';
--        wait until falling_edge(clk);
--        reset_execute <= '0';      
--        wait until falling_edge(clk);    
        -- Do something?
        wait until falling_edge(clk);       
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        input_data <= X"0002";
        wait until falling_edge(clk);
        input_data <= X"0003";
        wait until falling_edge(clk);
        input_data <= X"0001";
        wait until falling_edge(clk);
        input_data <= X"0005";
        wait until falling_edge(clk);
        input_data <= X"0000";
        wait until falling_edge(clk);
        input_data <= X"0001";
        wait until falling_edge(clk);
        input_data <= X"0005";
        wait until falling_edge(clk);
        input_data <= X"0000";
                   
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);

        


        
        assert false report "Test: End - Force stop" severity failure;       
    end process;   
end behavioural;