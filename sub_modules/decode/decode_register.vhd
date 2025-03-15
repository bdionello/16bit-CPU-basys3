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

entity decode_register is
    Port ( 
           -- register control inputs 
           rst : in std_logic := '0';
           clk: in std_logic := '0';
           wr_enable: in std_logic := '0';
           -- inputs
           wr_pc : in word_t := (others=>'0');
           -- register file
           wr_reg_data1  : in word_t := (others=>'0');
           wr_reg_data2  : in word_t := (others=>'0');
           wr_reg_write_index  : in std_logic_vector(2 downto 0) := (others=>'0');
           wr_extended_disp    : in word_t := (others => '0');
           wr_immidate : in word_t := (others=>'0'); 
           wr_inport_data : in word_t := (others=>'0');
           wr_alu_shift : in std_logic_vector(3 downto 0) := (others => '0');        
           -- contorller records
           wr_execute_ctl : in execute_type := execute_type_init_c;
           wr_memory_ctl : in memory_type := memory_type_init_c;
           wr_write_back_ctl : in write_back_type := write_back_type_init_c;
           
           -- outputs
           rd_pc : out word_t := (others=>'0');
           -- register file
           rd_reg_data1  : out word_t := (others=>'0');
           rd_reg_data2  : out word_t := (others=>'0');
           rd_reg_write_index : out std_logic_vector(2 downto 0) := (others=>'0');
           -- 
           rd_extended_disp    : out word_t := (others => '0');
           rd_immidate : out word_t := (others=>'0');
           rd_inport_data : out word_t := (others=>'0');
           rd_alu_shift : out  std_logic_vector(3 downto 0) := (others => '0');
           -- contorller records 
           rd_execute_ctl : out execute_type := execute_type_init_c;
           rd_memory_ctl : out memory_type := memory_type_init_c;
           rd_write_back_ctl : out write_back_type := write_back_type_init_c
           
           );
end decode_register;

architecture Behavioral of decode_register is
    begin
       --write operation 
        process(clk, rst)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then
                    rd_pc <= (others=>'0');
                    rd_reg_data1  <= (others=>'0');
                    rd_reg_data2  <= (others=>'0');
                    rd_reg_write_index  <= (others=>'0');
                    rd_extended_disp <= (others=>'0');
                    rd_immidate <= (others=>'0');
                    rd_inport_data <= (others=>'0');
                    rd_execute_ctl <= execute_type_init_c;
                    rd_memory_ctl <= memory_type_init_c;
                    rd_write_back_ctl <= write_back_type_init_c;
                    rd_alu_shift <= (others=>'0');                    
                     
                elsif(wr_enable='1') then
                    rd_pc <= wr_pc;
                    rd_reg_data1 <= wr_reg_data1;
                    rd_reg_data2 <= wr_reg_data2;
                    rd_reg_write_index <= wr_reg_write_index;
                    rd_extended_disp <= wr_extended_disp;
                    rd_immidate <= wr_immidate;
                    rd_inport_data <= wr_inport_data;
                    rd_alu_shift <= wr_alu_shift;
                    rd_execute_ctl <= wr_execute_ctl; 
                    rd_memory_ctl <= wr_memory_ctl;
                    rd_write_back_ctl <= wr_write_back_ctl;               
                end if;
            end if;
        end process;   
    end Behavioral;