-- datapath
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;

entity datapath is
    port (
        -- system ports
        sys_clk : in std_logic;
        sys_rst : in std_logic;
        in_port : in std_logic_vector(15 downto 0);        
        -- controller signal ports
        reg_dst : in std_logic;
        branch : in std_logic;
        ram_mem_rd : in std_logic;
        ram_mem_to_reg : in std_logic;
        rom_mem_rd : in std_logic;
        rom_mem_to_reg : in std_logic;
        alu_op : in std_logic_vector(2 downto 0);
        ram_mem_wr : in std_logic;
        rom_mem_wr : in std_logic;
        alu_src : in std_logic;
        reg_wr : in std_logic; 
        -- outputs
        data_out : out std_logic_vector (15 downto 0);
        inst_out : out std_logic_vector (15 downto 0)
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

end rtl ;