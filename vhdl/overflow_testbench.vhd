
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT overflow
	PORT(
		yrndl : IN std_logic_vector(22 downto 0);          
		yoverf : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL yoverf :  std_logic_vector(15 downto 0);
	SIGNAL yrndl :  std_logic_vector(22 downto 0) := "11111100000000000000000";

BEGIN

	uut: overflow PORT MAP(
		yoverf => yoverf,
		yrndl => yrndl
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS(yrndl) 
   BEGIN
      yrndl <= yrndl + 1 after 1 ns; 
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
