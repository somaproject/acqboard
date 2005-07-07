
-- VHDL Test Bench Created from source file testsamples.vhd -- 22:06:30 01/19/2003
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
use ieee.std_logic_arith.all;
ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT testsamples
	PORT(
		clk : IN std_logic;          
		kout : OUT std_logic;
		timerout : OUT std_logic;				  
		CONVST: out std_logic;
	   DATAIN : in std_logic_vector(13 downto 0);
   	SAMP_OE: out std_logic; 
		dout : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL kout :  std_logic;
	SIGNAL timerout :  std_logic;
	SIGNAL dout :  std_logic;
	SIGNAL SAMP_OE, CONVST: std_logic;
	signal DATAIN: std_logic_vector(13 downto 0) := "00000000000000";
	signal datacnt : integer;  
BEGIN

	uut: testsamples PORT MAP(
		clk => clk,
		kout => kout,
		timerout => timerout,
		dout => dout,
		convst => convst,
		datain => datain,
		samp_oe => samp_oe
	);

	clk <= not clk after 15000 ps; 
-- *** Test Bench - User Defined Section ***
   tb : PROCESS (CONVST)
   BEGIN
	   if falling_edge(CONVST) then
			DATAIN <= conv_std_logic_vector(datacnt, 14);
			if datacnt > 16000 then
				datacnt <= 0;
			else
				datacnt <= datacnt  + 1;
			end if;  
		end if; 
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

		
END;
