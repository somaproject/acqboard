
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
		inputdone : OUT std_logic;
		 CHA_VALUE: in integer;
		 CHB_VALUE: in integer;
		 FILEMODE: in std_logic 
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
		cha_value => 0,
		chb_value => 0,
		filemode => '1',
		inputdone => inputdone
	);

   reset <= '0' after 40 ns; 




-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
	convst <= '0' after 100 ns, '1' after 110 ns; 
	
	cs <= '0' after 1.9 us; 

	wait for 1.9 us; 

	for i in 0 to 31 loop
		sclk <= '1' after 10 ns, '0' after 20 ns;
		wait for 30 ns; 
	end loop;  

	
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
