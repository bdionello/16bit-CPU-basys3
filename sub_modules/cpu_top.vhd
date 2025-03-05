-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use work.cpu_types.all ;
use work.cpu_components.all ;

entity cpu_top is port (
    stm_sys_clk : in std_logic;
    rst_ex : in std_logic; -- btnr button on baysys3 "right for run"
    rst_ld : in std_logic; -- btnl button on baysys3  "left for load"
    in_port : in std_logic_vector (15 downto 0); -- only 15 to 5 is used
    out_port : out std_logic_vector (15 downto 0)
    );
end entity cpu_top ;

architecture rtl of cpu_top is
    signal sys_rst_s, reg_dest_s, branch_s, ram_mem_rd_s, ram_mem_to_reg_s, rom_mem_rd_s, rom_mem_to_reg_s, ram_mem_wr_s, rom_mem_wr_s, alu_src_s, reg_wr_s, reset_load: std_logic;
    signal alu_op_s : std_logic_vector(2 downto 0);
    signal inst_s : std_logic_vector (15 downto 0); -- instruction 
begin
    dp_0: entity work.datapath port map(
        -- system ports
        sys_clk => stm_sys_clk,
        sys_rst => sys_rst_s,
        in_port => in_port, 
        -- controller signal ports
        reg_dst => reg_dest_s, -- mux control for which register to use from instruction; 
        branch => branch_s,
        ram_mem_rd => ram_mem_rd_s,
        ram_mem_to_reg => ram_mem_to_reg_s,
        rom_mem_rd => rom_mem_rd_s,
        rom_mem_to_reg => rom_mem_to_reg_s,
        alu_op => alu_op_s,
        ram_mem_wr => ram_mem_wr_s,
        rom_mem_wr => rom_mem_wr_s,
        alu_src => alu_src_s,
        reg_wr => reg_wr_s,
        -- outputs
        data_out => out_port,
        inst_out => inst_s
        );    
    ctrl_0: entity work.controller port map (
        -- inputs    
        clk => stm_sys_clk,
        reset_ex => rst_ex,
        reset_ld => rst_ld,
        inst_in => inst_s,
        -- output
        reg_dst => reg_dest_s,
        branch => branch_s,
        ram_mem_rd => ram_mem_rd_s,
        ram_mem_to_reg => ram_mem_to_reg_s,
        rom_mem_rd => rom_mem_rd_s,
        rom_mem_to_reg => rom_mem_to_reg_s,
        alu_op => alu_op_s,
        ram_mem_wr => ram_mem_wr_s,
        rom_mem_wr => rom_mem_wr_s,
        alu_src => alu_src_s,
        reg_wr => reg_wr_s 
        );

end rtl ;

