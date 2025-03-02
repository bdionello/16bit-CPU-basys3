-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;
use work.cpu_components.all ;

entity cpu_top is port (
 stm_sys_clk : IN std_logic;
 rst_ex : IN std_logic; -- BTNR button on BAYSYS3 "right for run"
 rst_ld : IN std_logic; -- BTNL button on BAYSYS3  "left for load"
 IN_port : IN std_logic_vector (15 downto 0); -- only 15 to 5 is used
 OUT_port : OUT std_logic_vector (15 downto 0)
 );
end cpu_top ;

architecture rtl of cpu_top is
    signal sys_rst_s, reg_dest_s, branch_s RAM_mem_rd_s, RAM_mem_to_reg_s, ROM_mem_rd_s, ROM_mem_to_reg_s, RAM_mem_wr_s, ROM_mem_wr_s, alu_src_s, reg_wr_s, reset_load, STD_LOGIC;
    signal alu_op_s STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal inst_s std_logic_vector (15 downto 0); -- instruction 
begin
    dp_0: ENTITY work.datapath port map (
        -- system ports
        sys_clk => stm_sys_clk;  
        sys_rst => sys_rst_s;
        IN_port => IN_port;  
        -- controller signal ports
        reg_dst => reg_dest_s; -- MUX control for which register to use from instruction; 
        branch => branch_s;
        RAM_mem_rd => RAM_mem_rd_s;
        RAM_mem_to_reg => RAM_mem_to_reg_s;
        ROM_mem_rd => ROM_mem_rd_s;
        ROM_mem_to_reg => ROM_mem_to_reg_s;
        alu_op => alu_op_s;
        RAM_mem_wr => RAM_mem_wr_s;
        ROM_mem_wr => ROM_mem_wr_s;
        alu_src => alu_src_s;
        reg_wr => reg_wr_s
        -- outputs
        OUT_p => OUT_port;
        inst_out inst_s
    ) ;    
    ctrl_0: ENTITY work.controller port map (
        -- inputs    
        clk => stm_sys_clk;
        reset_ex => rst_ex;
        reset_ld => rst_ld;
        inst_in => inst_s;
        -- outputs
        reg_dst => reg_dest_s;
        branch => branch_s;
        RAM_mem_rd RAM_mem_rd_s;
        RAM_mem_to_reg => RAM_mem_to_reg_s;
        ROM_mem_rd => ROM_mem_rd_s;
        ROM_mem_to_reg => ROM_mem_to_reg_s;
        alu_op => alu_op_s; 
        RAM_mem_wr => RAM_mem_wr_s;
        ROM_mem_wr => ROM_mem_wr_s;
        alu_src => alu_src_s;
        reg_wr => reg_wr_s   
    ) ;

end rtl ;

