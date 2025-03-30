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

entity execute_register is
    Port ( 
           -- register control inputs 
           rst                 : in std_logic := '0';
           clk                 : in std_logic := '0';
           wr_enable           : in std_logic := '0';
           -- inputs
           wr_instruction : in word_t;
           wr_pc               : in word_t;
           -- alu
           wr_alu_result       : in word_t;
           wr_alu_z            : in std_logic;
           wr_alu_n            : in std_logic;  
           wr_alu_o            : in std_logic;  
          -- register file
           wr_reg_data1        : in word_t;
           wr_reg_data2        : in word_t;
           wr_reg_write_index  : in std_logic_vector(2 downto 0);
           wr_immidate         : in word_t; 
           wr_m_1              : in std_logic; 
           wr_inport_data      : in word_t;            
           -- contorller records
           wr_memory_ctl       : in memory_type;
           wr_write_back_ctl   : in write_back_type;
           
           -- outputs
           rd_instruction : out word_t;
           rd_pc               : out word_t;
           -- alu
           rd_alu_result       : out word_t;
           rd_alu_z            : out std_logic;
           rd_alu_n            : out std_logic;
           rd_alu_o            : out std_logic;  
           -- register file
           rd_reg_data1        : out word_t;
           rd_reg_data2        : out word_t;        
           rd_reg_write_index  : out std_logic_vector(2 downto 0);
           --
           rd_immidate         : out word_t;
           rd_m_1              : out std_logic;
           rd_inport_data      : out word_t;
           -- contorller records 
           rd_memory_ctl       : out memory_type;
           rd_write_back_ctl   : out write_back_type           
           );
end execute_register;

architecture Behavioral of execute_register is
    begin
       --write operation 
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then
                    rd_instruction <= x"0000";
                    rd_pc <= (others=>'0');
                    rd_alu_result  <= (others=>'0');
                    rd_alu_z <= '0';
                    rd_alu_n <= '0';
                    rd_alu_o <= '0';
                    rd_reg_data1  <= (others=>'0');
                    rd_reg_data2  <= (others=>'0');
                    rd_reg_write_index  <= (others=>'0');
                    rd_immidate <= (others=>'0');
                    rd_m_1 <= '0';
                    rd_inport_data <= (others=>'0');
                    rd_memory_ctl <= memory_type_init_c;
                    rd_write_back_ctl <= write_back_type_init_c;                    
                elsif(wr_enable='1') then
                    rd_instruction <= wr_instruction;
                    rd_pc <= wr_pc;
                    rd_alu_result <= wr_alu_result;
                    rd_alu_z <= wr_alu_z;
                    rd_alu_n <= wr_alu_n;
                    rd_alu_o <= wr_alu_o;
                    rd_reg_data1 <= wr_reg_data1;
                    rd_reg_data2 <= wr_reg_data2;
                    rd_reg_write_index <= wr_reg_write_index;
                    rd_immidate <= wr_immidate;
                    rd_m_1 <= wr_m_1;
                    rd_inport_data <= wr_inport_data;
                    rd_memory_ctl <= wr_memory_ctl;
                    rd_write_back_ctl <= wr_write_back_ctl;                                   
                end if;
            end if;
        end process;   
    end Behavioral;