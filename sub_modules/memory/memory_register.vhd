
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
           rst                : in std_logic := '0';
           clk                : in std_logic := '0';
           wr_enable          : in std_logic := '0';
           -- inputs
           wr_pc              : in word_t;
           -- alu
           wr_alu_result      : in word_t;
          -- register file
           wr_reg_data1       : in word_t;
           wr_mem_data        : in word_t;
           wr_reg_write_index : in std_logic_vector(2 downto 0);
           wr_immidate        : in word_t; 
           wr_m_1             : in std_logic; 
           wr_inport_data     : in word_t;           
           -- contorller records
           wr_write_back_ctl  : in write_back_type;           
           -- outputs
           rd_pc              : out word_t;
           -- alu
           rd_alu_result      : out word_t;
           -- register file
           rd_reg_data1       : out word_t;
           rd_mem_data        : out word_t;       
           rd_reg_write_index : out std_logic_vector(2 downto 0);
           -- 
           rd_immidate        : out word_t;
           rd_m_1             : out std_logic; 
           rd_inport_data     : out word_t;
           -- contorller records 
           rd_write_back_ctl  : out write_back_type           
           );
end memory_register;

architecture Behavioral of memory_register is
    begin
       --write operation 
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then 
                    rd_pc <= (others=>'0');
                    rd_alu_result  <= (others=>'0');
                    rd_reg_data1  <= (others=>'0');
                    rd_mem_data    <= (others=>'0');
                    rd_reg_write_index  <= (others=>'0');
                    rd_immidate <= (others=>'0');
                    rd_m_1 <= '0';
                    rd_inport_data <= (others=>'0');
                    rd_write_back_ctl <= write_back_type_init_c;                    
                elsif(wr_enable='1') then
                    rd_pc <= wr_pc;
                    rd_alu_result <= wr_alu_result;
                    rd_reg_data1 <= wr_reg_data1;
                    rd_mem_data <= wr_mem_data;
                    rd_reg_write_index <= wr_reg_write_index;
                    rd_immidate <= wr_immidate;
                    rd_m_1 <= wr_m_1;
                    rd_inport_data <= wr_inport_data;
                    rd_write_back_ctl <= wr_write_back_ctl;                                   
                end if;
            end if;
        end process;   
    end Behavioral;