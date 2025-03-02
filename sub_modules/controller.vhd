-- controller
library ieee ;
use ieee.std_logic_1164.all ;
use work.cpu_types.all;

entity controller is
    port (
    -- inputs    
    clk : in STD_LOGIC;
    reset_ex: in STD_LOGIC;
    reset_ld: in STD_LOGIC;
    inst_in : IN std_logic_vector (15 downto 0);
    -- outputs
    reg_dst : OUT STD_LOGIC;
    branch : OUT STD_LOGIC;
    RAM_mem_rd : OUT STD_LOGIC;
    RAM_mem_to_reg : OUT STD_LOGIC;
    ROM_mem_rd : OUT STD_LOGIC;
    ROM_mem_to_reg : OUT STD_LOGIC;
    alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    RAM_mem_wr : OUT STD_LOGIC;
    ROM_mem_wr : OUT STD_LOGIC;
    alu_src : OUT STD_LOGIC;
    reg_wr : OUT STD_LOGIC
    );
    end controller ;

architecture rtl of controller is    
    signal state, nextstate: statetype;

begin
    -- state register
    process (clk, reset_ex, reset_ld) begin
        -- Reset load means ROM mode
        -- Reset Execute means RAM mode
        if reset_ld | reset_ex = '1' then state <= RESET;    
        elsif clk'event and clk = '1' then    
            state <= nextstate;    
        end if;    
    end process;

     -- controller outputs
     case(state)
        RESET:
        begin
            if
            reg_dst => '0';
            branch => '0';
            RAM_mem_rd => '0';
            RAM_mem_to_reg => '0';
            ROM_mem_rd => '0';
            ROM_mem_to_reg => '0';
            alu_op => "000";
            RAM_mem_wr => '0';
            ROM_mem_wr => '0';
            alu_src => '0';
            reg_wr=> '0';
            nextstate = DECODE;
        end


end rtl ;