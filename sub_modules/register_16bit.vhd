library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register_16bit is
    port(
        rst : in std_logic;
        clk: in std_logic;
        --read signals
        rd_data: out std_logic_vector(15 downto 0);
        --write signals
        wr_data: in std_logic_vector(15 downto 0); 
        wr_enable: in std_logic
        );
end register_16bit;

architecture register_16bit_arch of register_16bit is
begin
    --write operation 
    process(clk)
        begin
            if(rising_edge(clk)) then
                if(rst='1') then
                    rd_data <= x"0000"; 
                elsif(wr_enable='1') then
                    rd_data <= wr_data;
                end if;
            end if;
        end process;
end register_16bit_arch;