
-- VHDL Test Bench Created from source file test_adc.vhd -- 13:45:06 07/05/2003
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

	COMPONENT test_adc
	PORT(
		reset : IN std_logic;
		sclk : IN std_logic;
		convst : IN std_logic;
		cs : IN std_logic;          
		sdout : OUT std_logic;
		busy : OUT std_logic;
		inputdone : OUT std_logic
		);
	END COMPONENT;

	SIGNAL reset :  std_logic := '1';
	SIGNAL sclk :  std_logic := '0';
	SIGNAL convst :  std_logic := '1' ;
	SIGNAL cs :  std_logic := '1';
	SIGNAL sdout :  std_logic;
	SIGNAL busy :  std_logic;
	SIGNAL inputdone :  std_logic;

BEGIN

	uut: test_adc PORT MAP(
		reset => reset,
		sclk => sclk,
		convst => convst,
		cs => cs,
		sdout => sdout,
		busy => busy,
		inputdone => inputdone
	);

   reset <= '0' after 40 ns; 




-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
	convst <= '0' after 100 ns, '1' after 110 ns; 
	wait; 


   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
