
-- VHDL Test Bench Created from source file acqboard.vhd -- 15:06:42 04/05/2004
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

	COMPONENT acqboard
	PORT(
		CLKIN : IN std_logic;
		ADCIN : IN std_logic_vector(4 downto 0);
		ESO : IN std_logic;
		EEPROMLEN : IN std_logic;
		FIBERIN : IN std_logic;
		RESET : IN std_logic;          
		ADCCLK : OUT std_logic;
		ADCCS : OUT std_logic;
		ADCCONVST : OUT std_logic;
		PGARCK : OUT std_logic;
		PGASRCK : OUT std_logic;
		PGASERA : OUT std_logic;
		ESI : OUT std_logic;
		ESCK : OUT std_logic;
		ECS : OUT std_logic;
		FIBEROUT : OUT std_logic;
		CLK8_OUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLKIN :  std_logic := '0';
	SIGNAL ADCIN :  std_logic_vector(4 downto 0);
	SIGNAL ADCCLK :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL ADCCONVST :  std_logic;
	SIGNAL PGARCK :  std_logic;
	SIGNAL PGASRCK :  std_logic;
	SIGNAL PGASERA :  std_logic;
	SIGNAL ESI :  std_logic;
	SIGNAL ESCK :  std_logic;
	SIGNAL ECS :  std_logic;
	SIGNAL ESO :  std_logic;
	SIGNAL EEPROMLEN :  std_logic := '0';
	SIGNAL FIBERIN :  std_logic;
	SIGNAL FIBEROUT :  std_logic;
	SIGNAL RESET :  std_logic := '1';
	SIGNAL CLK8_OUT :  std_logic;

	signal bouts :  std_logic_vector(79 downto 0) := (others => '0'); 

	component test_PGA is
	    Port ( SCLK : in std_logic;
	           RCLK : in std_logic;
	           SIN : in std_logic;
				  bouts: out std_logic_vector(10*8-1 downto 0));
	end component;

	signal cmdid, cmd : std_logic_vector(3 downto 0) :=(others => '0');
	signal cmddata0, cmddata1, cmddata2, cmddata3, cmdchksum: 
				std_logic_vector(7 downto 0) := (others => '0'); 
	signal sendcmd, cmdpending : std_logic := '0'; 
	component test_SendCMD is
	    Port ( CMDID : in std_logic_vector(3 downto 0);
	           CMD : in std_logic_vector(3 downto 0);
	           DATA0 : in std_logic_vector(7 downto 0);
	           DATA1 : in std_logic_vector(7 downto 0);
	           DATA2 : in std_logic_vector(7 downto 0);
	           DATA3 : in std_logic_vector(7 downto 0);
	           CHKSUM : in std_logic_vector(7 downto 0);
				  SENDCMD : in std_logic;
				  CMDPENDING : out std_logic;
				  DOUT : out std_logic 
			 );
	end component;

	signal syscnt : integer := 0; 

   signal eaddr, edin, edout : integer := 0;
	signal ewe : std_logic := '0'; 
	component test_EEPROM is
	    Port ( SCK : in std_logic;
	           SO : out std_logic;
	           SI : in std_logic;
	           CS : in std_logic;
	           ADDR : in integer;
				  DOUT : out integer;
				  DIN : in integer; 
				  WE : in std_logic);
	end component;	


BEGIN

	uut: acqboard PORT MAP(
		CLKIN => CLKIN,
		ADCIN => ADCIN,
		ADCCLK => ADCCLK,
		ADCCS => ADCCS,
		ADCCONVST => ADCCONVST,
		PGARCK => PGARCK,
		PGASRCK => PGASRCK,
		PGASERA => PGASERA,
		ESI => ESI,
		ESCK => ESCK,
		ECS => ECS,
		ESO => ESO,
		EEPROMLEN => EEPROMLEN,
		FIBERIN => FIBERIN,
		FIBEROUT => FIBEROUT,
		RESET => RESET,
		CLK8_OUT => CLK8_OUT
	);

	pga : test_PGA port map (
		SCLK => pgasrck,
		RCLK => pgarck,
		SIN =>  pgasera,
		bouts => bouts); 


	cmdctl : test_SendCMD port map (
		CMDID => cmdid,
		CMD => cmd,
		DATA0 => cmddata0,
		DATA1 => cmddata1, 
		DATA2 => cmddata2,
		DATA3 => cmddata3,
		chksum => cmdchksum,
		SENDCMD => sendcmd,
		cmdpending => cmdpending,
		DOUT => FIBERIN); 


   rom : test_EEPROM port map (
		SCK => ESCK,
		SO => ESO,
		SI => ESI,
		CS => ECS,
		ADDR => eaddr,
		DIN => edin,
		DOUT => edout,
		we => ewe); 

	clkin <= not clkin after 15.625 ns;

	reset <= '0' after 100 ns;

	process (clkin) is
	begin
		if rising_edge(clkin)  then
			syscnt <= syscnt + 1; 
		end if; 
	end process;



	commands : process is
	begin
		wait until syscnt = 1000;
		
		-- null command for frame alignment

		cmdid <= "0000";
		cmd <= "0000"; 
		cmddata0 <= X"00"; 
		cmddata1 <= X"00";
		sendcmd <= '1'; 
		wait until rising_edge(clkin);
		sendcmd <= '0';  
		wait until cmdpending = '0';
	
		eaddr <= 
		wait until syscnt = 3000;
		
		cmdid <= "0011";
		cmd <= "0001"; 
		cmddata0 <= X"00"; 
		cmddata1 <= X"07";
		sendcmd <= '1'; 
		wait until rising_edge(clkin);
		sendcmd <= '0';  
		wait until cmdpending = '0';

			
	end process commands; 
		
	
END;
