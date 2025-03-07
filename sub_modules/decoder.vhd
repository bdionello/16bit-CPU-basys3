-- decoder
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all ;

entity decoder is
    port(
        instr            : in std_logic_vector(15 downto 0);  -- Input instruction
        instr_decoded    : out  instruction_type
    );
end decoder;

architecture Behavioural of decoder is

    -- Internal signals
    signal operation : std_logic_vector(6 downto 0);
begin
    -- Extract the opcode from the instruction
    operation <= instr(15 downto 9);

    -- Decode process
    decode: process(operation, instr) is
    begin
     -- default
     instr_decoded <= instruction_type_init_c;

        case operation is
            when NOP | RETURN_OP =>
                instr_decoded.opcode <= instr(15 downto 9);

            when ADD | SUB | MUL | NAND_OP =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);
                instr_decoded.rb <= instr(5 downto 3);
                instr_decoded.rc <= instr(2 downto 0);

            when SHL_OP | SHR_OP =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);
                instr_decoded.shift <= instr(3 downto 0);

            when TEST =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);                

            when OUT_OP =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);
                instr_decoded.out_port_ctl <= '1';
                
            when IN_OP =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);
                instr_decoded.in_port_ctl <= '1';                                

            when BRR | BRR_N | BRR_Z =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.disp_l <= instr(8 downto 0);

            when BR | BR_N | BR_Z | BR_SUB =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.ra <= instr(8 downto 6);
                instr_decoded.disp_s <= instr(5 downto 0);

            when LOAD | STORE | MOV =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.r_dest <= instr(8 downto 6);
                instr_decoded.r_src <= instr(5 downto 3);

            when LOADIMM =>
                instr_decoded.opcode <= instr(15 downto 9);
                instr_decoded.m_1 <= instr(8);
                instr_decoded.imm <= instr(7 downto 0);
                
            when others => NULL;
        end case;
    end process; -- Decode
end Behavioural; -- Behavioural