-- CPU
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;
use work.cpu_types.all;

entity cpu_top is port (
    stm_sys_clk   : in std_logic;
    rst_ex        : in std_logic; -- btnr button on baysys3 "right for run"
    rst_ld        : in std_logic; -- btnl button on baysys3 "left for load"
    in_port       : in STD_LOGIC_VECTOR(15 DOWNTO 6); -- only 15 to 6 is used
    dip_switches  : in word_t; 
    out_port      : out word_t;    
    stm_ack       : out std_logic;  
     
    
    -- Debug display console ports to constraints
    board_clock   : in std_logic;
    
    -- Debug display 7-segment LED ports to constraints
    led_segments  : out STD_LOGIC_VECTOR( 6 downto 0 );
    led_digits    : out STD_LOGIC_VECTOR( 3 downto 0 );
    


    vga_red       : out std_logic_vector( 3 downto 0 );
    vga_green     : out std_logic_vector( 3 downto 0 );
    vga_blue      : out std_logic_vector( 3 downto 0 );

    h_sync_signal : out std_logic;
    v_sync_signal : out std_logic
    );
end entity cpu_top ;

architecture rtl of cpu_top is
    signal sys_rst_i          : std_logic;
    signal ctl_wr_enable_i    : std_logic;
    signal debug_console_i    : std_logic;  -- switch from video memory to debug console
    signal display_enable_i    : std_logic; -- enable video memory write or 7 seg write
    signal decode_ctl_i       : decode_type;   
    signal ex_stage_ctl_i     : execute_type;
    signal mem_stage_ctl_i    : memory_type;   
    signal wb_stage_ctl_i     : write_back_type;    
    signal op_code_i          : op_code_t; -- instruction
    signal boot_mode_i        : boot_mode_type;
    signal led_7seg_data_i    : word_t;
    signal video_data_i       : word_t;
    signal display_addr_i     : word_t; -- address for video display or 7 seg
    signal out_port_i         : word_t;
    signal in_port_i          : word_t;
    signal dip_switches_i     : word_t;    
    -- Console Display signals
    signal display_fetch_i    :  display_fetch_type;
    signal display_decode_i   :  display_decode_type;  
    signal display_execute_i  :  display_execute_type;
    signal display_memory_i   :  display_memory_type;
    signal display_register_i :  display_register_type;
          
begin
  
    debug_console_i <= dip_switches_i(15);    
    dip_switches_i <= dip_switches;
    out_port <= out_port_i;
    stm_ack <= out_port_i(0);
    in_port_i <= in_port(15 downto 6) & "000000";
    -------------- CPU System --------------------------
    dp_0: entity work.datapath
        port map(
            -- inputs
            sys_clk => stm_sys_clk,
            sys_rst => sys_rst_i,
            in_port => in_port_i,
            dip_switches => dip_switches_i,
            -- control inputs
            boot_mode => boot_mode_i,
            decode_ctl => decode_ctl_i,
            execute_ctl => ex_stage_ctl_i,
            memory_ctl => mem_stage_ctl_i,
            write_back_ctl => wb_stage_ctl_i, 
            -- outputs
            video_data => video_data_i,
            display_enable => display_enable_i,
            display_data_addr => display_addr_i,
            ctl_wr_enable => ctl_wr_enable_i,
            out_port => out_port_i,
            op_code_out => op_code_i,
            led_7seg_data => led_7seg_data_i,
            -- Display console signals
            display_fetch => display_fetch_i,
            display_decode => display_decode_i,
            display_execute => display_execute_i,
            display_memory => display_memory_i,
            display_register => display_register_i           
        );    
    ctrl_0: entity work.controller 
        port map (
            -- inputs    
            clk => stm_sys_clk,
            reset_ex => rst_ex,
            reset_ld => rst_ld,
            wr_enable => ctl_wr_enable_i,
            op_code => op_code_i,
            -- output
            sys_rst => sys_rst_i,
            boot_mode => boot_mode_i,
            decode_ctl => decode_ctl_i,
            execute_ctl => ex_stage_ctl_i,
            memory_ctl => mem_stage_ctl_i,
            write_back_ctl => wb_stage_ctl_i    
        );
        
   ------------ Debug and display --------------    
   led_display_memory : entity work.led_display
       port map (       
               addr_write => display_addr_i,
               clk => stm_sys_clk,
               data_in => led_7seg_data_i,
               en_write => display_enable_i,       
               board_clock => board_clock,
               led_segments => led_segments,
               led_digits => led_digits
           );   
       
   console_display : entity work.console
        port map (
        --
        -- Stage 1 Fetch
        --
            s1_pc => display_fetch_i.s1_pc,
            s1_inst => display_fetch_i.s1_inst,        
        --
        -- Stage 2 Decode
        --        
            s2_pc => display_decode_i.s2_pc,
            s2_inst => display_decode_i.s2_inst,        
            s2_reg_a => display_decode_i.s2_reg_a,
            s2_reg_b => display_decode_i.s2_reg_b,
            s2_reg_c => display_decode_i.s2_reg_c,        
            s2_reg_a_data => x"0000",
            s2_reg_b_data => display_decode_i.s2_reg_b_data,
            s2_reg_c_data => display_decode_i.s2_reg_c_data,
            s2_immediate => display_decode_i.s2_immediate,        
        --
        -- Stage 3 Execute
        --        
            s3_pc => display_execute_i.s3_pc,
            s3_inst => display_execute_i.s3_inst,        
            s3_reg_a => display_execute_i.s3_reg_a,
            s3_reg_b => "000",
            s3_reg_c => "000",        
            s3_reg_a_data => x"0000",
            s3_reg_b_data => display_execute_i.s3_reg_b_data,
            s3_reg_c_data => display_execute_i.s3_reg_c_data,
            s3_immediate => display_execute_i.s3_immediate,        
            s3_r_wb => display_execute_i.s3_r_wb,
            s3_r_wb_data => display_execute_i.s3_r_wb_data,        
            s3_br_wb => display_execute_i.s3_br_wb,
            s3_br_wb_address => display_execute_i.s3_br_wb_address,        
            s3_mr_wr => display_execute_i.s3_mr_wr,
            s3_mr_wr_address => display_execute_i.s3_mr_wr_address,
            s3_mr_wr_data => display_execute_i.s3_mr_wr_data,        
            s3_mr_rd => display_execute_i.s3_mr_rd,
            s3_mr_rd_address => display_execute_i.s3_mr_rd_address,        
        --
        -- Stage 4 Memory
        --        display_memory_i
            s4_pc => display_memory_i.s4_pc,
            s4_inst => display_memory_i.s4_inst,
            s4_reg_a => display_memory_i.s4_reg_a,
            s4_r_wb => display_memory_i.s4_r_wb,
            s4_r_wb_data => display_memory_i.s4_r_wb_data,        
        --
        -- CPU registers
        --        
            register_0 => display_register_i.register_0,
            register_1 => display_register_i.register_1,
            register_2 => display_register_i.register_2,
            register_3 => display_register_i.register_3,
            register_4 => display_register_i.register_4,
            register_5 => display_register_i.register_5,
            register_6 => display_register_i.register_6,
            register_7 => display_register_i.register_7,        
            register_0_of => display_register_i.register_0_of,
            register_1_of => display_register_i.register_1_of,
            register_2_of => display_register_i.register_2_of,
            register_3_of => display_register_i.register_3_of,
            register_4_of => display_register_i.register_4_of,
            register_5_of => display_register_i.register_5_of,
            register_6_of => display_register_i.register_6_of,
            register_7_of => display_register_i.register_7_of,      
        --
        -- CPU Flags
        --
            zero_flag => display_execute_i.zero_flag,
            negative_flag => display_execute_i.negative_flag,
            overflow_flag => display_execute_i.overflow_flag,        
        --
        -- Debug screen enable
        --
            debug => debug_console_i,        
        --
        -- Text console display memory access signals ( clk is the processor clock )
        --        
            clk => stm_sys_clk,
            addr_write => display_addr_i,
            data_in => video_data_i,
            en_write => display_enable_i,        
        --
        -- Video related signals
        --        
            board_clock => board_clock,
            h_sync_signal => h_sync_signal,
            v_sync_signal => v_sync_signal,
            vga_red => vga_red,
            vga_green => vga_green,
            vga_blue => vga_blue
        );        
end rtl ;
