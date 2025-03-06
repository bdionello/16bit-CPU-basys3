library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_TB is
end memory_TB;

architecture Behavioral of memory_TB is
    -- Test Bench config
    constant memory_size : integer := 1024;
    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz; -- 1/T = 100MHz
    -- Control signals
    signal clk : std_logic := '0';
    signal reset_i : STD_LOGIC := '0';
    signal write_enable_i : STD_LOGIC := '0';
    signal read_data_enable_i : STD_LOGIC := '0';
    -- signal read_inst_enable_i : STD_LOGIC := '0';
    signal data_in_i : STD_LOGIC_VECTOR (15 downto 0) := X"0000"; -- All write data       
    signal data_addr_i : STD_LOGIC_VECTOR (15 downto 0) := X"0000";   
    signal inst_addr_i : STD_LOGIC_VECTOR (15 downto 0) := X"0000";        
    -- Measurment Signals
    signal data_out_i : STD_LOGIC_VECTOR (15 downto 0) := X"0000";
    signal inst_out_i : STD_LOGIC_VECTOR (15 downto 0) := X"0000";    
    -- Memory mapped ports
    signal in_port_i :  STD_LOGIC_VECTOR (15 downto 0) := X"0000";  -- Read from Dip switches
    signal out_port_i :  STD_LOGIC_VECTOR (15 downto 0) := X"0000"; -- Write to Display   
       
begin
    -- Test unit
    mem0: entity work.mem_manager
         port map(
            
            write_enable => write_enable_i,
            read_data_enable => read_data_enable_i,
            clock => clk,
            reset => reset_i,
            data_in => data_in_i,
            data_addr => data_addr_i,            
            data_out => data_out_i,
            inst_addr => inst_addr_i,
            inst_out => inst_out_i,
            -- read_inst_enable => read_inst_enable_i,
            in_port => in_port_i,
            out_port =>  out_port_i      
         );
     -- Clock process
     CLK_PROC : process
         begin
             wait for clk_period / 2;
             if clk = '1' then
                 clk <= '0';
             else
                 clk <= '1';
             end if;
     end process;
     
     TEST_PROC : process
     variable instruction_address: std_logic_vector(15 downto 0);
     variable write_address: std_logic_vector(15 downto 0);
     variable write_data: std_logic_vector(15 downto 0);
     variable read_data_address: std_logic_vector(15 downto 0);
         begin
             -- Inital Reset
             reset_i <= '1';
             wait until falling_edge(clk);
             reset_i <= '0';
             wait until falling_edge(clk);
                                                
             -- TEST 1 -- ROM READ all addresses 
             instruction_address := X"0000";
             -- run 512 times to read 1024 bytes
             -- start at 20ns  
             test1_rom_read : for k in 0 to (memory_size/2)-1 loop                            
                 inst_addr_i <= instruction_address;  
                 wait until falling_edge(clk);
                 assert inst_out_i = instruction_address report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                 instruction_address := std_logic_vector((unsigned(instruction_address)) + 2);
             end loop test1_rom_read;
             
             -- Reset before next test
             inst_addr_i <= X"0000";
             reset_i <= '1';
             wait until falling_edge(clk);
             reset_i <= '0';
             wait until falling_edge(clk);             
             
             -- Start at 5160ns
             -- Test 2 -- RAM Write all addresses
              write_address := X"0400";
              write_data := X"0000";
              write_enable_i <= '1';
              test2_ram_write : for k in 0 to (memory_size/2)-1 loop                                         
                 data_addr_i <= write_address;
                 data_in_i <= write_data;  
                 wait until falling_edge(clk);
                 -- assert inst_out_i = read_address report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                 write_address := std_logic_vector((unsigned(write_address)) + 2);
                 write_data := std_logic_vector((unsigned(write_data)) + 2);
               end loop test2_ram_write;
               
               -- Reset before next test
               data_in_i <= X"0000";
               data_addr_i <= X"0000";
               write_enable_i <= '0';
               reset_i <= '1';
               wait until falling_edge(clk);
               reset_i <= '0';
               wait until falling_edge(clk);
               
               -- Start at 10300ns
               -- Test 3 -- RAM read all addresses
                read_data_address := X"0400";
                read_data_enable_i <= '1';
                test3_ram_read : for k in 0 to (memory_size/2)-1 loop                                               
                   data_addr_i <= read_data_address; 
                   wait until falling_edge(clk);
                   assert data_out_i = (read_data_address AND (NOT X"0400"))  report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));                 
                   read_data_address := std_logic_vector((unsigned(read_data_address)) + 2);
                 end loop test3_ram_read;
                                  
                 -- Reset before next test
                 data_addr_i <= X"0000";
                 read_data_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);
                 
                 -- Start at 15440 ns 
                 -- Test 4 -- simultaneous access instruction and data ROM/RAM
                 instruction_address := X"0000";
                 write_address := X"0400";
                 write_data := X"5555";
                 read_data_address := X"0400";                 
                 test4_write_read : for k in 0 to 9 loop
                    read_data_enable_i <= '0';          -- read disable
                    write_enable_i <= '1';              -- write enable
                    inst_addr_i <= instruction_address; -- read rom 
                    data_addr_i <= write_address;       -- write ram
                    data_in_i <= write_data;     
                    wait until falling_edge(clk);                    
                    read_data_enable_i <= '1';          -- read enable
                    write_enable_i <= '0';              -- write disable
                    data_addr_i <= read_data_address;   -- read data
                    wait until falling_edge(clk);
                    assert data_out_i = write_data report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));
                    assert inst_out_i = instruction_address report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                    -- increment variables
                    instruction_address := std_logic_vector((unsigned(instruction_address)) + 2);
                    write_address := std_logic_vector((unsigned(write_address)) + 2);
                    write_data := NOT write_data;
                    read_data_address := std_logic_vector((unsigned(read_data_address)) + 2);
                 end loop test4_write_read;                 
                 
                 -- Reset before next test
                 data_addr_i <= X"0000";
                 data_in_i <= X"0000";
                 read_data_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);
                 -- Start at 15650 ns 
                 -- Test 5 -- simultaneous access instruction and data RAM/RAM
                 instruction_address := X"0414";
                 write_address := X"0400";
                 write_data := X"CCCC";
                 read_data_address := X"0400";                 
                 test5_write_read : for k in 0 to 9 loop
                    read_data_enable_i <= '0';          -- read disable
                    write_enable_i <= '1';              -- write enable
                    inst_addr_i <= instruction_address; -- read rom 
                    data_addr_i <= write_address;       -- write ram
                    data_in_i <= write_data;     
                    wait until falling_edge(clk);                    
                    read_data_enable_i <= '1';          -- read enable
                    write_enable_i <= '0';              -- write disable
                    data_addr_i <= read_data_address;   -- read data
                    wait until falling_edge(clk);
                    assert data_out_i = write_data report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));
                    assert inst_out_i = (instruction_address AND NOT X"0400") report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                    -- increment variables
                    instruction_address := std_logic_vector((unsigned(instruction_address)) + 2);
                    write_address := std_logic_vector((unsigned(write_address)) + 2);
                    write_data := NOT write_data;
                    read_data_address := std_logic_vector((unsigned(read_data_address)) + 2);
                 end loop test5_write_read;
                 
                 -- Reset before next test
                 data_addr_i <= X"0000";
                 data_in_i <= X"0000";
                 inst_addr_i <= X"0000";
                 read_data_enable_i <= '0';
                 write_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);
                                  
                 -- Start at 15880ns 
                 -- Test 6 -- Read from IN port for memory mapped IO               
                 in_port_i <= X"ABCD";                
                 read_data_enable_i <= '1';
                 data_addr_i <= X"FFF0";
                 wait until falling_edge(clk);
                 assert data_out_i = X"ABCD" report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));
                 
                 -- Reset before next test
                 in_port_i <= X"0000";
                 data_addr_i <= X"0000";
                 read_data_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);     
                                         
                 -- Start at 15890ns 
                 -- Test 7 -- write to OUT port for memory mapped IO
                 write_enable_i <= '1';                
                 data_addr_i <= X"FFF2";
                 data_in_i <= X"DCBA";
                 wait until falling_edge(clk);
                 assert out_port_i = X"DCBA" report "Unexpected return value. out_port_i = " & integer'image(to_integer(unsigned(out_port_i)));
             
                 -- Reset before next test
                 data_addr_i <= X"0000";
                 data_in_i <= X"0000";
                 inst_addr_i <= X"0000";
                 read_data_enable_i <= '0';
                 write_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);
                 
                 -- Start at 15940ns 
                 -- Test 8 -- simultaneous data read and write             
                 read_data_enable_i <= '1';
                 data_addr_i <= X"0414";
                 wait until falling_edge(clk);
                 assert data_out_i = X"0014" report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));                  
                 write_enable_i <= '1';                
                 data_addr_i <= X"0414";
                 data_in_i <= X"FFFF";
                 wait until falling_edge(clk);
                 write_enable_i <= '0';
                 wait until falling_edge(clk);
                 assert data_out_i = X"0014" report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i))); 
                 
                 data_addr_i <= X"0000";
                 data_in_i <= X"0000";
                 read_data_enable_i <= '0';
                 write_enable_i <= '0';
                 reset_i <= '1';
                 wait until falling_edge(clk);
                 reset_i <= '0';
                 wait until falling_edge(clk);
                 
                 -- Start at 15990ns 
                 -- Test 9 -- Test reset with Read and write
                 -- Reset clears output but does not block write access
                 reset_i <= '1';
                 wait until falling_edge(clk);
                  -- test rom  
                 inst_addr_i <= X"0014"; 
                 wait until falling_edge(clk);
                 assert inst_out_i = X"0000" report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                  -- test ram port b
                 inst_addr_i <= X"0414";
                 wait until falling_edge(clk);
                 assert inst_out_i = X"0000" report "Unexpected return value. inst_out_i = " & integer'image(to_integer(unsigned(inst_out_i)));                 
                 -- test write port a                 
                 write_enable_i <= '1';                
                 data_addr_i <= X"0414";
                 data_in_i <= X"FFFF";
                 wait until falling_edge(clk);
                 write_enable_i <= '0';
                 read_data_enable_i <= '1';
                 wait until falling_edge(clk);
                 assert data_out_i = X"0000" report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i))); 
                 reset_i <= '0';
                 wait until falling_edge(clk);                 
                 assert data_out_i = X"FFFF" report "Unexpected return value. data_out_i = " & integer'image(to_integer(unsigned(data_out_i)));             
                 -- Hard stop
                 assert false report "Test: End - Force stop" severity failure;
     end process;         
end Behavioral;
