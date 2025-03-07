library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
    port (
        A, B: in std_logic_vector(15 downto 0);
        Selector: in std_logic;
        C : out std_logic_vector(15 downto 0)
        );
    end mux;

architecture mux_arch of mux is
    begin
        C <= A when (Selector = '0') else B;
    end mux_arch;