library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ALU is
    port(
        in1      : in std_logic_vector(15 downto 0);  -- First operand
        in2      : in std_logic_vector(15 downto 0);  -- Second operand

        alu_mode : in std_logic_vector(6 downto 0);    -- ALU opcode (7-bit)
        alu_out   : out std_logic_vector(15 downto 0); -- ALU result

        shift    : in std_logic_vector(3 downto 0);   -- Shift amount
        zero_flag     : out std_logic := '0';                -- Zero flag (Z)
        negative_flag : out std_logic := '0';                -- Negative flag (N)
        clk : in std_logic;
        rst : in std_logic
    );
end ALU;

architecture behavioral of ALU is
begin
    process(in1, in2, shift, alu_mode)
    variable temp_result : std_logic_vector(15 downto 0);
    variable temp_result_mul : std_logic_vector(31 downto 0);
    begin
        case alu_mode is
            -- A-Format Instructions
            when "0000000" => temp_result := (others => '0');                                                           -- NOP (A0 Format)
            when "0000001" => temp_result := std_logic_vector(signed(in1) + signed(in2));                               -- ADD (A1 Format)
            when "0000010" => temp_result := std_logic_vector(signed(in1) - signed(in2));                               -- SUB (A1 Format)
            when "0000011" => temp_result_mul := std_logic_vector(signed(in1) * signed(in2));                           -- MUL (A1 Format)
                temp_result:= temp_result_mul(15 downto 0);  -- wallacetree                          
            when "0000100" => temp_result := in1 NAND in2;                                                              -- NAND (A1 Format)
            when "0000101" => temp_result := std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(shift))));    -- SHL (A2 Format)
            when "0000110" => temp_result := std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(shift))));   -- SHR (A2 Format)
            when "0000111" =>                                                                                           -- TEST (A3 Format)
                temp_result := (others => '0');
                if (in1 = "0000000000000000") then
                    zero_flag <= '1';
                else
                    zero_flag <= '0';
                end if;
                if (signed(in1) < 0) then
                    negative_flag <= '1';
                else
                    negative_flag <= '0';
                end if;

            -- Default case
            when others => temp_result := (others => '0'); -- Default NOP
        end case;

        -- Output result
        alu_out <= temp_result;
       
--        -- Set Flags
--        if (temp_result = "0000000000000000") then
--            zero_flag <= '1';
--        else
--            zero_flag <= '0';
--        end if;
--        if (signed(temp_result) < 0) then
--            negative_flag <= '1';
--        else
--            negative_flag <= '0';
--        end if;

    end process;
end behavioral;