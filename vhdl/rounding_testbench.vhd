
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY rounding_testbench IS
END rounding_testbench;

ARCHITECTURE behavior OF rounding_testbench IS 
-- this testbench is completely combinatorial, so it should be real fast. 
	COMPONENT rounding
	Generic ( n: positive := 36); 
	PORT(
		accl : IN std_logic_vector(42 downto 0);          
		yrnd : OUT std_logic_vector(22 downto 0)
		);
	END COMPONENT;

	SIGNAL accl :  std_logic_vector(42 downto 0);
	SIGNAL yrnd :  std_logic_vector(22 downto 0);
	signal fixedin : std_logic_vector(20 downto 0) := (others => '0');
	signal varyin : std_logic_vector(21 downto 0) := (others => '0');
BEGIN

	uut: rounding 
	generic map (n => 36) 
	PORT MAP(
		accl => accl,
		yrnd => yrnd
	);

   
   accl <= (fixedin & varyin);

   -- we're interested in overflow performance. 
   tb : PROCESS(varyin) is
      variable i : integer; 
   BEGIN

	      varyin <= varyin + 1 after 1 ns; 
   	   

  END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
