-- C:\DESKTOP\ACQBOARD\VHDL
-- VHDL Test Bench created by
-- HDL Bencher 5.1i
-- Sat Jun 21 20:25:42 2003
-- 
-- Notes:
-- 1) This testbench has been automatically generated from
--   your Test Bench Waveform
-- 2) To use this as a user modifiable testbench do the following:
--   - Save it as a file with a .vhd extension (i.e. File->Save As...)
--   - Add it to your project as a testbench source (i.e. Project->Add Source...)
-- 

LIBRARY  IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY  SIMPRIM;
USE SIMPRIM.VCOMPONENTS.ALL;
USE SIMPRIM.VPACKAGE.ALL;

LIBRARY ieee;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE testbench_arch OF testbench IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT rounding
		PORT (
			YRND : out  std_logic_vector (22 DOWNTO 0);
			ACCL : in  std_logic_vector (30 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL YRND : std_logic_vector (22 DOWNTO 0);
	SIGNAL ACCL : std_logic_vector (30 DOWNTO 0);

BEGIN
	UUT : rounding
	PORT MAP (
		YRND => YRND,
		ACCL => ACCL
	);

	PROCESS
		VARIABLE TX_OUT : LINE;
		VARIABLE TX_ERROR : INTEGER := 0;

		PROCEDURE CHECK_YRND(
			next_YRND : std_logic_vector (22 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (YRND /= next_YRND) THEN 
				write(TX_LOC,string'("Error at time="));
				write(TX_LOC, TX_TIME);
				write(TX_LOC,string'("ns YRND="));
				write(TX_LOC, YRND);
				write(TX_LOC, string'(", Expected = "));
				write(TX_LOC, next_YRND);
				write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				writeline(results, TX_LOC);
				Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		BEGIN
		-- --------------------
		ACCL <= transport std_logic_vector'("0000000100000000000000110000000"); --800180
		-- --------------------
		WAIT FOR 100 ns; -- Time=100 ns
		ACCL <= transport std_logic_vector'("0000000100000000000000010000000"); --800080
		-- --------------------
		WAIT FOR 100 ns; -- Time=200 ns
		ACCL <= transport std_logic_vector'("0000000100000000000000110000001"); --800181
		-- --------------------
		WAIT FOR 100 ns; -- Time=300 ns
		ACCL <= transport std_logic_vector'("0000000100000000000000101000000"); --800140
		-- --------------------
		WAIT FOR 100 ns; -- Time=400 ns
		ACCL <= transport std_logic_vector'("0000000000000000000000010000001"); --81
		-- --------------------
		WAIT FOR 500 ns; -- Time=900 ns
		ACCL <= transport std_logic_vector'("0000000110000000000000000000000"); --C00000
		-- --------------------
		WAIT FOR 800 ns; -- Time=1700 ns
		ACCL <= transport std_logic_vector'("0000000110000000000000000000001"); --C00001
		-- --------------------
		WAIT FOR 1200 ns; -- Time=2900 ns
		ACCL <= transport std_logic_vector'("1111111111111111111111111111111"); --7FFFFFFF
		-- --------------------
		WAIT FOR 1500 ns; -- Time=4400 ns
		-- --------------------

		IF (TX_ERROR = 0) THEN 
			write(TX_OUT,string'("No errors or warnings"));
			writeline(results, TX_OUT);
			ASSERT (FALSE) REPORT
				"Simulation successful (not a failure).  No problems detected. "
				SEVERITY FAILURE;
		ELSE
			write(TX_OUT, TX_ERROR);
			write(TX_OUT, string'(
				" errors found in simulation"));
			writeline(results, TX_OUT);
			ASSERT (FALSE) REPORT
				"Errors found during simulation"
				SEVERITY FAILURE;
		END IF;
	END PROCESS;
END testbench_arch;

CONFIGURATION rounding_cfg OF testbench IS
	FOR testbench_arch
	END FOR;
END rounding_cfg;
