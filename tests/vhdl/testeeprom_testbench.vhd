
-- VHDL Test Bench Created from source file tessteeprom.vhd -- 09:33:52 06/03/2004
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

ENTITY testeeprom_testbench IS
END testeeprom_testbench;

ARCHITECTURE behavior OF testeeprom_testbench IS 

	COMPONENT tessteeprom
	PORT(
		CLK : IN std_logic;
		ESO : IN std_logic;
		RESET : IN std_logic;          
		ECS : OUT std_logic;
		ESI : OUT std_logic;
		ESCK : OUT std_logic;
		LED0 : OUT std_logic;
		LED1 : OUT std_logic;
		DELAYTICKOUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL ECS :  std_logic;
	SIGNAL ESO :  std_logic;
	SIGNAL ESI :  std_logic;
	SIGNAL ESCK :  std_logic;
	SIGNAL LED0 :  std_logic;
	SIGNAL LED1 :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL DELAYTICKOUT :  std_logic;

BEGIN

	uut: tessteeprom PORT MAP(
		CLK => CLK,
		ECS => ECS,
		ESO => ESO,
		ESI => ESI,
		ESCK => ESCK,
		LED0 => LED0,
		LED1 => LED1,
		RESET => RESET,
		DELAYTICKOUT => DELAYTICKOUT
	);

   RESET <= '0' after 100 ns; 
	clk <= not clk after 15 ns;
-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
