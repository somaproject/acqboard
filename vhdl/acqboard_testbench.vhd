
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 
-- acqboard_testbench.vhd -- This is the main testbench for the acquisition
-- board, designed to test command processing, DSP, and the like
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
		fiberout : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clkin :  std_logic;
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
	SIGNAL fiberin :  std_logic;
	SIGNAL fiberout :  std_logic;
	SIGNAL reset :  std_logic;

BEGIN

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
		fiberin => fiberin,
		fiberout => fiberout,
		reset => reset
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
