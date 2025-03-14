library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity displacement_TB is
--  Port ( );
end displacement_TB;

architecture Behavioral of displacement_TB is
    -- Test Bench config
    constant memory_size : integer := 1024;
    constant clk_hz : integer := 100e6;
    constant clk_period : time := 1 sec / clk_hz; -- 1/T = 100MHz
    signal clk : std_logic := '0';
     
    signal op_code_i : std_logic_vector(6 downto 0) := (others => '0');
    signal disp_l_i : std_logic_vector(8 downto 0) := (others => '0');
    signal disp_s_i : std_logic_vector(5 downto 0) := (others => '0');
    signal exteded_disp_i : word_t := (others => '0');
    
begin
    dut0: entity work.sign_extend
        port map(
               op_code         =>  op_code_i,  -- Opcode from Decode Stage
               disp_l          =>  disp_l_i,  -- Long displacement (for BRR)
               disp_s          =>  disp_s_i,  -- Short displacement (for BR)
               extended_disp   =>  exteded_disp_i  -- Short displacement (for BR)
        );
        
     CLK_PROC : process
        begin
            wait for clk_period / 2;
            if clk = '1' then
                clk <= '0';
            else
                clk <= '1';
            end if;
        end process;
    
    test_proc: process
    begin
        disp_s_i <= (others => '0'); -- not used for BRR tests
        -- Test BRR
        op_code_i <= BRR;     
        disp_l_i <= "111111111";
        wait until falling_edge(clk);
        disp_l_i <= "011111111";
        wait until falling_edge(clk);
        
        -- Test BRR_N
        op_code_i <= BRR_N;     
        disp_l_i <= "111111111";
        wait until falling_edge(clk);
        disp_l_i <= "011111111";
        wait until falling_edge(clk);
        
        -- Test BRR_Z
        op_code_i <= BRR_Z;     
        disp_l_i <= "111111111";
        wait until falling_edge(clk);
        disp_l_i <= "011111111";
        wait until falling_edge(clk);
        
        disp_l_i <= (others => '0'); -- not used for BR tests
        -- Test BR
        op_code_i <= BR;     
        disp_s_i <= "111111"; 
        wait until falling_edge(clk);
        disp_s_i <= "011111";
        wait until falling_edge(clk);
        
        -- Test BR_N
        op_code_i <= BR_N;     
        disp_s_i <= "111111"; 
        wait until falling_edge(clk);
        disp_s_i <= "011111";
        wait until falling_edge(clk);
        
        -- Test BR_Z
        op_code_i <= BR_Z;     
        disp_s_i <= "111111"; 
        wait until falling_edge(clk);
        disp_s_i <= "011111";
        wait until falling_edge(clk);
        
        -- Test BR_SUB
        op_code_i <= BR_SUB;     
        disp_s_i <= "111111"; 
        wait until falling_edge(clk);
        disp_s_i <= "011111";
        wait until falling_edge(clk);
         
        assert false report "Test: End - Force stop" severity failure;                             
    end process;
end Behavioral;
