
-- VHDL Test Bench Created from source file simple.vhd -- 18:03:43 12/08/2004
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

ENTITY simpletest IS
END simpletest;

ARCHITECTURE behavior OF simpletest IS 

	COMPONENT simple
	PORT(
		CLKIN : IN std_logic;
		SDIN : IN std_logic;          
		SCLK : OUT std_logic;
		ADCCS : OUT std_logic;
		CONVST : OUT std_logic;
		FIBEROUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLKIN :  std_logic := '0';
	SIGNAL SDIN :  std_logic;
	SIGNAL SCLK :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL CONVST :  std_logic;
	SIGNAL FIBEROUT :  std_logic;

	signal reset : std_logic := '1';

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
BEGIN

	uut: simple PORT MAP(
		CLKIN => CLKIN,
		SDIN => SDIN,
		SCLK => SCLK,
		ADCCS => ADCCS,
		CONVST => CONVST,
		FIBEROUT => FIBEROUT
	);

	adc_uut: ADC generic map (
		filename => "adcin.dat")
		port map (
		RESET => reset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN,
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => open,
		CHB_OUT => open,
		FILEMODE => '1',
		BUSY => open,
		INPUTDONE => open); 


	CLKIN <= not CLKIN after 15.625 ns; 
	RESET <= '0' after 20 ns; 


END;
