library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all;

entity branch_unit is
    Port (
        -- Inputs
        op_code         : in std_logic_vector(6 downto 0);  -- Opcode from Decode Stage
        pc_current      : in word_t;  -- Current PC value
        reg_data        : in word_t;  -- Data from register (for BR instructions)
        disp_l          : in std_logic_vector(8 downto 0);  -- Long displacement (for BRR)
        disp_s          : in std_logic_vector(5 downto 0);  -- Short displacement (for BR)
        alu_n           : in std_logic;  -- Negative flag from ALU
        alu_z           : in std_logic;  -- Zero flag from ALU        
        -- Outputs
        branch_taken    : out std_logic;  -- Branch taken signal
        branch_target   : out word_t  -- Calculated branch target address
        --sign_extended_displacement : out word_t  -- Sign-extended and multiplied displacement
    );
end branch_unit;

architecture Behavioral of branch_unit is
begin
    process (op_code, pc_current, reg_data, disp_l, disp_s, alu_n, alu_z) is
        variable displacement_l : word_t;
        variable displacement_s : word_t;
    begin
        -- Default values
        branch_taken <= '0';
        branch_target <= (others => '0');

        -- Handle branch instructions
        case op_code is
            -- B1 format branch instructions
            when BRR =>              
                -- Calculate branch target address
                branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(displacement_l));
                branch_taken <= '1';

            when BRR_N => -- BRR.N
                if alu_n = '1' then
                    -- If negative
                    -- Calculate branch target address
                    branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(displacement_l));
                    branch_taken <= '1';
                else
                    -- If not negative, PC = PC + 2 (next instruction)
                    branch_target <= std_logic_vector(unsigned(pc_current) + 2);
                    branch_taken <= '0';
                end if;

            when BRR_Z => -- BRR.Z
                if alu_z = '1' then
                    -- If zero
                    -- Calculate branch target address
                    branch_target <= std_logic_vector(unsigned(pc_current) + unsigned(displacement_l));
                    branch_taken <= '1';
                else
                    -- If not zero, PC = PC + 2 (next instruction)
                    branch_target <= std_logic_vector(unsigned(pc_current) + 2);
                    branch_taken <= '0';
                end if;

            -- B2 format branch instructions
            when BR | BR_SUB => -- BR or BR.SUB
                -- Calculate branch target address
                branch_target <= std_logic_vector(unsigned(reg_data) + unsigned(displacement_s));
                branch_taken <= '1';

            when BR_N => -- BR.N
                if alu_n = '1' then
                    -- If negative
                    -- Calculate branch target address
                    branch_target <= std_logic_vector(unsigned(reg_data) + unsigned(displacement_s));
                    branch_taken <= '1';
                else
                    -- If not negative, PC = PC + 2 (next instruction)
                    branch_target <= std_logic_vector(unsigned(pc_current) + 2);
                    branch_taken <= '0';
                end if;

            when BR_Z => -- BR.Z
                if alu_z = '1' then
                    -- If zero
                    -- Calculate branch target address
                    branch_target <= std_logic_vector(unsigned(reg_data) + unsigned(displacement_s));
                    branch_taken <= '1';
                else
                    -- If not zero, PC = PC + 2 (next instruction)
                    branch_target <= std_logic_vector(unsigned(pc_current) + 2);
                    branch_taken <= '0';
                end if;

            -- RETURN instruction
            when RETURN_OP =>
                -- Use the value of R7 as the branch target
                branch_target <= reg_data;
                branch_taken <= '1';

            when others =>
                -- Default case (no branch)
                branch_target <= (others => '0');
                branch_taken <= '0';
        end case;

    end process;
end Behavioral;