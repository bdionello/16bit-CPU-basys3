----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2025 04:11:54 PM
-- Design Name: 
-- Module Name: ALU_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_TB is end ALU_TB;

architecture behavioural of ALU_TB is

component ALU port(
    in1      : in std_logic_vector(15 downto 0);  -- First operand
    in2      : in std_logic_vector(15 downto 0);  -- Second operand

    alu_mode : in std_logic_vector(6 downto 0);   -- ALU opcode (7-bit)
    alu_out   : out std_logic_vector(15 downto 0); -- ALU result

    shift    : in std_logic_vector(3 downto 0);   -- Shift amount
    zero_flag     : out std_logic;                -- Zero flag (Z)
    negative_flag : out std_logic;                -- Negative flag (N)
    clk : in std_logic;
    rst : in std_logic
);
end component;

signal clk, rst, zero_flag, negative_flag : std_logic;
signal alu_mode : std_logic_vector(6 downto 0);
signal in1, in2, alu_out : std_logic_vector(15 downto 0); 
signal shift : std_logic_vector(3 downto 0);


begin
uut: ALU port map(clk => clk, rst => rst, zero_flag => zero_flag, negative_flag => negative_flag, alu_mode => alu_mode, in1 => in1, in2 => in2, alu_out => alu_out, shift => shift);

process begin
    clk <= '0'; wait for 10 us;
    clk <= '1'; wait for 10 us;
end process;

process begin
    rst <= '1';
    wait for 20 ns;
    rst <= '0';

    wait for 20 ns; --ADD
    in1 <= "0000000000000001"; 
    in2 <= "0000000000000010"; 
    alu_mode <= "0000001"; 
    wait for 20 ns;
    
    wait for 20 ns; --SUB
    in1 <= "0000000000000001"; 
    in2 <= "0000000000000011"; 
    alu_mode <= "0000010"; 
    wait for 20 ns;
    
    wait for 20 ns; --MUL
    in1 <= "0000000000011000"; 
    in2 <= "0000000000000011"; 
    alu_mode <= "0000011"; 
    wait for 20 ns;
    
    wait for 20 ns; --NAND
    in1 <= "0000000000000111"; 
    in2 <= "0000000000000011"; 
    alu_mode <= "0000100"; 
    wait for 20 ns;
    
    wait for 20 ns; --SHL
    in1 <= "0000000000010101"; 
    shift <= "0001"; 
    alu_mode <= "0000101"; 
    wait for 20 ns;
    
    wait for 20 ns; --SHR
    in1 <= "0000000000010101"; 
    shift <= "0001"; 
    alu_mode <= "0000110"; 
    wait for 20 ns;

end process;



end behavioural;
