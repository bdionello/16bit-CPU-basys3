-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all;

entity cpu_top is port (
    stm_sys_clk : in std_logic;
    rst_ex : in std_logic; -- btnr button on baysys3 "right for run"
    rst_ld : in std_logic; -- btnl button on baysys3 "left for load"
    in_port : in word_t; -- only 15 to 5 is used
    out_port : out word_t
    );
end entity cpu_top ;

architecture rtl of cpu_top is
    signal sys_rst_i : std_logic;
    signal reg_dest_i : std_logic;
    signal branch_i : std_logic;
    signal mem_to_reg_i : std_logic;
    signal mem_read_i : std_logic;
    signal mem_write_i : std_logic;
    signal alu_src_i : std_logic;
    signal reg_write_i : std_logic;
    signal alu_op_i : alu_op_t;
    signal op_code_i : word_t; -- instruction 
        
begin
    dp_0: entity work.datapath port map(
        -- system ports
        sys_clk => stm_sys_clk,
        in_port => in_port, 
        -- controller signal ports
        sys_rst => sys_rst_i,
        alu_op => alu_op_i,                
        alu_src => alu_src_i,        
        reg_dst => reg_dest_i,
        branch => branch_i,
        mem_read => mem_read_i,
        mem_write => mem_write_i,
        mem_to_reg => mem_to_reg_i,
        reg_write => reg_write_i,
        -- outputs
        data_out => out_port,
        op_code_out => op_code_i
        );    
    ctrl_0: entity work.controller port map (
        -- inputs    
        clk => stm_sys_clk,
        reset_ex => rst_ex,
        reset_ld => rst_ld,
        op_code => op_code_i,
        -- output
        sys_rst => sys_rst_i,
        alu_op => alu_op_i,                
        alu_src => alu_src_i,        
        reg_dst => reg_dest_i,
        branch => branch_i,
        mem_read => mem_read_i,
        mem_write => mem_write_i,
        mem_to_reg => mem_to_reg_i,
        reg_write => reg_write_i       
        );
end rtl ;
