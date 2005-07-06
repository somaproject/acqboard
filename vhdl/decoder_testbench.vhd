
-- VHDL Test Bench Created from source file decoder.vhd -- 14:36:16 06/29/2003
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

ENTITY decoder_testbench IS
END decoder_testbench;

ARCHITECTURE behavior OF decoder_testbench IS 

	COMPONENT decoder
	PORT(
		clk : IN std_logic;
		din : IN std_logic;          
		dataout : OUT std_logic_vector(7 downto 0);
		kout : OUT std_logic;
		code_err : OUT std_logic;
		disp_err : OUT std_logic;
		datalock : OUT std_logic;
		reset : IN std_logic);
	END COMPONENT;

	component test_serialize is
	    	Generic (filename : string ); 
	    	Port ( START : in std_logic;
	           DOUT : out std_logic;
			 DONE : out std_logic);
	end component;

	SIGNAL clk :  std_logic := '0';
	SIGNAL din :  std_logic;
	SIGNAL dataout :  std_logic_vector(7 downto 0);
	SIGNAL kout :  std_logic;
	SIGNAL code_err :  std_logic;
	SIGNAL disp_err :  std_logic;
	SIGNAL datalock :  std_logic;
	SIGNAL reset :  std_logic;		  	
	signal start, done : std_logic := '0';

BEGIN


	clk <= not clk after 15.625 ns /2; 
	uut: decoder PORT MAP(
		clk => clk,
		din => din,
		dataout => dataout,
		kout => kout,
		code_err => code_err,
		disp_err => disp_err,
		datalock => datalock,
		reset => reset
	);

	inputdata : test_serialize 
		generic map ( 
			filename => "input.dat")
		port map (
			dout => din,
			start => start,
			done => done);

	start <= '1' after 10 us;

-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
