
-- VHDL Test Bench Created from source file aes3.vhd -- 08:43:48 02/08/2005
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

ENTITY aes3test IS
END aes3test;

ARCHITECTURE behavior OF aes3test IS 

	component AES3 is
	    Port ( CLKIN : in std_logic;
	           SDIN : in std_logic_vector(4 downto 0);		 
	           CONVST : out std_logic;
	           ADCCS : out std_logic;
	           SCLK : out std_logic;
	           FIBEROUT : out std_logic;
			 CLKENOUT : out std_logic;
			 BITENOUT : out std_logic; 
			 SAMPLEOUT : out std_logic;
			 BITOUT : out std_logic;
			 CLKOUT : out std_logic);
	end component;


	component AES3reader is
	    Port ( CLK : in std_logic;
	           CLKEN : in std_logic;
	           DIN : in std_logic; 
			 AOUT : out integer;
			 BOUT : out integer );
	end component;

	SIGNAL CLKIN :  std_logic := '0';
	SIGNAL CLK : std_logic := '0'; 
	SIGNAL SDIN :  std_logic_vector(4 downto 0) := (others => '0');
	SIGNAL CONVST :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL SCLK :  std_logic;
	SIGNAL FIBEROUT :  std_logic;
	SIGNAL CLKENOUT, BITENOUT, SAMPLEOUT : std_logic := '0'; 

	signal aout, bout : integer := 0; 

BEGIN

	uut: aes3 PORT MAP(
		CLKIN => CLKIN,
		SDIN => SDIN,
		CONVST => CONVST,
		ADCCS => ADCCS,
		SCLK => SCLK,
		FIBEROUT => FIBEROUT,
		CLKENOUT => CLKENOUT,
		BITENOUT => BITENOUT,
		SAMPLEOUT => SAMPLEOUT,
		CLKOUT => clk
	);

	aes3reading : AES3reader port map (	
		CLK => CLK,
		CLKEN => CLKENOUT,
		DIN => FIBEROUT,
		AOUT => aout,
		BOUT => bout); 

	clkin <= not clkin after 15.625 ns;

END;
