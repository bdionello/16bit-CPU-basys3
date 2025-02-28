-- controller
library ieee ;
use ieee.std_logic_1164.all ;
use work.cpu_types.all;

entity controller is
    port (clk, reset: in STD_LOGIC;
    y: out STD_LOGIC);
end controller ;

architecture rtl of controller is    
    signal state, nextstate: statetype;

begin
    -- select next state
    nextstate <= 
    S1 when state = S0 else
    S2 when state = S1 else
    S0;

    -- state register
    process (clk, reset) begin
        if reset = '1' then state <= S0;    
        elsif clk'event and clk = '1' then    
            state <= nextstate;    
        end if;    
    end process;

     -- controller outputs
     y <= '1 when state = S0 else '0'';
end rtl ;