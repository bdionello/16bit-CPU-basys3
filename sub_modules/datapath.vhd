-- datapath
library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
--use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all;

entity datapath is
    port (
        -- system ports
        sys_clk : in std_logic;
        sys_rst : in std_logic;
        in_port : in word_t;        
        -- controller signal ports
        -- EX
        alu_op : in alu_op_t;
        alu_src : in std_logic;
        reg_dst : in std_logic;
        -- Memory
        branch : in std_logic;        
        mem_read : in std_logic;
        mem_write : in std_logic;
        -- Write back
        mem_to_reg : in std_logic;
        reg_write : in std_logic; 
        -- outputs
        data_out : out word_t;
        op_code_out : out op_code_t
        );        
end datapath;

architecture data_path_arch of datapath is
    -- Internal signals -- Denoted by: '_i' = Not stage specific 
    -- Controller signals
    signal branch_i : std_logic := '0';
    -- Fetch Stage signals -- Denoted by: "_f'    
    signal pc_in_f : word_t := (others => '0');
    signal pc_out_f : word_t := (others => '0');
    signal pc_next_f : word_t := (others => '0');
    
    signal instruction_f : word_t := (others => '0');
    -- Decode stage signals -- Denoted by:'_d'
    signal instruction_d : word_t := (others => '0');
    signal pc_next_d : word_t := (others => '0');
        -- Propagate Only
    signal alu_op_d : alu_op_t;
    signal alu_src_d : std_logic;
    signal reg_dst_d : std_logic;
        
    -- Execute stage signals -- Denoted by:'_ex'
    signal alu_op_ex : alu_op_t;
    signal alu_src_ex : std_logic;
    signal reg_dst_ex : std_logic;
    -- Memory stage signals -- Denoted by:'_mem'    
    signal pc_branch_mem : word_t := (others => '0');
    -- Write back stage signals -- Denoted by:'_wb'       
    begin
        -- Internal signal logic
        pc_in_f <= pc_branch_mem when branch_i = '1' else pc_next_f; -- TODO AND with alu flag condition 
                
        mem: entity work.mem_manager
            port map (
                -- Shared ports
                clock => sys_clk, --: in STD_LOGIC := '0';
                reset => sys_rst, --: in STD_LOGIC := '0';        
                write_enable --: in STD_LOGIC := '0';
                read_data_enable --: in STD_LOGIC := '0';
                data_addr --: in STD_LOGIC_VECTOR (15 downto 0) := X"0000";
                data_in --: in STD_LOGIC_VECTOR (15 downto 0):= X"0000"; -- All write data
                data_out --: out STD_LOGIC_VECTOR (15 downto 0):= X"0000";
                -- Instruction memory - read only
                inst_addr --: in STD_LOGIC_VECTOR (15 downto 0):= X"0000";
                inst_out => instruction_f, 
                -- Memory Mapped ports
                in_port --: in STD_LOGIC_VECTOR (15 downto 0):= X"0000";
                out_port --: out STD_LOGIC_VECTOR (15 downto 0) := X"0000"            
            );         
                   
        pc: entity work.program_counter
            port map (
                rst => sys_rst,
                clk => sys_clk,
                --read signals
                rd_instruction => pc_in_f, --: out std_logic_vector(15 downto 0);
                --write signals
                wr_instruction => pc_out_f, --: in std_logic_vector(15 downto 0); 
                wr_enable => '1' -- TODO: connect for hazard control          
        );
        adder_pc: entity work.adder
            port map (
                A => pc_out_f,
                B => step_size_c,
                C => pc_next_f
            );
            
        fetch: entity.work.fetch_register
            port map ( 
                rst => sys_rst,
                clk => sys_clk,
                --read signals               
                rd_instruction => instruction_d, --: out std_logic_vector(15 downto 0);
                rd_pc => pc_next_d,
                --write signals
                wr_instruction => instruction_f, --: in std_logic_vector(15 downto 0);
                wr_pc => pc_next_f,  
                wr_enable => '1' -- TODO: connect for hazard control            
            );
                   
        decoder: entity work.decoder
            port map (
                instr => instruction_d,   -- Input instruction
                opcode       --: out std_logic_vector(6 downto 0);  -- Opcode
                ra           --: out std_logic_vector(2 downto 0);  -- Register A
                rb           --: out std_logic_vector(2 downto 0);  -- Register B
                rc           --: out std_logic_vector(2 downto 0);  -- Register C
                shift        --: out std_logic_vector(3 downto 0);  -- Shift amount
            
                disp_s       --: out std_logic_vector(5 downto 0);  -- Displacement (short)
                disp_l       --: out std_logic_vector(8 downto 0);  -- Displacement (long)
            
                m_1          --: out std_logic;                     -- Mode bit
                in_port_ctl  --: out std_logic;                     -- Control line for IN inst. mux
                out_port_ctl --: out std_logic;                     -- Control line for OUT inst. mux
                imm          --: out std_logic_vector(7 downto 0);  -- Immediate value
            
                r_dest       --: out std_logic_vector(2 downto 0);  -- Destination register
                r_src        --: out std_logic_vector(2 downto 0)   -- Source register    
        );
    

end data_path_arch ;