library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library xpm;
use xpm.vcomponents.all;

entity ram is
    port(
        clk : in std_logic;
        -- Port A - read/write
        rsta : in std_logic;  
        ena : in std_logic; -- enable r and w    
        wea : in std_logic_vector(0 downto 0); -- enable write port a     
        addra : in std_logic_vector(8 downto 0);
        dina : in std_logic_vector(15 downto 0);         
        douta : out std_logic_vector(15 downto 0);    
        -- Port B - read only               
        rstb : in std_logic;                   
        enb : in std_logic;                                  
        addrb : in std_logic_vector(8 downto 0);                   
        doutb : out std_logic_vector(15 downto 0)                 
    );
end ram;

architecture ram_arch of ram is
    begin
        -- xpm_memory_dpdistram: Dual Port Distributed RAM
        -- Xilinx Parameterized Macro, Version 2017.4
        xpm_memory_dpdistram_inst : xpm_memory_dpdistram
          generic map (        
            -- Common module generics
            MEMORY_SIZE             => 8192,           --positive integer
            CLOCKING_MODE           => "common_clock", --string; "common_clock", "independent_clock" 
            MEMORY_INIT_FILE        => "none",         --string; "none" or "<filename>.mem" 
            MEMORY_INIT_PARAM       => "",             --string;
            USE_MEM_INIT            => 1,              --integer; 0,1
            MESSAGE_CONTROL         => 0,              --integer; 0,1
            USE_EMBEDDED_CONSTRAINT => 0,              --integer: 0,1
            MEMORY_OPTIMIZATION     => "true",          --string; "true", "false" 
        
            -- Port A module generics
            WRITE_DATA_WIDTH_A      => 16,             --positive integer
            READ_DATA_WIDTH_A       => 16,             --positive integer
            BYTE_WRITE_WIDTH_A      => 16,             --integer; 8, 9, or WRITE_DATA_WIDTH_A value
            ADDR_WIDTH_A            => 9,              --positive integer
            READ_RESET_VALUE_A      => "0",            --string
            READ_LATENCY_A          =>  1,              --non-negative integer
        
            -- Port B module generics
            READ_DATA_WIDTH_B       => 16,             --positive integer
            ADDR_WIDTH_B            => 9,              --positive integer
            READ_RESET_VALUE_B      => "0",            --string
            READ_LATENCY_B          => 1              --non-negative integer
          )
          port map (        
            -- Port A module ports
            clka                    => clk,
            rsta                    => rsta,
            ena                     => ena,
            regcea                  => '1',   --do not change
            wea                     => wea,
            addra                   => addra,
            dina                    => dina,
            douta                   => douta,        
            -- Port B module ports
            clkb                    => '1', -- unused for common clock mode
            rstb                    => rstb,
            enb                     => enb,
            regceb                  => '1',   --do not change
            addrb                   => addrb,
            doutb                   => doutb
          );        
        -- End of xpm_memory_dpdistram_inst instance declaration
end ram_arch;
				
				