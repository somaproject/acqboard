
-- VHDL Test Bench Created from source file pgaload.vhd -- 21:26:35 02/03/2005
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

ENTITY pgaloadtest IS
END pgaloadtest;

ARCHITECTURE behavior OF pgaloadtest IS 

	COMPONENT pgaload
	PORT(
		CLK : IN std_logic;
		RESET : IN std_logic;
		CHAN : IN std_logic_vector(3 downto 0);
		GAIN : IN std_logic_vector(2 downto 0);
		FILTER : IN std_logic;
		GSET : IN std_logic;
		ISET : IN std_logic;
		FSET : IN std_logic;
		PGARESET : IN std_logic;
		ISEL : IN std_logic_vector(1 downto 0);          
		SCLK : OUT std_logic;
		RCLK : OUT std_logic;
		SOUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL RESET :  std_logic := '1';
	SIGNAL SCLK :  std_logic;
	SIGNAL RCLK :  std_logic;
	SIGNAL SOUT :  std_logic;
	SIGNAL CHAN :  std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL GAIN :  std_logic_vector(2 downto 0) := (others => '0');
	SIGNAL FILTER :  std_logic :='0';
	SIGNAL GSET :  std_logic;
	SIGNAL ISET :  std_logic;
	SIGNAL FSET :  std_logic;
	SIGNAL PGARESET :  std_logic := '0';
	SIGNAL ISEL :  std_logic_vector(1 downto 0) := (others => '0');
 
	component PGA is
	    Port ( SCLK : in std_logic;
	           RCLK : in std_logic;
	           SIN : in std_logic;
			 BOUTS: out std_logic_vector(6*8-1 downto 0) );
	end  component;

	signal pgadata : std_logic_vector(6*8-1 downto 0);
	
	-- parsing
	type gainarray is array(9 downto 0) of std_logic_vector(2 downto 0); 
	signal gains : gainarray := (others => "000"); 
	signal filters : std_logic_vector(9 downto 0) := (others => '0'); 
	signal inselA, inselb: std_logic_vector(1 downto 0); 
	 

BEGIN


	uut: pgaload PORT MAP(
		CLK => CLK,
		RESET => RESET,
		SCLK => SCLK,
		RCLK => RCLK,
		SOUT => SOUT,
		CHAN => CHAN,
		GAIN => GAIN,
		FILTER => FILTER,
		GSET => GSET,
		ISET => ISET,
		FSET => FSET,
		PGARESET => PGARESET,
		ISEL => ISEL
	);

     -- hook up the gains
	filters(1) <= pgadata(47);
	gains(1) <= pgadata(44) & pgadata(45) & pgadata(46);
	gains(0) <= pgadata(43 downto 41); 
	filters(0) <= pgadata(40);

	filters(3) <= pgadata(39);
	gains(3) <= pgadata(36) & pgadata(37) & pgadata(38);
	gains(2) <= pgadata(35 downto 33); 
	filters(2) <= pgadata(32);

	inselA(1) <= pgadata(29);
	inselA(0) <= pgadata(28); 

	gains(4) <= pgadata(27 downto 25); 
	filters(4) <= pgadata(24);
	 
	inselB(1) <= pgadata(21);
	inselB(0) <= pgadata(20); 

	gains(5) <= pgadata(19 downto 17); 
	filters(5) <= pgadata(16);

	filters(7) <= pgadata(15);
	gains(7) <= pgadata(12) & pgadata(13) & pgadata(14);
	gains(6) <= pgadata(11 downto 9); 
	filters(6) <= pgadata(8);

	filters(9) <= pgadata(7);
	gains(9) <= pgadata(4) & pgadata(5) & pgadata(6);
	gains(8) <= pgadata(3 downto 1); 
	filters(8) <= pgadata(0);


	CLK <= not CLK after 10 ns; 
	RESET <= '0' after 40 ns; 

     PGAuut: PGA port map
		(SCLK => SCLK,
		RCLK => RCLK,
		SIN => SOUT,
		BOUTS => pgadata); 
		 
	-- running code
	main: process is
	begin
		wait until falling_edge(RESET);
		wait for 20 ns; 
		wait until rising_edge(CLK); 

		CHAN <= "0000"; 
		GAIN <= "110";
		GSET <= '1';
		wait until rising_edge(CLK);
		GSET <= '0';
		for i in 1 to 300 loop
			wait until rising_edge(CLK);
		end loop; 
		assert gains(0) = "110" 
			report "Error setting gains(0)"
			severity error; 

		CHAN <= "0001"; 
		GAIN <= "101";
		GSET <= '1';
		wait until rising_edge(CLK);
		GSET <= '0';
		for i in 1 to 300 loop
			wait until rising_edge(CLK);
		end loop; 
		assert gains(1) = "101" 
			report "Error setting gains(1)"
			severity error; 

		CHAN <= "0001"; 
		FILTER <= '1';
		FSET <= '1';
		wait until rising_edge(CLK);
		FSET <= '0';
		for i in 1 to 300 loop
			wait until rising_edge(CLK);
		end loop; 
		assert filters(1) = '1' 
			report "Error setting filters(1)"
			severity error; 


		CHAN <= "1000"; 
		GAIN <= "111";
		GSET <= '1';
		wait until rising_edge(CLK);
		GSET <= '0';
		for i in 1 to 300 loop
			wait until rising_edge(CLK);
		end loop; 
		assert gains(8) = "111" 
			report "Error setting gains(8)"
			severity error; 

		assert false
			report "End of simulation"
			severity failure; 

	end process main; 
END;
