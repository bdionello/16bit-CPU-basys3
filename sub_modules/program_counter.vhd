-- program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.cpu_types.all;

entity program_counter is
    port(
        rst : in std_logic := '0';
        clk: in std_logic := '0';
        --read signals
        rd_instruction: out word_t := (others => '0');
        --write signals
        wr_instruction: in word_t := (others => '0'); 
        wr_enable: in std_logic := '0'
        );
end program_counter;

architecture pc_arch of program_counter is
    begin
        --write operation 
        process(clk,rst)
            begin
                if(rising_edge(clk)) then
                    if(rst='1') then
                        rd_instruction <= (others => '0'); 
                    elsif(wr_enable='1') then
                        rd_instruction <= wr_instruction;
                    end if;
                end if;
            end process;
end pc_arch;