-- program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.cpu_types.all;

entity immediate_concatenator is
    port(
        clear_low : in  std_logic := '0';
        imm_in : in word_t;
        imm_out : out word_t
        );
end immediate_concatenator ;

architecture imm_concat_arch of immediate_concatenator is    
    begin    
        -- write operation
        -- concatenate the last immidate value with the next one 
        process(imm_in, clear_low)
            variable imm_last : word_t := (others => '0');
            begin   
                if(clear_low = '0') then
                        imm_out <= (others => '0');
                        imm_last := (others => '0');
                    else
                        imm_out <= imm_in or imm_last;
                        imm_last := imm_in;
                end if;
            end process;
end imm_concat_arch;