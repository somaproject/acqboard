-- VHDL Test Bench Created from source file fiberrx.vhd -- 10:35:39 07/01/2003
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

	component FiberRX is
	    Port ( CLK : in std_logic;
	           FIBERIN : in std_logic;
			 RESET : in std_logic; 
	           DATA : out std_logic_vector(31 downto 0);
	           CMD : out std_logic_vector(3 downto 0);
	           NEWCMD : out std_logic;
	           CMDID : out std_logic_vector(3 downto 0);
	           CHKSUM : out std_logic_vector(7 downto 0));
	end component;
	
	-- input test 	
	component test_serialize is
	    Generic (filename : string); 
	    Port ( START : in std_logic;
	          DOUT : out std_logic;
			 DONE : out std_logic);
	end component;

	SIGNAL clk :  std_logic := '0';
	SIGNAL fiberin :  std_logic;
	SIGNAL reset :  std_logic := '1';
	SIGNAL data :  std_logic_vector(31 downto 0);
	SIGNAL cmd :  std_logic_vector(3 downto 0);
	SIGNAL newcmd :  std_logic;
	SIGNAL cmdid :  std_logic_vector(3 downto 0);
	SIGNAL chksum :  std_logic_vector(7 downto 0);
	

	signal txstart, txdone : std_logic := '0';

BEGIN

	clk <= not clk after 15.625 ns /2; 
	
	reset <= '0' after 40 ns; 
	
	txstart <= '1' after 10 us, '0' after 10.10 us; 
	uut: fiberrx PORT MAP(
		clk => clk,
		fiberin => fiberin,
		reset => reset,
		data => data,
		cmd => cmd,
		newcmd => newcmd,
		cmdid => cmdid,
		chksum => chksum
	);

	simulated_data : test_serialize 
		generic map (filename => "commands.dat") 
		port map (
		start => txstart,
		dout => fiberin,
		done => txdone
	);

	


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
