
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


ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT rmac
	PORT(
		CLK : IN std_logic;
		X : IN std_logic_vector(15 downto 0);
		H : IN std_logic_vector(21 downto 0);
		XBASE : IN std_logic_vector(6 downto 0);
		STARTMAC : IN std_logic;
		RESET : IN std_logic;          
		XA : OUT std_logic_vector(6 downto 0);
		HA : OUT std_logic_vector(6 downto 0);
		MACDONE : OUT std_logic;
		Y : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL X :  std_logic_vector(15 downto 0);
	SIGNAL XA :  std_logic_vector(6 downto 0);
	SIGNAL H :  std_logic_vector(21 downto 0);
	SIGNAL HA :  std_logic_vector(6 downto 0);
	SIGNAL XBASE :  std_logic_vector(6 downto 0);
	SIGNAL STARTMAC :  std_logic;
	SIGNAL MACDONE :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL Y :  std_logic_vector(15 downto 0);


   signal error : std_logic := '0';


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


	tb: process is
	  	file xfile, xbasefile, hfile, yfile : text; 
	  	variable xline, xbaseline, hline, yline: line;
		type bufarray is array (0 to 127) of integer;
		variable xbuf, hbuf : bufarray; 
		variable yref : integer; 
		variable temp: integer; 
		variable lx : std_logic_vector(15 downto 0) := (others => '0');
		variable lh : std_logic_vector(21 downto 0) := (others => '0');


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
			for i in 0 to 127 loop
				read(xline, temp);
				xbuf(i) := temp;
			end loop; 

			-- load the h-values
			for i in 0 to 127 loop
				read(hline, temp);
				hbuf(i) := temp;
			end loop; 
		
			read(xbaseline, temp);
			xbase <= std_logic_vector(to_unsigned(temp, 7));  

			read(yline, yref); 


			-- now, the actual MAC-ing

			wait until rising_edge(clk); 
			startmac <= '1';

			while MACDONE = '0' loop
				wait until rising_edge(clk); 
				startmac <= '0'; 
				lx := std_logic_vector(to_signed(xbuf(TO_INTEGER(unsigned(xa))), 16)); 
				lh := std_logic_vector(to_signed(hbuf(TO_INTEGER(unsigned(ha))), 22));
				x <= lx;
				h <= lh; 
			end loop; 
			
			-- mac should be done; compare with Y
			if Y = std_logic_vector(to_signed(yref, 16)) then 
				error <= '0';
			else
				error <= '1';
			end if; 

	  end loop; 
	end process tb; 

END;
