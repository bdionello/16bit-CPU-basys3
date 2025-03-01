-- datapath
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;

entity datapath is
    port (
        -- system ports
        sys_clk : IN STD_LOGIC;
        sys_rst : IN STD_LOGIC;
        IN_port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);        
        -- controller signal ports
        regDst : IN STD_LOGIC;
        branch : IN STD_LOGIC;
        RAM_mem_rd : IN STD_LOGIC;
        RAM_mem_to_reg : IN STD_LOGIC;
        ROM_mem_rd : IN STD_LOGIC;
        ROM_mem_to_reg : IN STD_LOGIC;
        alu_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RAM_mem_wr : IN STD_LOGIC;
        ROM_mem_wr : IN STD_LOGIC;
        alu_src : IN STD_LOGIC;
        reg_wr : IN STD_LOGIC; 
        -- outputs
        data_out : OUT std_logic_vector (15 downto 0);
        inst_out : OUT std_logic_vector (15 downto 0)
    ) ;
end datapath ;

architecture rtl of datapath is

--   component work.rom port(
--       clk : IN STD_LOGIC; -- clock
--       rst : IN STD_LOGIC; -- restart
--       ena : IN STD_LOGIC; -- enable
--       rd : IN STD_LOGIC; --read port a
--       addr  : IN STD_LOGIC_VECTOR(9 downto 0); -- address
--       dout : OUT STD_LOGIC_VECTOR(15 downto 0); -- data out port a
--    end component;       
    SIGNAL PC_to_rom_adr : STD_LOGIC_VECTOR(9 DOWNTO 0); -- from Program counter
    SIGNAL rom_data : STD_LOGIC_VECTOR(15 DOWNTO 0); -- instruction
    
    begin
        rom0 : ENTITY work.rom PORT MAP(
           clk => sys_clk,
           rst => sys_rst,
           ena => ROM_mem_wr,
           rd => '1',
           addr => PC_to_rom_adr,
           dout => rom_data 
          );
end rtl ;