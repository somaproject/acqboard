
-- VHDL Test Bench Created from source file input.vhd -- 13:37:19 07/05/2003
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT input
	PORT(
		clk : IN std_logic;
		insample : IN std_logic;
		reset : IN std_logic;
		sdin : IN std_logic_vector(4 downto 0);
		osc : IN std_logic_vector(3 downto 0);
		osen : IN std_logic;
		oswe : IN std_logic;
		osd : IN std_logic_vector(15 downto 0);          
		convst : OUT std_logic;
		adccs : OUT std_logic;
		sclk : OUT std_logic;
		dout : OUT std_logic_vector(15 downto 0);
		cout : OUT std_logic_vector(3 downto 0);
		weout : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0' ;
	SIGNAL insample :  std_logic;
	SIGNAL reset :  std_logic := '1';
	SIGNAL convst :  std_logic;
	SIGNAL adccs :  std_logic;
	SIGNAL sclk :  std_logic;
	SIGNAL sdin :  std_logic_vector(4 downto 0);
	SIGNAL dout :  std_logic_vector(15 downto 0);
	SIGNAL cout :  std_logic_vector(3 downto 0);
	SIGNAL weout :  std_logic;
	SIGNAL osc :  std_logic_vector(3 downto 0);
	SIGNAL osen :  std_logic;
	SIGNAL oswe :  std_logic;
	SIGNAL osd :  std_logic_vector(15 downto 0);
	SIGNAL busy : std_logic_vector(4 downto 0) := (others => '0');
	SIGNAL inputdone : std_logic_vector(4 downto 0) := (others => '0');


	-- adc input test
	component test_ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic;
	           CONVST : in std_logic;
	           CS : in std_logic;
	           SDOUT : out std_logic;
			 BUSY: out std_logic; 
			 INPUTDONE: out std_logic);
	end component;

BEGIN

	uut: input PORT MAP(
		clk => clk,
		insample => insample,
		reset => reset,
		convst => convst,
		adccs => adccs,
		sclk => sclk,
		sdin => sdin,
		dout => dout,
		cout => cout,
		weout => weout,
		osc => osc,
		osen => osen,
		oswe => oswe,
		osd => osd
	);

	adc_in: test_ADC port map(
		RESET => reset,
		sclk = > sclk,
		CONVST => convst,
		CS => adccs,
		SDOUT => sdin(0),
		BUSY	=> busy(0),
		INPUTDONE => inputdone(0));

    clk <= not clk after 15.625 ns / 2; 
    reset <= '0' after 45 ns; 





		 
-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
