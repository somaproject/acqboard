
-- VHDL Test Bench Created from source file input.vhd -- 20:13:17 04/08/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use std.textio.all; 

ENTITY filtertest IS
	generic (simname : string := "basic"); 
END filtertest;
											 
ARCHITECTURE behavior OF filtertest IS 

	COMPONENT input
	PORT(
		CLK : IN std_logic;
		INSAMPLE : IN std_logic;
		RESET : IN std_logic;
		SDIN : IN std_logic_vector(4 downto 0);
		OSC : IN std_logic_vector(3 downto 0);
		OSRST : IN std_logic;
		OSEN : IN std_logic;
		OSWE : IN std_logic;
		OSD : IN std_logic_vector(15 downto 0);          
		CONVST : OUT std_logic;
		ADCCS : OUT std_logic;
		SCLK : OUT std_logic;
		DOUT : OUT std_logic_vector(15 downto 0);
		COUT : OUT std_logic_vector(3 downto 0);
		WEOUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL INSAMPLE :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL CONVST :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL SCLK :  std_logic;
	SIGNAL SDIN :  std_logic_vector(4 downto 0);
	SIGNAL DOUT :  std_logic_vector(15 downto 0);
	SIGNAL COUT :  std_logic_vector(3 downto 0);
	SIGNAL WEOUT :  std_logic;
	SIGNAL OSC :  std_logic_vector(3 downto 0);
	SIGNAL OSRST :  std_logic;
	SIGNAL OSEN :  std_logic;
	SIGNAL OSWE :  std_logic;
	SIGNAL OSD :  std_logic_vector(15 downto 0);

	component samplebuffer is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           DIN : in std_logic_vector(15 downto 0);
	           CHANIN : in std_logic_vector(3 downto 0);
	           WE : in std_logic;
	           AIN : in std_logic_vector(7 downto 0);
	           DOUT : out std_logic_vector(15 downto 0);
	           AOUT : in std_logic_vector(7 downto 0);
				  ALLCHAN : in std_logic;  
				  SAMPOUTEN: in std_logic; 
	           CHANOUT : in std_logic_vector(3 downto 0));
	end component;
	
	signal X, fdin : std_logic_vector(15 downto 0) := (others => '0'); 
	signal H : std_logic_vector(21 downto 0) := (others => '0'); 
	signal XA, HA, XABASE, SAMPLE : std_logic_vector(7 downto 0) := (others => '0'); 
	signal startmac, macdone, fwe : std_logic := '0';
	signal allchan : std_logic := '0'; 
	signal fain : std_logic_vector(8 downto 0) := (others => '0'); 
	signal macchan : std_logic_vector(3 downto 0) := (others => '0'); 
	
	   
	component FilterArray is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           WE : in std_logic;
	           H : out std_logic_vector(21 downto 0);
	           HA : in std_logic_vector(7 downto 0);
	           AIN : in std_logic_vector(8 downto 0);
	           DIN : in std_logic_vector(15 downto 0));
	end component;
   
	component RMACcontrol is
	    Port ( CLK : in std_logic;
	           INSAMPLE : in std_logic;
	           OUTSAMPLE : in std_logic;
			     OUTBYTE : in std_logic; 
	           RESET : in std_logic;
	           STARTMAC : out std_logic;
	           MACDONE : in std_logic;
	           SAMPLE : out std_logic_vector(7 downto 0);
	           SAMPBASE : out std_logic_vector(7 downto 0);
			     SAMPOUTEN: out std_logic; 
	           RMACCHAN : out std_logic_vector(3 downto 0));
	end component;

	component RMAC is
	    Port ( CLK : in std_logic;
	           X : in std_logic_vector(15 downto 0);
	           XA : out std_logic_vector(7 downto 0);
	           H : in std_logic_vector(21 downto 0);
	           HA : out std_logic_vector(7 downto 0);
	           XBASE : in std_logic_vector(7 downto 0);
	           STARTMAC : in std_logic;
			     MACDONE  : out std_logic; 
			     RESET : in std_logic; 
	           Y : out std_logic_vector(15 downto 0));
	end component;

	signal y :  std_logic_vector(15 downto 0) := (others => '0');

	signal  outsample, outbyte : std_logic := '0';

	component ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic := '0';
	           CONVST : in std_logic;
	           CS : in std_logic;
	           SDOUT : out std_logic;
			    CHA_VALUE: in integer;
			    CHB_VALUE: in integer;
			    CHA_OUT : out integer;
			    CHB_OUT : out integer; 
			    FILEMODE: in std_logic; 
			    BUSY: out std_logic; 
			    INPUTDONE: out std_logic);
	end component;

   type adc_intarray is array(0 to 4) of integer; 
	signal cha_out, chb_out: adc_intarray := (others => 0) ;
	signal sampouten : std_logic := '0'; 
	signal adc_reset : std_logic; 

   signal clk_enable : std_logic := '0'; 
	signal syscnt : integer := 0; 

	component FilterLoad is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( CLK : in std_logic;
	           DOUT : out std_logic_vector(15 downto 0);
	           AOUT : out std_logic_vector(8 downto 0);
	           WEOUT : out std_logic;
				  LOAD : in std_logic);
	end component;
	signal loadfilter : std_logic := '0'; 
	signal filedone : std_logic := '0'; 

BEGIN

	uut: input PORT MAP(
		CLK => CLK,
		INSAMPLE => INSAMPLE,
		RESET => RESET,
		CONVST => CONVST,
		ADCCS => ADCCS,
		SCLK => SCLK,
		SDIN => SDIN,
		DOUT => DOUT,
		COUT => COUT,
		WEOUT => WEOUT,
		OSC => OSC,
		OSRST => OSRST,
		OSEN => OSEN,
		OSWE => OSWE,
		OSD => OSD
	);



	adc0 : ADC  generic map (
			filename => simname & ".adcin.0.dat")
			port map (
			RESET => adc_reset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(0),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => cha_out(0),
			CHB_OUT => chb_out(0),
			FILEMODE => '1',
			BUSY => open,
			INPUTDONE => filedone); 
			  
	adc1 : ADC  generic map (
			filename => simname & ".adcin.1.dat")
			port map (
			RESET => adc_reset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(1),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => cha_out(1),
			CHB_OUT => chb_out(1),
			FILEMODE => '1',
			BUSY => open,
			INPUTDONE => open); 

	adc2 : ADC  generic map (
			filename => simname & ".adcin.2.dat")
			port map (
			RESET => adc_reset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(2),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => cha_out(2),
			CHB_OUT => chb_out(2),
			FILEMODE => '1',
			BUSY => open,
			INPUTDONE => open); 

	adc3 : ADC  generic map (
			filename => simname &  ".adcin.3.dat")
			port map (
			RESET => adc_reset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(3),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => cha_out(3),
			CHB_OUT => chb_out(3),
			FILEMODE => '1',
			BUSY => open,
			INPUTDONE => open); 

	adc4 : ADC  generic map (
			filename => simname & ".adcin.4.dat")
			port map (
			RESET => adc_reset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(4),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => cha_out(4),
			CHB_OUT => chb_out(4),
			FILEMODE => '1',
			BUSY => open,
			INPUTDONE => open); 

 	sample_UUT : samplebuffer port map (
			CLK => clk,
			RESET => RESET,
			DIN => dout, 
			CHANIN => cout,
			WE => WEOUT,
			AIN => SAMPLE,
			DOUT => X,
			AOUT => XA,
			ALLCHAN => allchan,
			SAMPOUTEN => SAMPOUTEN,
			CHANOUT => macchan); 



  filter : FilterArray port map (
  			CLK => CLK,
			RESET => RESET,
			WE => fwe, 
			H => H,
			HA => HA,
			AIN => fain,
			DIN => fdin);
	
			
	rmaccont : RMACcontrol port map(
			CLK => clk,
			INSAMPLE => insample,
			OUTSAMPLE => outsample,
			OUTBYTE => outbyte,
			RESET => RESET,
			STARTMAC => startmac,
			MACDONE => macdone,
			SAMPLE => SAMPLE,
			SAMPBASE => XABASE,
			SAMPOUTEN => sampouten,
			RMACCHAN => MACCHAN); 

   rmaccr : RMAC port map (
			CLK => clk,
			X => X, 
			XA => XA,
			H => H,
			HA => HA,
			XBASE => XABASE,
			STARTMAC => startmac,
			MACDONE => macdone,
			RESET => RESET, 
			Y => Y);

	filload: FilterLoad generic map
			(filename => simname & ".filter.dat")
			port map(
			clk => clk,
			DOUT => fdin, 
			AOUT => fain,
			WEOUT => fwe,
			load => loadfilter); 


	clk <= not clk after 7.8125 ns; 


	process(clk, clk_enable) is
		variable clkcnt : integer := 1; 

	begin
		if rising_edge(clk_enable) then
			clkcnt := 1; 
		else
			if rising_edge(clk) then
			   if clk_enable = '1' then 
				    clkcnt := clkcnt + 1;
				end if; 
			end if; 
		end if; 
		if clkcnt mod 2000 = 0 then
	   	outsample <= '1';
		else
			outsample <= '0';
		end if;

		if clkcnt mod 250 = 0 then	
			insample <= '1';
		else
			insample <= '0';
		end if; 

		if clkcnt mod 80 = 0 then
			outbyte <= '1';
		else	
			outbyte <= '0';
		end if; 


	end process; 

	process(clk) is
	begin
		if rising_edge(clk) then
			syscnt <= syscnt + 1; 
		end if;
	end process; 


	process(clk, reset) is
		
		file outputfile : text; 
	  	variable L: line;
	begin
		if falling_edge(reset) then
			file_open(outputfile, simname &  ".output.dat", write_mode);
		end if; 
 		if rising_edge(clk) then
			if outsample = '1' then
				writeline(outputfile, L); 
			end if; 

			if macdone = '1' then
				write(L, to_integer(signed(y)));	 
				write(L, ' ');
			end if; 

		end if; 
	end process; 
	
	tb: process is

	begin
	   
		adc_reset <= '0';  
		loadfilter <= '1';
		wait until rising_edge(clk);
		adc_reset <= '1'; 
		loadfilter <= '0'; 
		wait until syscnt > 1000;
		adc_reset <= '0'; 
		wait until rising_edge(clk); 

		reset <= '0'; 
		clk_enable <= '1'; 
		wait until filedone = '1';
		wait; 



	end process; 

	
END;
