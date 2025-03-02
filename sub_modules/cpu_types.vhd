-- subtype used in design
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;

package cpu_types is
    type statetype is (RESET, DECODE);    
        -- ALU Operations        
    constant NOP      : std_logic_vector(6 downto 0) := "0000000";
    constant ADD      : std_logic_vector(6 downto 0) := "0000001";
    constant SUB      : std_logic_vector(6 downto 0) := "0000010";
    constant MUL      : std_logic_vector(6 downto 0) := "0000011";
    constant NAND_OP  : std_logic_vector(6 downto 0) := "0000100";
    constant SHL      : std_logic_vector(6 downto 0) := "0000101";
    constant SHR      : std_logic_vector(6 downto 0) := "0000110";
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

    -- fix git pls
end cpu_types ;