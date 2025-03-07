
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fetch_register is
    Port ( 
           -- inputs 
           rst : in std_logic;
           clk: in std_logic;
           wr_enable: in std_logic;
           wr_instruction : in word_t;
           wr_pc : in word_t;
           -- outputs
           rd_instruction : out word_t;
           rd_pc : out word_t
           );
end fetch_register;

architecture Behavioral of fetch_register is
    begin
       --write operation 
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then
                    rd_instruction <= x"0000";
                    rd_pc <= X"0000"; 
                elsif(wr_enable='1') then
                    rd_instruction <= wr_instruction;
                    rd_pc <= wr_pc;
                end if;
            end if;
        end process;   
    end Behavioral;