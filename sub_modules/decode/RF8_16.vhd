
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register_file is
    port(
        rst : in std_logic;
        clk: in std_logic;
        --read signals
        rd_index1: in std_logic_vector(2 downto 0); 
        rd_index2: in std_logic_vector(2 downto 0);
        --write signals
        wr_index: in std_logic_vector(2 downto 0); 
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic;
        of_flag       :  in STD_LOGIC := '0';
        
        -- out puts
        rd_data1: out std_logic_vector(15 downto 0); 
        rd_data2: out std_logic_vector(15 downto 0);
        
        -- Console display output
        register_0    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_1    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_2    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_3    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_4    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_5    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_6    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        register_7    :  out STD_LOGIC_VECTOR ( 15 downto 0 );
        
        o_flag_0      :  out STD_LOGIC := '0';
        o_flag_1      :  out STD_LOGIC := '0';
        o_flag_2      :  out STD_LOGIC := '0';
        o_flag_3      :  out STD_LOGIC := '0';
        o_flag_4      :  out STD_LOGIC := '0';
        o_flag_5      :  out STD_LOGIC := '0';
        o_flag_6      :  out STD_LOGIC := '0';
        o_flag_7      :  out STD_LOGIC := '0'
        
       
              
        );
end register_file;

architecture behavioural of register_file is

type reg_array is array (integer range 0 to 7) of std_logic_vector(15 downto 0);
--internals signals
signal reg_file : reg_array;

type of_array is array (integer range 0 to 7) of std_logic; 
--internals signals
signal of_flags : of_array;

begin
    --write operation 
    process(clk, rst, wr_enable)
        begin        
            if(rst='1') then
                for i in 0 to 7 loop
                    reg_file(i)<= (others => '0'); 
                    of_flags <= (others => '0'); 
                end loop;        
            elsif (falling_edge(clk) and (wr_enable='1')) then   -- write on falling edge          
                case wr_index(2 downto 0) is
                    when "000" => reg_file(0) <= wr_data;
                                  of_flags(0) <= of_flag;
                               
                    when "001" => reg_file(1) <= wr_data;
                                  of_flags(1) <= of_flag;
                               
                    when "010" => reg_file(2) <= wr_data;
                                  of_flags(2) <= of_flag;
                               
                    when "011" => reg_file(3) <= wr_data;
                                  of_flags(3) <= of_flag;
                               
                    when "100" => reg_file(4) <= wr_data;
                                  of_flags(4) <= of_flag;
                               
                    when "101" => reg_file(5) <= wr_data;
                                  of_flags(5) <= of_flag;
                               
                    when "110" => reg_file(6) <= wr_data;
                                  of_flags(6) <= of_flag;
                               
                    when "111" => reg_file(7) <= wr_data;
                                  of_flags(7) <= of_flag;
                                  
                    when others => NULL; end case;            
            end if;
    end process;
    
    --read operation -- read concurrantly
    rd_data1 <=	
    reg_file(0) when(rd_index1="000") else
    reg_file(1) when(rd_index1="001") else
    reg_file(2) when(rd_index1="010") else
    reg_file(3) when(rd_index1="011") else
    reg_file(4) when(rd_index1="100") else
    reg_file(5) when(rd_index1="101") else
    reg_file(6) when(rd_index1="110") else
    reg_file(7);
    
    rd_data2 <=
    reg_file(0) when(rd_index2="000") else
    reg_file(1) when(rd_index2="001") else
    reg_file(2) when(rd_index2="010") else
    reg_file(3) when(rd_index2="011") else
    reg_file(4) when(rd_index2="100") else
    reg_file(5) when(rd_index2="101") else
    reg_file(6) when(rd_index2="110") else
    reg_file(7);
    --map registers to console display ports
    register_0 <= reg_file(0);
    register_1 <= reg_file(1);
    register_2 <= reg_file(2);
    register_3 <= reg_file(3);
    register_4 <= reg_file(4);
    register_5 <= reg_file(5);
    register_6 <= reg_file(6);
    register_7 <= reg_file(7);
    
    o_flag_0 <= of_flags(0);
    o_flag_1 <= of_flags(1);
    o_flag_2 <= of_flags(2);
    o_flag_3 <= of_flags(3);
    o_flag_4 <= of_flags(4);
    o_flag_5 <= of_flags(5);
    o_flag_6 <= of_flags(6);
    o_flag_7 <= of_flags(7);
        
end behavioural;