
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

entity memory_register is
    Port ( 
           -- register control inputs 
           rst : in std_logic := '0';
           clk : in std_logic := '0';
           wr_enable: in std_logic := '0';
           -- inputs
           -- alu
           wr_alu_result  : in word_t := (others=>'0');
          -- register file
           wr_reg_write_index  : in std_logic_vector(2 downto 0) := (others=>'0');
           -- TODO add displacement
           wr_immidate : in word_t := (others=>'0');
           wr_inport_data : in word_t := (others=>'0');           
           -- contorller records
           wr_write_back_ctl : in write_back_type := write_back_type_init_c;           
           -- outputs
           -- alu
           rd_alu_result  : out word_t := (others=>'0');
           -- register file       
           rd_reg_write_index  : out std_logic_vector(2 downto 0) := (others=>'0');
           -- 
           rd_immidate : out word_t := (others=>'0');
           rd_inport_data : out word_t := (others=>'0');
           -- contorller records 
           rd_write_back_ctl : out write_back_type := write_back_type_init_c           
           );
end memory_register;

architecture Behavioral of memory_register is
    begin
       --write operation 
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then
                    rd_alu_result  <= (others=>'0');
                    rd_reg_write_index  <= (others=>'0');
                    rd_immidate <= (others=>'0');
                    rd_inport_data <= (others=>'0');
                    rd_write_back_ctl <= write_back_type_init_c;                    
                elsif(wr_enable='1') then
                    rd_alu_result <= wr_alu_result;
                    rd_reg_write_index <= wr_reg_write_index;
                    rd_immidate <= wr_immidate;
                    rd_inport_data <= wr_inport_data;
                    rd_write_back_ctl <= wr_write_back_ctl;                                   
                end if;
            end if;
        end process;   
    end Behavioral;