library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity alu_file is
port(rst : in std_logic; clk: in std_logic;

in1, in2 : in std_logic_vector(3 downto 0);
alu_mode : in std_logic_vector(3 downto 0);
result : out std_logic_vector(15 downto 0);
z_flag, n_flag : in std_logic);
end alu_file;

architecture behavioural of alu_file is

--internals signals
signal r1, r2 : std_logic_vector(3 downto 0);
signal temp_result : std_logic_vector(15 downto 0);
signal temp_z, temp_n : std_logic;

process(clk)
begin
    case alu_mode is
    when "000" => temp_result <= temp_result; --NOP
    when "001" => temp_result <= r1 + r2; --ADD
    when "010" => temp_result <= r1 - r2; --SUB
    when "011" => temp_result <= r1 * r2; --MUL
    when "100" => temp_result <= r1 NAND r2; --NAND
    when "101" => temp_result <= temp_result; --SHL
    when "110" => temp_result <= temp_result; --SHR
    when "111" => 
        if (r1 = '0') then
            temp_z <= '1';
        else
            temp_z <= '0';
        end if

        if (r1 < '0') then
            temp_n <= '1';
        else
            temp_n <= '0';
        end if

end process;
result <= temp_result;
z_flag <= temp_z;
n_flag <= temp_n;

end behavioural;