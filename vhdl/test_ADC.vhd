library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.ALL;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_ADC is
    Generic (filename : string := "adcin.dat" ); 
    Port ( RESET : in std_logic;
           SCLK : in std_logic := '0';
           CONVST : in std_logic;
           CS : in std_logic;
           SDOUT : out std_logic;
		 BUSY: out std_logic; 
		 INPUTDONE: out std_logic);
end test_ADC;

architecture Behavioral of test_ADC is
-- a behavioral simulation of the AD7655, reads in input values from
-- filename, which has two columns of unsigned ints < 2^16-1
-- RESET is necessary for setup; INPUTDONE goes high when the end of
-- the input file is reached. 
-- 

  constant sclk_to_sdout : time := 10 ns;
  constant convst_delay : time := 1.75 ns;
  
  signal channelA_bits, channelB_bits : std_logic_vector(15 downto 0); 
  signal bitpos : integer := 0;  
  signal outputbits : std_logic_vector(31 downto 0);

begin
   -- reset closes the file, opens the file, etc. 
   outputbits <= channelA_bits & channelB_bits;
   process(CONVST, SCLK, RESET) is
  	file inputfile : text open read_mode is filename; 
  	variable L: line;

    	variable channelA, channelB: integer; 
   begin 
  		if falling_edge(RESET) then
		     SDOUT <= '0';	
		elsif CONVST'EVENT and CONVST = '0' then
		     SDOUT <= '0';
			BUSY <= '1' after 10 ns, '0' after 1.75 us; 
			if not endfile(inputfile) then
			   bitpos <= 31; 
			   readline(inputfile, L);
			   read(L, channelA);
			   read(L, channelB);

			   -- now we have two integers; we need to turn them into std_logic
			   channelA_bits <= conv_std_logic_vector(channelA, 16);
			   channelB_bits <= conv_std_logic_vector(channelB, 16);
		   

			else
			   INPUTDONE <= '1';
			end if; 
		else
	      if rising_edge(SCLK) then
			if CS = '0' then 
				SDOUT <= outputbits(bitpos) after 25 ns;
				bitpos <= bitpos -1;
			end if;  

		 end if; 
	    end if; 
   end process; 


end Behavioral;
