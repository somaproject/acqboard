
-- VHDL Test Bench Created from source file rmac.vhd -- 20:45:18 04/04/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.ALL;

use IEEE.numeric_std.ALL;


ENTITY rmactest IS
END rmactest;

ARCHITECTURE behavior OF rmactest IS 

	COMPONENT rmac
	PORT(
		CLK : IN std_logic;
		X : IN std_logic_vector(15 downto 0);
		H : IN std_logic_vector(21 downto 0);
		XBASE : IN std_logic_vector(7 downto 0);
		STARTMAC : IN std_logic;
		RESET : IN std_logic;          
		XA : OUT std_logic_vector(7 downto 0);
		HA : OUT std_logic_vector(7 downto 0);
		MACDONE : OUT std_logic;
		Y : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL X, LX :  std_logic_vector(15 downto 0);
	SIGNAL XA :  std_logic_vector(7 downto 0);
	SIGNAL H, LH :  std_logic_vector(21 downto 0);
	SIGNAL HA :  std_logic_vector(7 downto 0);
	SIGNAL XBASE :  std_logic_vector(7 downto 0);
	SIGNAL STARTMAC :  std_logic;
	SIGNAL MACDONE :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL Y :  std_logic_vector(15 downto 0);


   signal err : std_logic := '0';


BEGIN

	uut: rmac PORT MAP(
		CLK => CLK,
		X => X,
		XA => XA,
		H => H,
		HA => HA,
		XBASE => XBASE,
		STARTMAC => STARTMAC,
		MACDONE => MACDONE,
		RESET => RESET,
		Y => Y
	);


	clk <= not clk after 7.8125 ns;

	reset <= '0' after 100 ns; 

	-- open file
	-- read line
	-- load values into fake-rams

   process(clk) is
	begin
		if rising_edge(clk) then
			X <= LX;
			H <= LH;
		end if; 
	end process; 

	tb: process is
	  	file xfile, xbasefile, hfile, yfile : text; 
	  	variable xline, xbaseline, hline, yline: line;
		type bufarray is array (0 to 255) of integer;
		variable xbuf, hbuf : bufarray; 
		variable yref : integer; 
		variable temp: integer; 
		

	begin

		wait until falling_edge(reset); 
		-- open the files:
	  file_open(xfile, "x.dat", read_mode); 
	  file_open(xbasefile, "xbase.dat", read_mode); 
	  file_open(hfile, "h.dat", read_mode); 
	  file_open(yfile, "y.dat", read_mode); 

	  while not endfile(xfile) loop
			readline(xfile, xline);
			readline(xbasefile, xbaseline);
			readline(hfile, hline);
			readline(yfile, yline); 
			
			-- load the x-values
			for i in 0 to 255 loop
				read(xline, temp);
				xbuf(i) := temp;
			end loop; 

			-- load the h-values
			for i in 0 to 255 loop
				read(hline, temp);
				hbuf(i) := temp;
			end loop; 
		
			read(xbaseline, temp);
			xbase <= std_logic_vector(to_unsigned(temp, 8));  

			read(yline, yref); 


			-- now, the actual MAC-ing

			wait until rising_edge(clk); 
			startmac <= '1';

			while MACDONE = '0' loop
				wait until rising_edge(clk); 
				startmac <= '0'; 
				lx <= std_logic_vector(to_signed(xbuf(TO_INTEGER(unsigned(xa))), 16)); 
				lh <= std_logic_vector(to_signed(hbuf(TO_INTEGER(unsigned(ha))), 22));


			end loop; 
			
			-- mac should be done; compare with Y
			if Y = std_logic_vector(to_signed(yref, 16)) then 
				err <= '0';
			else
				err <= '1';
			end if; 

			assert Y = std_logic_vector(to_signed(yref, 16))
				report "Output of RMAC differs from expected value"
				severity error; 

	  end loop; 
	  assert false
	  	report "End of simulation"
		severity Failure; 
	end process tb; 

END;
