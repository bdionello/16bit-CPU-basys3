-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;
use work.cpu_components.all ;

entity cpu_top is port (
 stm_sys_clk : IN std_logic;
 rst_ex : IN std_logic; -- BTNR button on BAYSYS3 "right for run"
 rs_ld : IN std_logic; -- BTNL button on BAYSYS3  "left for load"
 IN_port : IN std_logic_vector (15 downto 0); -- only 15 to 5 is used
 OUT_port : OUT std_logic_vector (15 downto 0)
 );
end cpu_top ;

architecture rtl of cpu_top is

    signal sel : std_logic_vector (1 downto 0) ;
    signal load, clear : std_logic ;
    -- other declarations (e.g. components) here
begin

    d1: datapath port map (stm_sys_clk ) ;
    c1: controller port map (stm_sys_clk ) ;

end rtl ;

