
-- VHDL Test Bench Created from source file filter_test.vhd -- 16:44:45 01/07/2003
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
USE std.textio.ALL;


ENTITY testbench IS
END testbench;

-- Filter_test testbench --------------------------------------
--  Filter test bench. This essentially wires-up all the components, but should
--  be easier to get data out of then a real implementation, as the actual one
--  only exposes the 8B/10B encoded output. 
-- 
--  The input here (in addition to the requisite 32 MHz CLKIN) will be
--  a system which reads in an array of 10 14-bit 2s-complement integers
--  from a text file, a line at a time, triggered by the going high of CONVST. 
--  
ARCHITECTURE behavior OF testbench IS 

	COMPONENT filter_test
	PORT(
		clkin : IN std_logic;
		resetin : IN std_logic;
		datain : IN std_logic_vector(13 downto 0);          
		convst : OUT std_logic;
		oeb : OUT std_logic_vector(9 downto 0);
		outbyteout : OUT std_logic;
		macrnd : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL convst :  std_logic := '1';
	SIGNAL clkin :  std_logic := '1';
	SIGNAL resetin :  std_logic := '1';
	SIGNAL datain :  std_logic_vector(13 downto 0) := "00000000000000";
	SIGNAL oeb :  std_logic_vector(9 downto 0);
	SIGNAL outbyteout :  std_logic;
	SIGNAL macrnd, macrndl :  std_logic_vector(15 downto 0);
	subtype dataword is integer range -8192 to 8191;
	type inputarray is array (0 to 9) of dataword;
			signal dataouts : inputarray := (others => 0); 

BEGIN

	uut: filter_test PORT MAP(
		convst => convst,
		clkin => clkin,
		resetin => resetin,
		datain => datain,
		oeb => oeb,
		outbyteout => outbyteout,
		macrnd => macrnd
	);


-- *** Test Bench - User Defined Section ***

   resetin <= '0' after 40 ns;

	simulator_in: process (CONVST, oeb) is
			--subtype dataword is integer range -8192 to 8191;
			file input_file : text open read_mode is "../dsp/simulation/test.dat";
			variable tempdata: dataword;
			variable iline: line; 
			

		begin
			if rising_edge(convst) then
				readline(input_file, iline);
				for channelnumber in 0 to 9 loop
					read(iline, tempdata);
					dataouts(channelnumber) <= tempdata; 
				end loop; 
			end if;

			if falling_edge(oeb(0)) then
				datain <= conv_std_logic_vector(dataouts(0), 14) after 20 ns;
			elsif rising_edge(oeb(0)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(1)) then
				datain <= conv_std_logic_vector(dataouts(1), 14) after 20 ns;
			elsif rising_edge(oeb(1)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(2)) then
				datain <= conv_std_logic_vector(dataouts(2), 14) after 20 ns;
			elsif rising_edge(oeb(2)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(3)) then
				datain <= conv_std_logic_vector(dataouts(3), 14) after 20 ns;
			elsif rising_edge(oeb(3)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if;
			if falling_edge(oeb(4)) then
				datain <= conv_std_logic_vector(dataouts(4), 14) after 20 ns;
			elsif rising_edge(oeb(4)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if;
			if falling_edge(oeb(5)) then
				datain <= conv_std_logic_vector(dataouts(5), 14) after 20 ns;
			elsif rising_edge(oeb(5)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(6)) then
				datain <= conv_std_logic_vector(dataouts(6), 14) after 20 ns;
			elsif rising_edge(oeb(6)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(7)) then
				datain <= conv_std_logic_vector(dataouts(7), 14) after 20 ns;
			elsif rising_edge(oeb(7)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(8)) then
				datain <= conv_std_logic_vector(dataouts(8), 14) after 20 ns;
			elsif rising_edge(oeb(8)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 
			if falling_edge(oeb(9)) then
				datain <= conv_std_logic_vector(dataouts(9), 14) after 20 ns;
			elsif rising_edge(oeb(9)) then 
				datain <= "ZZZZZZZZZZZZZZ" after 6 ns;
			end if; 


	  	end process simulator_in;

		simulator_out :process (outbyteout) is
			 file output_file : text open write_mode is "../dsp/simulation/output.dat";
		begin
			 if rising_edge(outbyteout) then
			 	macrndl<= macrnd;
			 end if;
		end process simulator_out; 

	  clk_one: process(clkin) is
     begin
             if clkin = '1' then 
                     clkin <= '0' after 15625 ps, '1' after 31250 ps;  
             end if;
     end process clk_one; 

-- *** End Test Bench - User Defined Section ***

END;
