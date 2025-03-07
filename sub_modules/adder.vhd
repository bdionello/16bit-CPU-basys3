library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_types.all;
entity adder is
    port (
        A, B: in word_t;
        C : out word_t
        );
    end adder;
    
architecture adder_arch of adder is
    begin
        C <= std_logic_vector(unsigned(A) + unsigned(B));
    end adder_arch;
