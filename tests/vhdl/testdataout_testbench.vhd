
-- VHDL Test Bench Created from source file testdataout.vhd -- 22:34:41 01/18/2003
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
use ieee.std_logic_arith.ALL; 

 use std.textio.all; 
 use ieee.std_logic_textio; 
ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT testdataout
	PORT(
		clk : IN std_logic;          
		kout : OUT std_logic;
		timerout : OUT std_logic;
		dout : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL  sampclk :  std_logic := '1';
	SIGNAL kout :  std_logic;
	SIGNAL timerout :  std_logic;
	SIGNAL dout :  std_logic;

BEGIN

	uut: testdataout PORT MAP(
		clk => clk,
		kout => kout,
		timerout => timerout,
		dout => dout
	);

   CLK <= not CLK after 15625 ps;

	SAMPCLK <= not sampclk after 62500 ps; 


-- *** Test Bench - User Defined Section ***
   tb : PROCESS (CLK, sampclk, DOUT) is        
			file out_file : text open write_mode is "testdata.8b10b";
        variable iline, oline : line; 
   BEGIN
		if rising_edge(sampclk) then 
			 	write(oline, to_bit(dout));
			   writeline(out_file, oline);

		end if; 
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
