-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;
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
    signal reg_src_i : std_logic;
    signal decode_ctl_i : decode_type;   
    signal ex_stage_ctl_i : execute_type;
    signal mem_stage_ctl_i : memory_type;   
    signal wb_stage_ctl_i : write_back_type;    
    signal op_code_i : op_code_t; -- instruction
    signal boot_mode_i : boot_mode_type := BOOT_LOAD; 
        
begin
    dp_0: entity work.datapath port map(
        -- inputs
        sys_clk => stm_sys_clk,
        sys_rst => sys_rst_i,
        in_port => in_port,
        -- control inputs
        boot_mode => boot_mode_i,
        decode_ctl => decode_ctl_i,
        execute_ctl => ex_stage_ctl_i,
        memory_ctl => mem_stage_ctl_i,
        write_back_ctl => wb_stage_ctl_i, 
        -- outputs
        out_port => out_port,
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
        boot_mode => boot_mode_i,
        decode_ctl => decode_ctl_i,
        execute_ctl => ex_stage_ctl_i,
        memory_ctl => mem_stage_ctl_i,
        write_back_ctl => wb_stage_ctl_i    
        );
end rtl ;
