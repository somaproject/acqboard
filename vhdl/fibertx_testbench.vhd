
-- VHDL Test Bench Created from source file fibertx.vhd -- 14:33:56 06/24/2003
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

	COMPONENT fibertx
	PORT(
		clk : IN std_logic;
		clk8 : IN std_logic;
		reset : IN std_logic;
		outsample : IN std_logic;
		cmddone : IN std_logic;
		y : IN std_logic_vector(15 downto 0);
		cmdsts : IN std_logic_vector(3 downto 0);
		cmdid : IN std_logic_vector(6 downto 0);
		outbyte : IN std_logic;
		chksum : IN std_logic_vector(15 downto 0);          
		fiberout : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL clk8 :  std_logic;
	SIGNAL reset :  std_logic := '1';
	SIGNAL outsample :  std_logic;
	SIGNAL fiberout :  std_logic;
	SIGNAL cmddone :  std_logic;
	SIGNAL y :  std_logic_vector(15 downto 0) := "0000000000000000";
	SIGNAL cmdsts :  std_logic_vector(3 downto 0) := "0000";
	SIGNAL cmdid :  std_logic_vector(6 downto 0) := "0000000";
	SIGNAL cmderr : std_logic := '0';
	SIGNAL outbyte :  std_logic;
	SIGNAL chksum :  std_logic_vector(15 downto 0) := (others => '0');
	signal counter : integer := 0;

    constant clockperiod: time := 15.625 ns; 

BEGIN

	uut: fibertx PORT MAP(
		clk => clk,
		clk8 => clk8,
		reset => reset,
		outsample => outsample,
		fiberout => fiberout,
		cmddone => cmddone,
		y => y,
		cmdsts => cmdsts,
		cmdid => cmdid,
		outbyte => outbyte,
		chksum => chksum
	);

   clk <= not clk after clockperiod / 2;
   reset <= '0' after 14 ns; 


-- *** Test Bench - User Defined Section ***
   tb : PROCESS(CLK) is
   BEGIN
      if rising_edge(CLK) then

	     counter <= counter + 1; 
	 end if; 
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

   outsample <= '1' after clockperiod/2  when counter mod 2000 = 0 
    				else '0' after clockperiod/2  ;
   outbyte <= '1' after clockperiod/2 when counter mod 80 = 0 
   				else '0' after clockperiod/2;
   clk8 <= '1' after clockperiod/2 when counter mod 8 = 0 
   				else '0' after clockperiod/2 ;


END;
