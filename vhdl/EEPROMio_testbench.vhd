

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT eepromio
	PORT(
		clk : IN std_logic;
		i2cclk : IN std_logic;
		din : IN std_logic_vector(15 downto 0);
		addr : IN std_logic_vector(10 downto 0);
		wr : IN std_logic;
		en : IN std_logic;    
		sda : INOUT std_logic;      
		dout : OUT std_logic_vector(15 downto 0);
		done : OUT std_logic;
		scl : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic := '0';
	SIGNAL i2cclk :  std_logic;
	SIGNAL dout :  std_logic_vector(15 downto 0);
	SIGNAL din :  std_logic_vector(15 downto 0);
	SIGNAL addr :  std_logic_vector(10 downto 0);
	SIGNAL wr :  std_logic;
	SIGNAL en :  std_logic;
	SIGNAL done :  std_logic;
	SIGNAL scl :  std_logic;
	SIGNAL sda :  std_logic;
	signal cycle : integer := 0; 
 	constant clockperiod : time := 15 ns; 
BEGIN

	uut: eepromio PORT MAP(
		clk => clk,
		i2cclk => i2cclk,
		dout => dout,
		din => din,
		addr => addr,
		wr => wr,
		en => en,
		done => done,
		scl => scl,
		sda => sda
	);

   clk <= not clk after clockperiod / 2; 

   -- input signals
   din <= "1001000011110011";
   wr <= '0';
   ADDR <= "10110011100";
   	

   tb : PROCESS(CLK, cycle) is
   BEGIN
      if rising_edge(CLK) then
	    cycle <= cycle + 1; 

	 end if; 

	 if cycle mod 640 = 0 then
	 	i2cclk <= '1';
	 else
	 	i2cclk <= '0';
	 end if; 

	 if cycle = 100 then 
	 	en <= '1';
	 else 	
	 	en <= '0';
	 end if; 
   END PROCESS;

END;
