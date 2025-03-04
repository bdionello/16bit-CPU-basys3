library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity Decoder is
    port(
        instr        : in std_logic_vector(15 downto 0);  -- Input instruction
        opcode       : out std_logic_vector(6 downto 0);  -- Opcode
        ra           : out std_logic_vector(2 downto 0);  -- Register A
        rb           : out std_logic_vector(2 downto 0);  -- Register B
        rc           : out std_logic_vector(2 downto 0);  -- Register C
        shift        : out std_logic_vector(3 downto 0);  -- Shift amount

        disp_s       : out std_logic_vector(5 downto 0);  -- Displacement (short)
        disp_l       : out std_logic_vector(8 downto 0);  -- Displacement (long)

        m_1          : out std_logic;                     -- Mode bit
        in_port_ctl  : out std_logic;                     -- Control line for IN inst. mux
        out_port_ctl : out std_logic;                     -- Control line for OUT inst. mux
        imm          : out std_logic_vector(7 downto 0);  -- Immediate value

        r_dest       : out std_logic_vector(2 downto 0);  -- Destination register
        r_src        : out std_logic_vector(2 downto 0)   -- Source register
    );
end Decoder;

architecture Behavioural of Decoder is
    -- ALU Operations
    constant NOP      : std_logic_vector(6 downto 0) := "0000000";
    constant ADD      : std_logic_vector(6 downto 0) := "0000001";
    constant SUB      : std_logic_vector(6 downto 0) := "0000010";
    constant MUL      : std_logic_vector(6 downto 0) := "0000011";
    constant NAND_OP  : std_logic_vector(6 downto 0) := "0000100";
    constant SHL_OP   : std_logic_vector(6 downto 0) := "0000101";
    constant SHR_OP   : std_logic_vector(6 downto 0) := "0000110";
    constant TEST     : std_logic_vector(6 downto 0) := "0000111";
    constant OUT_OP   : std_logic_vector(6 downto 0) := "0100000";
    constant IN_OP    : std_logic_vector(6 downto 0) := "0100001";

    -- Branch Operations
    constant BRR      : std_logic_vector(6 downto 0) := "1000000";
    constant BRR_N    : std_logic_vector(6 downto 0) := "1000001";
    constant BRR_Z    : std_logic_vector(6 downto 0) := "1000010";
    constant BR       : std_logic_vector(6 downto 0) := "1000011";
    constant BR_N     : std_logic_vector(6 downto 0) := "1000100";
    constant BR_Z     : std_logic_vector(6 downto 0) := "1000101";
    constant BR_SUB   : std_logic_vector(6 downto 0) := "1000110";
    constant RETURN_OP: std_logic_vector(6 downto 0) := "1000111";

    -- Load/Store Operations
    constant LOAD     : std_logic_vector(6 downto 0) := "0010000";
    constant STORE    : std_logic_vector(6 downto 0) := "0010001";
    constant LOADIMM  : std_logic_vector(6 downto 0) := "0010010";
    constant MOV      : std_logic_vector(6 downto 0) := "0010011";

    -- Internal signals
    signal operation : std_logic_vector(6 downto 0);
begin
    -- Extract the opcode from the instruction
    operation <= instr(15 downto 9);

    -- Decode process
    Decode: process(operation, instr) is
    begin
        -- Default values
        opcode <= (others => '0');
        ra <= (others => '0');
        rb <= (others => '0');
        rc <= (others => '0');
        shift <= (others => '0');
        disp_s <= (others => '0');
        disp_l <= (others => '0');
        in_port_ctl <= '0';
        out_port_ctl <= '0';
        m_1 <= '0';
        imm <= (others => '0');
        r_dest <= (others => '0');
        r_src <= (others => '0');

        case operation is
            when NOP | RETURN_OP =>
                opcode <= instr(15 downto 9);

            when ADD | SUB | MUL | NAND_OP =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);
                rb <= instr(5 downto 3);
                rc <= instr(2 downto 0);

            when SHL_OP | SHR_OP =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);
                shift <= instr(3 downto 0);

            when TEST =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);                

            when OUT_OP =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);
                out_port_ctl <= '1';
                
            when IN_OP =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);
                in_port_ctl <= '1';                                

            when BRR | BRR_N | BRR_Z =>
                opcode <= instr(15 downto 9);
                disp_l <= instr(8 downto 0);

            when BR | BR_N | BR_Z | BR_SUB =>
                opcode <= instr(15 downto 9);
                ra <= instr(8 downto 6);
                disp_s <= instr(5 downto 0);

            when LOAD | STORE | MOV =>
                opcode <= instr(15 downto 9);
                r_dest <= instr(8 downto 6);
                r_src <= instr(5 downto 3);

            when LOADIMM =>
                opcode <= instr(15 downto 9);
                m_1 <= instr(8);
                imm <= instr(7 downto 0);

            when others => NULL;
        end case;
    end process; -- Decode
end Behavioural; -- Behavioural