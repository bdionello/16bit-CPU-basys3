-- package for datapath and controller
library ieee ;
use ieee.std_logic_1164.all ;
use work.cpu_types.all ;

package cpu_components is
    component datapath
    port (
    a, b, c, d : in num ;
    sum : out num ;
    sel : in std_logic_vector (1 downto 0) ;
    load, clear, clk : in std_logic
    ) ;
    end component ;

    component controller
    port (
    update : in std_logic ;
    sel : out std_logic_vector (1 downto 0) ;
    load, clear : out std_logic ;
    clk : in std_logic
    ) ;
    end component ;
    
-- fix git pls
end cpu_components ;