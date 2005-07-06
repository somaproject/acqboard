
-- VHDL Test Bench Created from source file acqboard.vhd -- 14:10:35 07/28/2003
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

ENTITY acqboard_testbench IS
END acqboard_testbench;

ARCHITECTURE behavior OF acqboard_testbench IS 
-- acqboard_testbench.vhd -- This is the main testbench for the acquisition
-- board, designed to test command processing, DSP, and the like.
-- 
-- 

	COMPONENT acqboard
	PORT(
		clkin : IN std_logic;
		adcin : IN std_logic_vector(4 downto 0);
		eso : IN std_logic;
		fiberin : IN std_logic;
		reset : IN std_logic;          
		adcclk : OUT std_logic;
		adccs : OUT std_logic;
		adcconvst : OUT std_logic;
		pgarck : OUT std_logic;
		pgasrck : OUT std_logic;
		pgasera : OUT std_logic;
		esi : OUT std_logic;
		esck : OUT std_logic;
		ecs : OUT std_logic;
		EEPROMLEN : in std_logic; 
		fiberout : OUT std_logic;
		clk8_out : out std_logic
		);
	END COMPONENT;

	SIGNAL clkin :  std_logic := '0';
	SIGNAL adcin :  std_logic_vector(4 downto 0);
	SIGNAL adcclk :  std_logic;
	SIGNAL adccs :  std_logic;
	SIGNAL adcconvst :  std_logic;
	SIGNAL pgarck :  std_logic;
	SIGNAL pgasrck :  std_logic;
	SIGNAL pgasera :  std_logic;
	SIGNAL esi :  std_logic;
	SIGNAL esck :  std_logic;
	SIGNAL ecs :  std_logic;
	SIGNAL eso :  std_logic;
	SIGNAL eepromlen : std_logic := '0'; -- EEPROM load enable
	SIGNAL fiberin :  std_logic;
	SIGNAL fiberout :  std_logic;
	SIGNAL reset :  std_logic := '1';
	signal adcbusy, adcdone : std_logic := '0'; 
	signal clk8 : std_logic; 

	signal sendCMD_cmdid, sendCMD_cmd : 
		std_logic_vector(3 downto 0) := (others => '0');
     signal sendCMD_data0, sendCMD_data1, sendCMD_data2, sendCMD_data3,
		  sendCMD_chksum : std_logic_vector(7 downto 0) := (others => '0');
	signal sendCMD_send, sendCMD_pending : std_logic := '0';


	signal save : std_logic := '0';


	-- test components
	component test_ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic := '0';
	           CONVST : in std_logic;
	           CS : in std_logic;
	           SDOUT : out std_logic;
			 CHA_VALUE: in integer;
			 CHB_VALUE: in integer;
			 FILEMODE: in std_logic; 
			 BUSY: out std_logic; 
			 INPUTDONE: out std_logic);
	end component;


	component test_SendCMD is
	    Port ( CMDID : in std_logic_vector(3 downto 0);
	           CMD : in std_logic_vector(3 downto 0);
	           DATA0 : in std_logic_vector(7 downto 0);
	           DATA1 : in std_logic_vector(7 downto 0);
	           DATA2 : in std_logic_vector(7 downto 0);
	           DATA3 : in std_logic_vector(7 downto 0);
	           CHKSUM : in std_logic_vector(7 downto 0);
			 SENDCMD : in std_logic;
			 CMDPENDING : out std_logic;
			 DOUT : out std_logic 
			 );
	end component;
	 
	component test_deserialize is
	    generic ( filename : string := "deserialize.output.dat"); 
	    Port ( CLK8 : in std_logic;
	           FIBEROUT : in std_logic);
	end component;

	component test_EEPROM is
	    Generic (  FILEIN : string := "eeprom_in.dat"; 
	    			FILEOUT : string := "eeprom_out.dat"); 
	    Port ( CLK : in std_logic;
	           CS : in std_logic;
	           SCK : in std_logic;
			 SI : in std_logic;
			 SO : out std_logic; 
			 RESET : in std_logic;
			 SAVE : in std_logic);
	end component;

BEGIN


	ADC0: test_ADC generic map (
			filename => "testvectors/acqboard.test_ADCs.random.0.dat")
			port map (
			RESET => reset,
			SCLK => adcclk,
			CONVST => adcconvst,
			CS => adccs,
			SDOUT => adcin(0),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			FILEMODE => '1',
			BUSY => adcbusy,
			INPUTDONE => adcdone);

	ADC1: test_ADC generic map (
			filename => "testvectors/acqboard.test_ADCs.random.1.dat")
			port map (
			RESET => reset,
			SCLK => adcclk,
			CONVST => adcconvst,
			CS => adccs,
			SDOUT => adcin(1),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			FILEMODE => '1',
			BUSY => adcbusy,
			INPUTDONE => adcdone);

	ADC2: test_ADC generic map (
			filename => "testvectors/acqboard.test_ADCs.random.2.dat")
			port map (
			RESET => reset,
			SCLK => adcclk,
			CONVST => adcconvst,
			CS => adccs,
			SDOUT => adcin(2),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			FILEMODE => '1',
			BUSY => adcbusy,
			INPUTDONE => adcdone);

	ADC3: test_ADC generic map (
			filename => "testvectors/acqboard.test_ADCs.random.3.dat")
			port map (
			RESET => reset,
			SCLK => adcclk,
			CONVST => adcconvst,
			CS => adccs,
			SDOUT => adcin(3),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			FILEMODE => '1',
			BUSY => adcbusy,
			INPUTDONE => adcdone);

	ADC4: test_ADC generic map (
			filename => "testvectors/acqboard.test_ADCs.random.4.dat")
			port map (
			RESET => reset,
			SCLK => adcclk,
			CONVST => adcconvst,
			CS => adccs,
			SDOUT => adcin(4),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			FILEMODE => '1',
			BUSY => adcbusy,
			INPUTDONE => adcdone);


	commands : test_sendCMD port map (
			CMDID => sendCMD_cmdid,
			CMD => sendCMD_cmd,
			DATA0 => sendCMD_data0,
			DATA1 => sendCMD_data1,
			DATA2 => sendCMD_data2,
			DATA3 => sendCMD_data3,
			CHKSUM => sendCMD_chksum,
			SENDCMD => sendCMD_send,
			CMDPENDING => sendCMD_pending,
			DOUT => fiberin);

    deserializer: test_deserialize 
    			generic map (
				filename => "testvectors/acqboard.output.random.dat")
			port map (
				clk8 => clk8,
				fiberout => fiberout); 

	eeprom_stuff:  test_EEPROM 
	    Generic map(FILEIN => "testvectors/acqboard.eeprom.in.dat",
	    			 FILEOUT => "testvectors/acqboard.eeprom.out.dat")
	    Port map (
	           CLK => '0',
	           CS => ecs,
	           SCK => esck,
			 SI => esi, 
			 SO => eso, 
			 RESET => reset, 
			 SAVE => save);

 
	uut: acqboard PORT MAP(
		clkin => clkin,
		adcin => adcin,
		adcclk => adcclk,
		adccs => adccs,
		adcconvst => adcconvst,
		pgarck => pgarck,
		pgasrck => pgasrck,
		pgasera => pgasera,
		esi => esi,
		esck => esck,
		ecs => ecs,
		eso => eso,
		eepromlen => eepromlen,
		fiberin => fiberin,
		fiberout => fiberout,
		reset => reset,
		clk8_out => clk8
	);


    -- first, the input clock;
    clkin <= not clkin after 15.625 ns; -- 32 MHz
    reset <= '0' after 40 ns; 




-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
