
-- VHDL Test Bench Created from source file input.vhd -- 17:44:46 01/26/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all; 
use  ieee.numeric_std.all; 
use std.TextIO.ALL; 

ENTITY rawtest IS
END rawtest;

ARCHITECTURE behavior OF rawtest IS 

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

	
	component clocks is
	    Port ( CLKIN : in std_logic;
	           CLK : out std_logic;
	           CLK8 : out std_logic;
			 RESET : in std_logic;  
	           INSAMPLE : out std_logic;
	           OUTSAMPLE : out std_logic;
	           OUTBYTE : out std_logic := '0';
	           SPICLK : out std_logic);
	end component;

	

	component raw is
	    Port ( CLK : in std_logic;
	           DIN : in std_logic_vector(15 downto 0);
	           CIN : in std_logic_vector(3 downto 0);
	           WEIN : in std_logic;
	           CHAN : in std_logic_vector(3 downto 0);
	           Y : out std_logic_vector(15 downto 0);
			 YEN : out std_logic); 

	end component;
	component FiberTX is
	    Port ( CLK : in std_logic;
	           CLK8 : in std_logic;
			 		RESET : in std_logic; 
	           OUTSAMPLE : in std_logic;
	           FIBEROUT : out std_logic;
	           CMDDONE : in std_logic;
			 	Y : in std_logic_vector(15 downto 0);
			 	YEN : std_logic; 
	           CMDSTS : in std_logic_vector(3 downto 0);
	           CMDID : in std_logic_vector(3 downto 0);
			 CMDSUCCESS : in std_logic; 
			 OUTBYTE : in std_logic; 
	           CHKSUM : in std_logic_vector(7 downto 0));
	end component;

	component ADC is
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
	end component;

	component deserialize is
	    generic ( filename : string := "deserialize.output.dat"); 
	    Port ( CLK8 : in std_logic;
	           FIBEROUT : in std_logic;
				  newframe : out std_logic; 
				  kchar : out std_logic_vector(7 downto 0);
				  cmdst : out std_logic_vector(7 downto 0);
				  data : out std_logic_vector(159 downto 0);
				  cmdid : out std_logic_vector(7 downto 0) 
				  );
	end component;

	signal newframe : std_logic := '0';
	signal kcharout: std_logic_vector(7 downto 0)
		:= (others => '0');
     signal cmdstsout, cmdidout : std_logic_vector(7 downto 0)
		:= (others => '0');  
	signal data : std_logic_vector(159 downto 0) 
		:= (others => '0'); 

	SIGNAL CLK :  std_logic := '0';
	signal clkin : std_logic := '0';
	SIGNAL INSAMPLE :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL CONVST :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL SCLK :  std_logic;
	SIGNAL SDIN :  std_logic_vector(4 downto 0)  := (others => '0');
	SIGNAL DOUT :  std_logic_vector(15 downto 0);
	SIGNAL COUT :  std_logic_vector(3 downto 0);
	SIGNAL WEOUT :  std_logic;
	SIGNAL OSC :  std_logic_vector(3 downto 0);
	SIGNAL OSRST :  std_logic;
	SIGNAL OSEN :  std_logic;
	SIGNAL OSWE :  std_logic;
	SIGNAL OSD :  std_logic_vector(15 downto 0);


	signal y : std_logic_vector(15 downto 0);
	signal yen : std_logic; 
	signal outsample, outbyte, clk8 : std_logic := '0';
	signal cha_value, chb_value : integer := 0; 
	signal spiclk : std_logic := '0';
   signal fiberout : std_logic := '0'; 
	signal intout : integer := 0;  


	type intlist is array(0 to 99) of integer; 
	signal samplelist : intlist;
	signal adcdone : std_logic := '0';  

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


	clock: clocks port map (
		CLKIN => clkin,
		CLK => clk,
		CLK8 => clk8,
		RESET => RESET, 
		INSAMPLE => INSAMPLE, 
		OUTSAMPLE => OUTSAMPLE,
		OUTBYTE => OUTBYTE, 
		SPICLK => spiclk); 

	rawio : raw port map (
		CLK => clk, 
		DIN => DOUT, 
		CIN => COUT, 
		WEIN => WEOUT, 
		CHAN => "0000",
		Y=> y, 
		YEN => yen); 

	fiber_uut: FiberTX port map ( 
		CLK => clk,
		CLK8 => clk8, 
		RESET => reset,
		OUTSAMPLE => outsample,
		FIBEROUT => fiberout,
		CMDDONE => '0',
		Y => y, 
		YEN => yen, 
		CMDSTS => X"0",
		CMDID => X"0",
		CMDSUCCESS => '0',
		OUTBYTE => outbyte, 
		CHKSUM => X"00"); 

 	adc0: ADC generic map (
		filename => "adc.0.dat")
		port map (
		RESET => RESET, 
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(0),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => cha_value,
		CHB_OUT => chb_value,
		FILEMODE => '1',
		BUSY => open,
		INPUTDONE => adcdone); 

	deser: deserialize port map
		(CLK8 => clk8,
		FIBEROUT => FIBEROUT,
		newframe => newframe,
		kchar => kcharout, 
		cmdst => cmdstsout,
		cmdid => cmdidout,
		data => data);
		 
	clkin <= not clkin after 16.625 ns;
	RESET <= '0' after 100 ns; 


	getsamples : process  is
		-- responsible for extracting samples
		-- from 8b/10b deserializer data word
	begin
		wait until falling_edge(NEWFRAME);
		while(RESET = '0') loop
			wait until falling_edge(NEWFRAME);
			for i in 0 to 7 loop
				intout <= to_integer(SIGNED(data(i*16+15 downto i*16))); 
				wait until CLK8 = '1'; 
			end loop;
		end loop; 
	end process getsamples; 	
	
	checksamples: process(intout, cha_value) is
		variable inpos, outpos : integer := 0;
		variable starting : integer := 1;
		variable tmp : integer := 0; 
		 
	begin
		-- we're using intlist as a circular buffer
		if cha_value'EVENT then 
			samplelist(inpos) <= cha_value; 
			inpos := (inpos + 1) mod 100; 
		end if; 	

		if intout'EVENT then
			if intout = -32768 and starting = 1 then
				-- this is just to pass over start-up
				-- artifacts			
			else
				starting := 0; 

				tmp := samplelist(outpos); 
				tmp := tmp - 32768; 
				if tmp < -32768 then
					tmp := -32768;
				end if; 

				assert tmp = intout 
					report "error reading value"
					severity error;
				outpos := (outpos + 1) mod 100; 
	
			end if; 
		end if; 
	
	end process checksamples;  


	ending: process(adcdone) is
	begin
		if rising_edge(adcdone) then
			assert false
			report "End of simulation"
			severity failure; 

		end if; 
	end process ending; 
END;
