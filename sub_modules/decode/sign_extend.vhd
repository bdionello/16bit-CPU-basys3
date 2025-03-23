library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all;

entity sign_extend is
    port (
        op_code         : in std_logic_vector(6 downto 0) := (others => '0');  -- Opcode from Decode Stage
        disp_l          : in std_logic_vector(8 downto 0) := (others => '0');  -- Long displacement (for BRR)
        disp_s          : in std_logic_vector(5 downto 0) := (others => '0');  -- Short displacement (for BR)
        extended_disp   : out word_t  -- Short displacement (for BR)
    );
end sign_extend;

architecture Behavioral of sign_extend is
    
    begin    
        process (op_code, disp_l, disp_s) is
            variable sign_extended_displacement : word_t;                
        begin
            case op_code is
                when BRR | BRR_N | BRR_Z =>  
                    -- Sign-extend disp_l to 16 bits and multiply by 2
                    sign_extended_displacement := std_logic_vector(resize(signed(disp_l), 16));
                    
                when BR | BR_SUB | BR_N | BR_Z  =>
                    -- Sign-extend disp_s to 16 bits and multiply by 2
                    sign_extended_displacement := std_logic_vector(resize(signed(disp_s), 16));
                    
                when others => 
                    sign_extended_displacement := (others => '0');
                end case;                
                extended_disp <= sign_extended_displacement(14 downto 0) & '0';
        end process;
end Behavioral;
