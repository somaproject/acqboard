
-- VHDL Test Bench Created from source file filter_test.vhd -- 16:44:45 01/07/2003
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

-- Filter_test testbench --------------------------------------
--  Filter test bench. This essentially wires-up all the components, but should
--  be easier to get data out of then a real implementation, as the actual one
--  only exposes the 8B/10B encoded output. 
-- 
--  The input here (in addition to the requisite 16 MHz clock signal) will be
--  
ARCHITECTURE behavior OF testbench IS 

	COMPONENT filter_test
	PORT(
		clkin : IN std_logic;
		resetin : IN std_logic;
		datain : IN std_logic_vector(13 downto 0);          
		convst : OUT std_logic;
		oeb : OUT std_logic_vector(9 downto 0);
		outbyteout : OUT std_logic;
		macrnd : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL convst :  std_logic;
	SIGNAL clkin :  std_logic;
	SIGNAL resetin :  std_logic;
	SIGNAL datain :  std_logic_vector(13 downto 0);
	SIGNAL oeb :  std_logic_vector(9 downto 0);
	SIGNAL outbyteout :  std_logic;
	SIGNAL macrnd :  std_logic_vector(15 downto 0);

BEGIN

	uut: filter_test PORT MAP(
		convst => convst,
		clkin => clkin,
		resetin => resetin,
		datain => datain,
		oeb => oeb,
		outbyteout => outbyteout,
		macrnd => macrnd
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
