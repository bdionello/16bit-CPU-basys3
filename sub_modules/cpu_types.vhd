-- subtype and constants used in design
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;

package cpu_types is
    type state_type is (RESET_STATE, DECODE);
    subtype word_t is std_logic_vector(15 downto 0); -- 2 bytes word = 16 bits
    subtype op_code_t is std_logic_vector(6 downto 0);
    subtype alu_op_t is std_logic_vector(2 downto 0);
    
    constant step_size_c : word_t := X"0002";
           
    -- ALU Operations
    constant NOP      : op_code_t := "0000000";
    constant ADD      : op_code_t := "0000001";
    constant SUB      : op_code_t := "0000010";
    constant MUL      : op_code_t := "0000011";
    constant NAND_OP  : op_code_t := "0000100";
    constant SHL_OP   : op_code_t := "0000101";
    constant SHR_OP   : op_code_t := "0000110";
    constant TEST     : op_code_t := "0000111";
    constant OUT_OP   : op_code_t := "0100000";
    constant IN_OP    : op_code_t := "0100001";
    
    -- Branch Operations
    constant BRR      : op_code_t := "1000000";
    constant BRR_N    : op_code_t := "1000001";
    constant BRR_Z    : op_code_t := "1000010";
    constant BR       : op_code_t := "1000011";
    constant BR_N     : op_code_t := "1000100";
    constant BR_Z     : op_code_t := "1000101";
    constant BR_SUB   : op_code_t := "1000110";
    constant RETURN_OP: op_code_t := "1000111";

    -- Load/Store Operations
    constant LOAD     : op_code_t := "0010000";
    constant STORE    : op_code_t := "0010001";
    constant LOADIMM  : op_code_t := "0010010";
    constant MOV      : op_code_t := "0010011";

end cpu_types ;