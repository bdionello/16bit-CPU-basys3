-- program counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity immediate_concatenator is
    port(
        rst : in std_logic;
        clk: in std_logic;
        imm_op : in  std_logic;
        imm_mode : in  std_logic;
        imm_in : in std_logic_vector (7 downto 0 ); 
        imm_out : out std_logic_vector (15 downto 0 )
        );
end immediate_concatenator ;

architecture imm_concat_arch of immediate_concatenator is
    signal imm_last_i : std_logic_vector (15 downto 0 ) := (others => '0');
    signal imm_tmp_i : std_logic_vector (15 downto 0 ) := (others => '0');
    signal imm_new_i : std_logic_vector (15 downto 0 ) := (others => '0');
       begin
        -- concatenate the last immidate value with the next one 
        process(clk, rst, imm_op)                
            begin
                if (rst='1') then
                    imm_last_i <= (others => '0');
                    imm_out <= (others => '0');                
                elsif (falling_edge(clk) and imm_op = '1' ) then     
                        if (imm_mode = '1') then                       
                            imm_last_i <= (imm_last_i AND X"00FF") or (imm_in & X"00");
                            imm_out <= (imm_last_i AND X"00FF") or (imm_in & X"00");                                                                   
                        else 
                            imm_last_i <= (imm_last_i AND X"FF00") or (X"00" & imm_in);
                            imm_out <= (imm_last_i AND X"FF00") or (X"00" & imm_in);       
                        end if;              
            end if;
        end process;
end imm_concat_arch;