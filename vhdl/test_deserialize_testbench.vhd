
-- VHDL Test Bench Created from source file test_deserialize.vhd -- 11:15:12 07/28/2003
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

	COMPONENT test_deserialize
	PORT(
		clk8 : IN std_logic;
		fiberout : IN std_logic       
		);
	END COMPONENT;

	SIGNAL clk8 :  std_logic := '0';
	SIGNAL fiberout :  std_logic;
	signal start,  done : std_logic; 


	component test_serialize is
	    Generic (filename : string := "input.dat"); 
	    Port ( START : in std_logic;
	           DOUT : out std_logic;
			 DONE : out std_logic);
	end component;

BEGIN

	uut: test_deserialize PORT MAP(
		clk8 => clk8,
		fiberout => fiberout);

	test_serializer : test_serialize
			generic map ( filename => "test_deserialize.dat")	
			port map (
				START => start,
				DOUT => fiberout,
				DONE => done);


    clk8 <= not clk8 after 62.5 ns; 
     start <= '1' after 100 us; 



-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
