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
    out_port      : out word_t;
    stm_ack       : out std_logic;    
    
    -- Debug display console ports to constraints
    debug_console : in STD_LOGIC;
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
    signal sys_rst_i       : std_logic;
    signal ctl_wr_enable_i : std_logic;
    signal decode_ctl_i    : decode_type;   
    signal ex_stage_ctl_i  : execute_type;
    signal mem_stage_ctl_i : memory_type;   
    signal wb_stage_ctl_i  : write_back_type;    
    signal op_code_i       : op_code_t; -- instruction
    signal boot_mode_i     : boot_mode_type;
    signal led_7seg_data_i : word_t;
    signal out_port_i      : word_t;
    signal in_port_i       : word_t;
    
    -- Console Display signals
    signal display_fetch_i  :  display_fetch_type;    
    
    component led_display is
        Port (    
            addr_write : in  STD_LOGIC_VECTOR (15 downto 0);
            clk : in  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR (15 downto 0);
            en_write : in  STD_LOGIC;    
            board_clock : in STD_LOGIC;
            led_segments : out STD_LOGIC_VECTOR( 6 downto 0 );
            led_digits : out STD_LOGIC_VECTOR( 3 downto 0 )
        );
    end component;
    component console is
          port (      
      --
      -- Stage 1 Fetch
      --
              s1_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
              s1_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );     
      --
      -- Stage 2 Decode
      --
              s2_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
              s2_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );      
              s2_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );
              s2_reg_b : in STD_LOGIC_VECTOR( 2 downto 0 );
              s2_reg_c : in STD_LOGIC_VECTOR( 2 downto 0 );      
              s2_reg_a_data : in STD_LOGIC_VECTOR( 15 downto 0 );
              s2_reg_b_data : in STD_LOGIC_VECTOR( 15 downto 0 );
              s2_reg_c_data : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s2_immediate : in STD_LOGIC_VECTOR( 15 downto 0 );
      --
      -- Stage 3 Execute
      --
              s3_pc : in STD_LOGIC_VECTOR ( 15 downto 0 );
              s3_inst : in STD_LOGIC_VECTOR ( 15 downto 0 );      
              s3_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );
              s3_reg_b : in STD_LOGIC_VECTOR( 2 downto 0 );
              s3_reg_c : in STD_LOGIC_VECTOR( 2 downto 0 );      
              s3_reg_a_data : in STD_LOGIC_VECTOR( 15 downto 0 );
              s3_reg_b_data : in STD_LOGIC_VECTOR( 15 downto 0 );
              s3_reg_c_data : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s3_immediate : in STD_LOGIC_VECTOR( 15 downto 0 );   
      --
      -- Branch and memory operation
      --
              s3_r_wb : in STD_LOGIC;
              s3_r_wb_data : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s3_br_wb : in STD_LOGIC;
              s3_br_wb_address : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s3_mr_wr : in STD_LOGIC;
              s3_mr_wr_address : in STD_LOGIC_VECTOR( 15 downto 0 );
              s3_mr_wr_data : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s3_mr_rd : in STD_LOGIC;
              s3_mr_rd_address : in STD_LOGIC_VECTOR( 15 downto 0 );     
      --
      -- Stage 4 Memory
      --
              s4_pc : in STD_LOGIC_VECTOR( 15 downto 0 );
              s4_inst : in STD_LOGIC_VECTOR( 15 downto 0 );      
              s4_reg_a : in STD_LOGIC_VECTOR( 2 downto 0 );      
              s4_r_wb : in STD_LOGIC;
              s4_r_wb_data : in STD_LOGIC_VECTOR( 15 downto 0 );      
      --
      -- CPU registers
      --      
              register_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_1 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_4 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_5 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_6 : in STD_LOGIC_VECTOR ( 15 downto 0 );
              register_7 : in STD_LOGIC_VECTOR ( 15 downto 0 );      
      --
      -- CPU registers overflow flags
      --
              register_0_of : in STD_LOGIC;
              register_1_of : in STD_LOGIC;
              register_2_of : in STD_LOGIC;
              register_3_of : in STD_LOGIC;
              register_4_of : in STD_LOGIC;
              register_5_of : in STD_LOGIC;
              register_6_of : in STD_LOGIC;
              register_7_of : in STD_LOGIC;      
      --
      -- CPU Flags
      --
              zero_flag : in STD_LOGIC;
              negative_flag : in STD_LOGIC;
              overflow_flag : in STD_LOGIC;      
      --
      -- Debug screen enable
      --
              debug : in STD_LOGIC;      
      --
      -- Text console display memory access signals ( clk is the processor clock )
      --
              addr_write : in  STD_LOGIC_VECTOR (15 downto 0);
              clk : in  STD_LOGIC;
              data_in : in  STD_LOGIC_VECTOR (15 downto 0);
              en_write : in  STD_LOGIC;     
      --
      -- Video related signals
      --
              board_clock : in STD_LOGIC;
              v_sync_signal : out STD_LOGIC;
              h_sync_signal : out STD_LOGIC;
              vga_red : out STD_LOGIC_VECTOR( 3 downto 0 );
              vga_green : out STD_LOGIC_VECTOR( 3 downto 0 );
              vga_blue : out STD_LOGIC_VECTOR( 3 downto 0 )      
          );
      end component; 
        
begin
    stm_ack <= out_port_i(0);
    out_port <= out_port_i;
    in_port_i <= in_port(15 downto 6) & "000000";
    -------------- CPU System --------------------------
    dp_0: entity work.datapath
        port map(
            -- inputs
            sys_clk => stm_sys_clk,
            sys_rst => sys_rst_i,
            in_port => in_port_i,
            -- control inputs
            boot_mode => boot_mode_i,
            decode_ctl => decode_ctl_i,
            execute_ctl => ex_stage_ctl_i,
            memory_ctl => mem_stage_ctl_i,
            write_back_ctl => wb_stage_ctl_i, 
            -- outputs
            ctl_wr_enable => ctl_wr_enable_i,
            out_port => out_port_i,
            op_code_out => op_code_i,
            led_7seg_data => led_7seg_data_i,
            -- Display console signals
            display_fetch => display_fetch_i
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
   led_display_memory : led_display
       port map (       
               addr_write => x"FFF2",
               clk => stm_sys_clk,
               data_in => led_7seg_data_i,
               en_write => '1',       
               board_clock => board_clock,
               led_segments => led_segments,
               led_digits => led_digits
           );   
       
   console_display : console
        port map (
        --
        -- Stage 1 Fetch
        --
            s1_pc => display_fetch_i.s1_pc,
            s1_inst => display_fetch_i.s1_inst,        
        --
        -- Stage 2 Decode
        --        
            s2_pc => x"0000",
            s2_inst => x"0000",        
            s2_reg_a => "000",
            s2_reg_b => "000",
            s2_reg_c => "000",        
            s2_reg_a_data => x"0000",
            s2_reg_b_data => x"0000",
            s2_reg_c_data => x"0000",
            s2_immediate => x"0000",        
        --
        -- Stage 3 Execute
        --        
            s3_pc => x"0000",
            s3_inst => x"0000",        
            s3_reg_a => "000",
            s3_reg_b => "000",
            s3_reg_c => "000",        
            s3_reg_a_data => x"0000",
            s3_reg_b_data => x"0000",
            s3_reg_c_data => x"0000",
            s3_immediate => x"0000",        
            s3_r_wb => '0',
            s3_r_wb_data => x"0000",        
            s3_br_wb => '0',
            s3_br_wb_address => x"0000",        
            s3_mr_wr => '0',
            s3_mr_wr_address => x"0000",
            s3_mr_wr_data => x"0000",        
            s3_mr_rd => '0',
            s3_mr_rd_address => x"0000",        
        --
        -- Stage 4 Memory
        --        
            s4_pc => x"0000",
            s4_inst => x"0000",
            s4_reg_a => "000",
            s4_r_wb => '0',
            s4_r_wb_data => x"0000",        
        --
        -- CPU registers
        --        
            register_0 => x"0000",
            register_1 => x"0000",
            register_2 => x"0000",
            register_3 => x"0000",
            register_4 => x"0000",
            register_5 => x"0000",
            register_6 => x"0000",
            register_7 => x"0000",        
            register_0_of => '0',
            register_1_of => '0',
            register_2_of => '0',
            register_3_of => '0',
            register_4_of => '0',
            register_5_of => '0',
            register_6_of => '0',
            register_7_of => '0',        
        --
        -- CPU Flags
        --
            zero_flag => '0',
            negative_flag => '0',
            overflow_flag => '0',        
        --
        -- Debug screen enable
        --
            debug => debug_console,        
        --
        -- Text console display memory access signals ( clk is the processor clock )
        --        
            clk => '0',
            addr_write => x"0000",
            data_in => x"0000",
            en_write => '0',        
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
