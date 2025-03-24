library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity out_register is
    port(
        clk: in std_logic;
        rst : in std_logic;        
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic;
        -- out puts
        rd_data: out std_logic_vector(15 downto 0) 
        );
end out_register;

architecture behavioural of out_register is
--internals signals
signal out_i : std_logic_vector(15 downto 0) := (others => '0');

begin
    rd_data <= out_i;
    --write operation 
    process(clk, rst, wr_enable)
        begin        
            if(rst='1') then
                out_i <= (others => '0');
            elsif (falling_edge(clk) and (wr_enable='1')) then   -- write on falling edge          
                out_i <= wr_data;
            end if;
    end process;        
end behavioural;