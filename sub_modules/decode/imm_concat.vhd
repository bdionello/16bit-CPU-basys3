-- program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity immediate_concatenator is
    port(
        rst       : in std_logic;
        clk       : in std_logic;
--        wr_enable : in std_logic;
--        imm_wb_index : in std_logic_vector(2 downto 0);
        imm_r7_in : in word_t;
        imm_op    : in  std_logic;
        imm_mode  : in  std_logic;
        imm_in    : in  word_t; 
        imm_out   : out std_logic_vector (15 downto 0 )
        );
end immediate_concatenator ;

architecture imm_concat_arch of immediate_concatenator is
 --   signal imm_last_i : std_logic_vector (15 downto 0 ) := (others => '0');
       begin
        -- concatenate the last immidate value with the next one 
        process(imm_op, imm_in, imm_mode)                
            begin     
--                if (rst='1') then
--                    -- imm_last_i <= (others => '0');
--                    imm_out <= (others => '0');   
                if (imm_op = '1') then                         
                    if (imm_mode = '1' ) then                  
                        imm_out <= (imm_r7_in AND X"00FF") or imm_in;                                                                 
                    else   
                        imm_out <= (imm_r7_in AND X"FF00") or  imm_in;      
                    end if;
                else
                    imm_out <= (others => '0');                 
                end if;                
        end process;
end imm_concat_arch;
