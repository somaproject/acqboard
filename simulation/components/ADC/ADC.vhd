library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.ALL;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity ADC is
    Generic (filename : string := "adcin.dat" ); 
    Port ( RESET : in std_logic;
           SCLK : in std_logic := '0';
           CONVST : in std_logic;
           CS : in std_logic;
           SDOUT : out std_logic;
		 CHA_VALUE: in integer;
		 CHB_VALUE: in integer;
		 CHA_OUT : out integer := 32768;
		 CHB_OUT : out integer := 32768; 
		 FILEMODE: in std_logic; 
		 BUSY: out std_logic; 
		 INPUTDONE: out std_logic);
end ADC;

architecture Behavioral of ADC is
-- a behavioral simulation of the AD7655, reads in input values from
-- filename, or from cha/chb values, depending on filemode. 
-- the filename has two columns of unsigned ints < 2^16-1
-- RESET is necessary for setup; INPUTDONE goes high when the end of
-- the input file is reached. 
-- 

  constant sclk_to_sdout : time := 10 ns;
  constant convst_delay : time := 1.75 ns;
  
  signal channelA_bits, channelB_bits : std_logic_vector(15 downto 0); 
  signal bitpos : integer := 0;  
  signal outputbits : std_logic_vector(31 downto 0)
  		:= (others => '0');
  signal filedone : std_logic := '0'; 
begin
   -- reset closes the file, opens the file, etc. 
   outputbits <= channelA_bits & channelB_bits;
	INPUTDONE <= filedone; 
   process(CONVST, SCLK, RESET, FILEMODE, CHA_VALUE, CHB_VALUE) is
	  	file inputfile : text; 
	  	variable L: line;

    	variable channelA, channelB: integer; 
   begin 
  		if falling_edge(RESET) then
		     SDOUT <= '0';	
			  filedone <= '0';
			  if filemode = '1' then
			     file_open(inputfile, filename, read_mode); 
			  end if; 
			  bitpos <= 31;
			  channelA_bits <= (others => '0');
			  channelB_bits <= (others => '0');  
			 CHA_OUT <= 32768;
			 CHB_OUT <=  32768; 
		elsif rising_edge(RESET) then
			file_close(inputfile); 
				  
		elsif CONVST'EVENT and CONVST = '0' then
		     SDOUT <= '0';
			BUSY <= '1' after 10 ns, '0' after 1.75 us; 
			if filemode = '1' then 
				if not endfile(inputfile) then
				   bitpos <= 31; 
				   readline(inputfile, L);
				   read(L, channelA);
				   read(L, channelB);

				   -- now we have two integers; we need to turn them into std_logic
				   channelA_bits <= conv_std_logic_vector(channelA, 16);
				   channelB_bits <= conv_std_logic_vector(channelB, 16);
					CHA_OUT <= channelA;
					CHB_OUT <= channelB; 

				else
				   filedone <= '1';
				   bitpos <= 31; 
				   channelA := 32768; 
				   channelB := 32768; 

				   -- now we have two integers; we need to turn them into std_logic
				   channelA_bits <= conv_std_logic_vector(channelA, 16);
				   channelB_bits <= conv_std_logic_vector(channelB, 16);
					CHA_OUT <= channelA;
					CHB_OUT <= channelB; 

				end if; 
			else
			  	 bitpos <= 31; 
			   channelA_bits <= conv_std_logic_vector(CHA_VALUE, 16);
			   channelB_bits <= conv_std_logic_vector(CHB_VALUE, 16);
		   end if; 				   	   	

		else
	      if rising_edge(SCLK) then

			if CS = '0' then 
				SDOUT <= outputbits(bitpos) after 30 ns;
				bitpos <= bitpos -1;
			end if;  

		 end if; 
	    end if; 
   end process; 


end Behavioral;
