library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity ALU is
    port(
        in1      : in std_logic_vector(15 downto 0);  -- First operand
        in2      : in std_logic_vector(15 downto 0);  -- Second operand

        alu_mode : in alu_op_type := alu_NOP;    -- ALU opcode (7-bit)
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
    -- alu_NOP, alu_ADD, alu_SUB, alu_MUL, alu_NAND, alu_SHL, alu_SHR, alu_TEST
        case alu_mode is
            -- A-Format Instructions
            when alu_NOP => temp_result := (others => '0');                                                           -- NOP (A0 Format)
            when alu_ADD => temp_result := std_logic_vector(signed(in1) + signed(in2));                               -- ADD (A1 Format)
            when alu_SUB => temp_result := std_logic_vector(signed(in1) - signed(in2));                               -- SUB (A1 Format)
            when alu_MUL => temp_result_mul := std_logic_vector(signed(in1) * signed(in2));                           -- MUL (A1 Format)
                temp_result:= temp_result_mul(15 downto 0);  -- Look into wallacetree                          
            when alu_NAND => temp_result := in1 NAND in2;                                                             -- NAND (A1 Format)
            when alu_SHL => temp_result := std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(shift))));  -- SHL (A2 Format)
            when alu_SHR => temp_result := std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(shift)))); -- SHR (A2 Format)
            when alu_TEST =>                                                                                          -- TEST (A3 Format)
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

    end process;
end behavioral;