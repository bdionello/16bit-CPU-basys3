library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library xpm;
use xpm.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all
entity rom is
    port(
        clk  : in std_logic;
        rst  : in std_logic;
        en   : in std_logic;
        addr : in std_logic_vector(8 downto 0);
        dout : out std_logic_vector(15 downto 0)       
    );
end rom;
architecture rom_arch of rom is
    begin
    
        -- xpm_memory_sprom: Single Port ROM
        -- Xilinx Parameterized Macro, version 2018.3
        xpm_memory_sprom_inst : xpm_memory_sprom
        generic map (    
            -- Common module generics
            MEMORY_SIZE             => 8192,            --positive integer
            MEMORY_PRIMITIVE        => "auto",          --string; "auto", "distributed", or "block";
            MEMORY_INIT_FILE        => "testB2.mem",    --string; "none" or "<filename>.mem" 
            MEMORY_INIT_PARAM       => "",              --string;
            USE_MEM_INIT            => 1,               --integer; 0,1
            WAKEUP_TIME             => "disable_sleep", --string; "disable_sleep" or "use_sleep_pin" 
            MESSAGE_CONTROL         => 0,               --integer; 0,1
            ECC_MODE                => "no_ecc",        --string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode" 
            AUTO_SLEEP_TIME         => 0,               --Do not Change
            MEMORY_OPTIMIZATION     => "true",          --string; "true", "false" 
            
            -- Port A module generics
            READ_DATA_WIDTH_A       => 16,              --positive integer
            ADDR_WIDTH_A            => 9,               --positive integer
            READ_RESET_VALUE_A      => "0",             --string
            READ_LATENCY_A          => 0                --non-negative integer
        )
        port map (    
            -- Common module ports
            sleep => '0',    
            -- Port A module ports
            clka => clk,
            rsta=> rst,
            ena => en,
            regcea => '1',
            addra => addr,
            injectsbiterra => '0',   --do not change
            injectdbiterra => '0',   --do not change
            douta => dout,
            sbiterra  => open,  --do not change
            dbiterra => open   --do not change
        );    
        -- End of xpm_memory_sprom_inst instance declaration
end rom_arch;
