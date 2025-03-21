-- memory manager
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_manager is
    Port (
        -- Shared ports
        clock            : in STD_LOGIC := '0';
        reset            : in STD_LOGIC := '0';        
        write_enable     : in STD_LOGIC := '0';
        read_data_enable : in STD_LOGIC := '0';
        data_addr        : in STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
        data_in          : in STD_LOGIC_VECTOR (15 downto 0):= (others => '0'); -- All write data
        data_out         : out STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
        -- Instruction memory - read only
        inst_addr        : in STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
        inst_out         : out STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
        -- read_inst_enable : in STD_LOGIC := '0'; -- used for debugging may not be needed for read only memory
        -- Memory Mapped ports
        in_port          : in STD_LOGIC_VECTOR (15 downto 0):= (others => '0');
        led_7seg_out     : out STD_LOGIC_VECTOR (15 downto 0) := (others => '0')
        );
end mem_manager;

architecture mem_manager_arch of mem_manager is
    signal last_ram_data_read_i: std_logic_vector(15 downto 0) := (others => '0');
    ----------- Control Signals
    signal reset_i : STD_LOGIC := '0';
    signal write_enable_i : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal rom_enable_i : STD_LOGIC := '0';    
    signal ram_a_enable_i : STD_LOGIC := '0';      
    signal ram_b_enable_i : STD_LOGIC := '0';       
    ----------- Data Signals
    signal out_port_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); 
    signal data_addr_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal inst_addr_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal data_in_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal rom_data_out_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal ram_a_data_out_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal ram_b_data_out_i : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');    
           
begin
    -- Shift Byte addressable address to word addressable due to internal memory configuration of rom/ram 
    inst_addr_i <= std_logic_vector(shift_right(unsigned(inst_addr),1));
    data_addr_i <= std_logic_vector(shift_right(unsigned(data_addr),1)); 
             
    ----------- Internal State Logic: control signals
    -- Reset condition send signal to ROM and RAM 
    reset_i <= '1' when (reset = '1') else '0'; 
    -- Rom is accessed for instruction address space below 0x0400   
    rom_enable_i <= '1' when (inst_addr AND X"0400") = X"0000" else '0'; 
    -- ram port_a for data memory and writing user code, enabled for read or write not both, and address space above 0x0400 (assembly code must conform)                                        
    ram_a_enable_i <= '1' when ((read_data_enable = '1') XOR (write_enable = '1')) AND ((data_addr AND X"0400") = X"0400") else '0';
    -- ram port_b for user code instruction read, memory space above 0x0400                     
    ram_b_enable_i <= '1' when ((inst_addr AND X"0400") = X"0400") else '0';
    write_enable_i <= "1" when (write_enable = '1') else "0";
                                            
    ----------- OUTPUT State LOGIC: data signals
    -- Change instruction output from rom or ram based on address range                  
    inst_out <= X"0000" when (reset_i ='1') else
                ram_b_data_out_i when ((inst_addr AND X"0400") = X"0400") else                                
                rom_data_out_i;    
    
    -- Connect memory to physical input port (read from Dip switch)               
    data_out <= in_port when (data_addr = X"FFF0") AND (read_data_enable = '1') AND (clock = '1') else
                ram_a_data_out_i when (read_data_enable = '1') AND (clock = '1') else
                X"0000" when (reset_i ='1');                              
    
    -- Connected to physical output port (Write to Display)                                  
    led_7seg_out <= data_in when (data_addr = X"FFF2") AND (write_enable = '1') AND (clock = '1') else
                    X"0000" when (reset_i ='1');
        
    rom_0 : entity work.rom
        port map(
            clk => clock,
            rst => reset_i,
            en => rom_enable_i,
            addr => inst_addr_i(8 downto 0),
            dout => rom_data_out_i 
        );       
    ram_0 : entity work.ram
        port map(
            clk => clock,
            -- Port A - read/write
            rsta => reset_i, 
            ena => ram_a_enable_i,   
            wea => write_enable_i,     
            addra => data_addr_i(8 downto 0),
            dina => data_in,         
            douta => ram_a_data_out_i,  
            -- Port B - read only               
            rstb => reset_i,                   
            enb => ram_b_enable_i,                                  
            addrb => inst_addr_i(8 downto 0),                   
            doutb => ram_b_data_out_i                 
        );
end mem_manager_arch;
