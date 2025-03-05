library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_manager is
    Port (
        -- Shared ports
        bootload_mode : in STD_LOGIC; -- asserted means reset load mode 
        data_in : in STD_LOGIC_VECTOR (15 downto 0); -- All write data
        write_enable : in STD_LOGIC;
        read_data_enable : in STD_LOGIC;
        clock : in STD_LOGIC;
        reset : in STD_LOGIC;
        data_addr : in STD_LOGIC_VECTOR (15 downto 0) := X"0000";
        data_out : out STD_LOGIC_VECTOR (15 downto 0);
        -- Instruction memory "Application code"
        inst_addr : in STD_LOGIC_VECTOR (15 downto 0);
        inst_out : out STD_LOGIC_VECTOR (15 downto 0);
        read_inst_enable : in STD_LOGIC;
        -- Memory Mapped ports
        in_port : in STD_LOGIC_VECTOR (15 downto 0);
        out_port : out STD_LOGIC_VECTOR (15 downto 0)
        );
end mem_manager;

architecture mem_manager_arch of mem_manager is
    -- Control Signals
    signal reset_i : STD_LOGIC;
    signal write_enable_i : STD_LOGIC_VECTOR (0 downto 0);
    signal rom_enable_i : STD_LOGIC;    
    signal ram_a_enable_i : STD_LOGIC;        
    signal ram_b_enable_i : STD_LOGIC;       
    ----
    -- Data Signals
    signal out_port_i : STD_LOGIC_VECTOR (15 downto 0); 
    signal data_addr_i : STD_LOGIC_VECTOR (15 downto 0);
    signal data_in_i : STD_LOGIC_VECTOR (15 downto 0);
    signal rom_data_out_i : STD_LOGIC_VECTOR (15 downto 0);
    signal ram_a_data_out_i : STD_LOGIC_VECTOR (15 downto 0);
    signal ram_b_data_out_i : STD_LOGIC_VECTOR (15 downto 0);     
           
begin
           
    -------------------
    -- Internal State Logic
    reset_i <= '1' when (reset = '1') else '0';    
    rom_enable_i <= '1' when (read_inst_enable = '1') AND (data_addr AND X"0400") = X"0000" else 
                    '0' when (reset = '1') else
                    '0';                        
    ram_a_enable_i <= '1' when (read_data_enable = '1') AND (data_addr AND X"0400") = X"0400" else
                      '0' when (reset = '1') else
                      '0';
    ram_b_enable_i <= '1' when (read_inst_enable = '1') AND (bootload_mode = '1') else
                      '0' when (reset = '1') else
                      '0';
    write_enable_i <= "1" when (write_enable = '1') else
                      "0" when (reset = '1') else
                      "0";     
    ------------------- 
    -- OUTPUT State LOGIC                 
    inst_out <= ram_b_data_out_i when (data_addr AND X"0400") = X"0400" AND (bootload_mode = '0') else rom_data_out_i;                
    data_out <= in_port when (data_addr = X"FFF2") AND (read_data_enable = '1') else ram_a_data_out_i;                                    
    out_port <= data_in when (data_addr = X"FFF0") AND (write_enable = '1') else X"0000";
    
    rom0 : entity work.rom
        port map(
            clk => clock,
            rst => reset_i,
            en => rom_enable_i,
            addr => inst_addr,
            dout => rom_data_out_i 
        );       
    ram0 : entity work.ram
        port map(
            clk => clock,
            -- Port A - read/write
            rsta => reset_i, 
            ena => ram_a_enable_i,   
            wea => write_enable_i,     
            addra => data_addr,
            dina => data_in,         
            douta => ram_a_data_out_i,    
            -- Port B - read only               
            rstb => reset_i,                   
            enb => ram_b_enable_i,                                  
            addrb => inst_addr,                   
            doutb => ram_b_data_out_i                 
        );
end mem_manager_arch;
