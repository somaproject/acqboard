
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT rmac
	PORT(
		clk : IN std_logic;
		x : IN std_logic_vector(15 downto 0);
		h : IN std_logic_vector(21 downto 0);
		xbase : IN std_logic_vector(6 downto 0);
		startmac : IN std_logic;
		macdone : out std_logic; 
		reset : IN std_logic;          
		xa : OUT std_logic_vector(6 downto 0);
		ha : OUT std_logic_vector(6 downto 0);
		y : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL x , lx, llx:  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL xa :  std_logic_vector(6 downto 0) := (others => '0');
	SIGNAL h :  std_logic_vector(21 downto 0);
	SIGNAL ha :  std_logic_vector(6 downto 0);
	SIGNAL xbase :  std_logic_vector(6 downto 0);
	SIGNAL startmac, macdone :  std_logic;
	SIGNAL reset :  std_logic := '0';
	SIGNAL y :  std_logic_vector(15 downto 0);

    constant clockperiod : time := 15 ns; 
    
BEGIN
    clk <= not clk after clockperiod / 2;
    reset <= '0' after 40 ns; 

	uut: rmac PORT MAP(
		clk => clk,
		x => x,
		xa => xa,
		h => h,
		ha => ha,
		xbase => xbase,
		startmac => startmac,
		reset => reset,
		macdone => macdone,
		y => y
	);

   H <= "0111111111111111111111";
   xbase <= "0000000";

-- *** Test Bench - User Defined Section ***
   tb : PROCESS(clk) is
       variable counter : integer := 0;
   BEGIN
   	if rising_edge(CLK) then
   	 x <= lx after 3 ns;
	 lx <= llx after 3 ns; 
	 if RESET = '1' then
	 	counter := 0;
	 else 
	 	counter := counter + 1;
	 end if; 
	 --
	 -- llx <= llx + 1; 
	 llx <= "0000000000000001";
	 if counter = 10 then
	 	startmac <= '1' after 3 ns;
	 else
	 	startmac <= '0' after 3 ns;
	end if; 
    end if; 

   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
