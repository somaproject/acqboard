
-- VHDL Test Bench Created from source file accumulator.vhd -- 19:58:19 12/03/2004
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
use ieee.std_logic_textio.all; 
use  ieee.numeric_std.all; 
use std.TextIO.ALL; 


ENTITY mactest IS
END mactest;

ARCHITECTURE behavior OF mactest IS 

	COMPONENT accumulator
		Generic (n : positive := 24); 
	PORT(
		CLK : IN std_logic;
		P : IN std_logic_vector(n-1 downto 0);
		CLR : IN std_logic;          
		ACC : OUT std_logic_vector((n-1)+7 downto 0)
		);
	END COMPONENT;


	component multiplier is	   
	    Generic ( n: positive := 24); 
	    Port ( CLK : in std_logic;
	           A : in std_logic_vector(15 downto 0);
	           B : in std_logic_vector(21 downto 0);
	           P : out std_logic_vector(n-1 downto 0));
	end component;


	
	component rounding is
	    Generic ( n: positive := 36); 
	       Port ( ACCL : in std_logic_vector((n-1)+7 downto 0);
		         YRND : out std_logic_vector(22 downto 0));
	end component;


	component overflow is
	    Port ( YOVERF : out std_logic_vector(15 downto 0);
	           YRNDL : in std_logic_vector(22 downto 0));
	end component;


	SIGNAL A : std_logic_vector(15 downto 0) := (others => '0'); 
	SIGNAL B :  std_logic_vector(21 downto 0) := (others => '0');
	SIGNAL POUT, expected_POUT : std_logic_vector(25 downto 0) := (others => '0');
	 
	SIGNAL multclk, accclk :  std_logic := '0';
	SIGNAL P :  std_logic_vector(25 downto 0) := (others => '0');
	SIGNAL ACC :  std_logic_vector(32 downto 0); 
	SIGNAL CLR, CLRL, CLRLL :  std_logic;

	signal done, acc_done, mult_done, overf_done, round_done  : std_logic := '0';
	signal rndin: std_logic_vector(32 downto 0) := (others => '0'); 
	signal rndout, rndout_expct : std_logic_vector(22 downto 0) := (others => '0');

	signal ofin : std_logic_vector(22 downto 0) := (others => '0'); 
	signal ofout: std_logic_vector(15 downto 0) := (others => '0');

BEGIN

	acc_uut: accumulator generic map(
		n => 26)
	 PORT MAP(
		CLK => accclk,
		P => P,
		ACC => ACC,
		CLR => CLR
	);

	mult_uut: multiplier generic map(
		n => 26)
		port map (
			CLK => multclk,
			A => A, 
			B => B, 
			P => POUT); 

	round_uut : rounding generic map (
		n=> 26)
		port map ( 	
			ACCL => rndin,
			YRND => rndout); 
	
	overflow_uut : overflow port map (
		YOVERF => ofout, 
		YRNDL => ofin); 

	multclk <= not multclk after 4 ns; 


	mult_test : process is
		file mfile : text; 
	  	variable mline: line;
		variable anum, bnum, ynum : integer := 0; 
		variable ain : std_logic_vector(31 downto 0);
		variable bin : std_logic_vector(31 downto 0); 
		variable yout: std_logic_vector(31 downto 0); 

	begin
	   file_open(mfile, "multiply.dat", read_mode); 
	   while (not endfile(mfile))	 loop
		readline(mfile, mline); 	
		hread(mline, ain); 
		hread(mline, bin);
		hread(mline, yout); 

		A <= ain(15 downto 0); 
		b <= bin(21 downto 0); 
		wait until rising_edge(multclk); 
		wait until rising_edge(multclk); 
		wait until rising_edge(multclk); 
		wait until rising_edge(multclk); 
		wait until rising_edge(multclk); 
		expected_POUT <= yout(25 downto 0); 
		assert yout(25 downto 0) = POUT 
			report "Invalid multiply"
			severity error; 
				

	   end loop; 
	   mult_done <= '1';
	   wait;  

	end process; 

	accclk <= not accclk after 4 ns; 

	acc_test : process is
		file afile : text; 
	  	variable aline: line;
		variable vin : std_logic_vector(47 downto 0); 

	begin
	   file_open(afile, "accumulate.dat", read_mode); 
	   while (not endfile(afile))	 loop


		readline(afile, aline);
		clr <= '1';
		wait until rising_edge(accclk); 
		clr <= '0';  
		while aline'LENGTH /= 0 loop 	

			hread(aline, vin); 
				
			if aline'LENGTH = 0 then
				-- end of line, the most recent read was 
				-- the final product  
				wait until rising_edge(accclk);
				wait until rising_edge(accclk);  
				assert ACC = vin(32 downto 0)
					report "Invalid accumulate"
					severity error;  
			else	
				-- normal	
				P <= vin(25 downto 0); 
				wait until rising_edge(accclk); 
			end if; 

		end loop; 			

	   end loop; 
	   acc_done <= '1';  
	   wait; 
	end process; 

	round_test : process is
		file rfile : text; 
	  	variable rline: line;
		variable vin : std_logic_vector(47 downto 0); 

	begin
	   file_open(rfile, "convrnd.dat", read_mode); 
	   while (not endfile(rfile))	 loop


		readline(rfile, rline);
		hread(rline, vin);
		rndin <=  vin(32 downto 0); 
		hread(rline, vin);
		rndout_expct <= vin(22 downto 0); 
		wait until rising_edge(accclk); 
		
		assert rndout = vin(22 downto 0)
			report "Convergent rounding error"
			severity error;
	   end loop; 
	   round_done <= '1';
	   wait;  

	end process; 

	overf_test : process is
		file ofile : text; 
	  	variable oline: line;
		variable vin : std_logic_vector(47 downto 0); 

	begin
	   file_open(ofile, "overflow.dat", read_mode); 
	   while (not endfile(ofile))	 loop


		readline(ofile, oline);
		hread(oline, vin);
		ofin <=  vin(22 downto 0); 
		hread(oline, vin);
		wait until rising_edge(accclk); 
		assert ofout = vin(15 downto 0)
			report "overflow error"
			severity error;
	   end loop;
	   overf_done <= '1';  
	   wait; 

	end process; 

	allproc : process is
	begin
		wait until acc_done = '1' and 
			mult_done = '1' and 	
			overf_done = '1' and
			round_done = '1'; 
		assert false	
			report "End of simulation"
			severity failure; 
	end process; 

END;
