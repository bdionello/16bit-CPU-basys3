-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;
use work.cpu_components.all ;

entity cpu_top is port (
a, b, c, d : in num ;
sum : out num ;
update, clk : in std_logic ) ;
end cpu_top ;

architecture rtl of cpu_top is
    signal sel : std_logic_vector (1 downto 0) ;
    signal load, clear : std_logic ;
    -- other declarations (e.g. components) here
begin
    d1: datapath port map ( a, b, c, d, sum, sel, load,
    clear, clk ) ;
    c1: controller port map ( update, sel, load,
    clear, clk ) ;

    -- fix git pls
end rtl ;

