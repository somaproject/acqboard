
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 


ENTITY input_testbench IS
END input_testbench;

ARCHITECTURE behavior OF input_testbench IS 

	COMPONENT input
	PORT(
		clk : IN std_logic;
		insample : IN std_logic;
		reset : IN std_logic;
		sdin : IN std_logic_vector(4 downto 0);
		osc : IN std_logic_vector(3 downto 0);
		osen : IN std_logic;
		oswe : IN std_logic;
		osd : IN std_logic_vector(15 downto 0);          
		convst : OUT std_logic;
		adccs : OUT std_logic;
		sclk : OUT std_logic;
		dout : OUT std_logic_vector(15 downto 0);
		cout : OUT std_logic_vector(3 downto 0);
		weout : OUT std_logic
		);
	END COMPONENT;

	component test_ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic;
	           CONVST : in std_logic;
	           CS : in std_logic;		 
			 CHA_VALUE: in integer;
		 	 CHB_VALUE: in integer;
		 	 FILEMODE: in std_logic; 
	           SDOUT : out std_logic;
			 BUSY: out std_logic; 
			 INPUTDONE: out std_logic);
	end component;
	SIGNAL clk :  std_logic := '0';
	SIGNAL insample :  std_logic;
	SIGNAL reset :  std_logic := '1';
	SIGNAL convst :  std_logic;
	SIGNAL adccs :  std_logic;
	SIGNAL sclk :  std_logic;
	SIGNAL sdin :  std_logic_vector(4 downto 0) := (others => '0');
	SIGNAL dout :  std_logic_vector(15 downto 0);
	SIGNAL cout :  std_logic_vector(3 downto 0);
	SIGNAL weout :  std_logic;
	SIGNAL osc :  std_logic_vector(3 downto 0);
	SIGNAL osen :  std_logic := '1';
	SIGNAL oswe :  std_logic;
	SIGNAL osd :  std_logic_vector(15 downto 0);

	SIGNAL busy : std_logic_vector(4 downto 0) := (others => '0');
	SIGNAL inputdone : std_logic_vector(4 downto 0) := (others => '0');
     type outputvalues is array (0 to 9) of integer; 
	signal outvals: outputvalues; 
	signal cha_value, chb_value : integer := 0;

BEGIN

	uut: input PORT MAP(
		clk => clk,
		insample => insample,
		reset => reset,
		convst => convst,
		adccs => adccs,
		sclk => sclk,
		sdin => sdin,
		dout => dout,
		cout => cout,
		weout => weout,
		osc => osc,
		osen => osen,
		oswe => oswe,
		osd => osd
	);
	
	SDIN <= "HHHHH";
	input_ADCS : for i in 0 to 4 generate
		begin
		 	adc_in: test_ADC generic map (
				filename => "adcin.dat")
				
			port map(
				RESET => reset,
				sclk => sclk,
				CONVST => convst,
				CS => adccs,
				SDOUT => sdin(i),
				BUSY	=> busy(i),
				CHA_VALUE => cha_value,
				CHB_VALUE => chb_value,
				filemode => '0',
				INPUTDONE => inputdone(i));
		end generate; 

 clk <= not clk after 15.625 ns / 2; 
    reset <= '0' after 45 ns; 




-- *** Test Bench - User Defined Section ***
   tb : PROCESS(CLK) is
   	variable clockcnt: integer := 0;  
   BEGIN
     if rising_edge(CLK) then
	   clockcnt := clockcnt + 1;

	   if clockcnt mod 250 = 0 then
	   	insample <= '1' after 1 ns;
 	   else
	   	insample <= '0' after 1 ns; 
	   end if; 

	end if; 
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

  -- input control 
  process(CLK, INSAMPLE) is
  begin
  	if rising_edge(CLK) then
	    if insample = '1' then
		  cha_value <= cha_value + 1;
		  chb_value <= chb_value + 1;
	    end if;
	end if; 
  end process; 

  -- output process
  output_proc: process(CLK, cout, WEOUT, DOUT) is
	variable intoutvals: outputvalues;
	variable signedval : ieee.numeric_std.signed(15 downto 0);  
  begin
  	if rising_edge(CLK) then
		if weout = '1' then 
		 
		  intoutvals(to_integer(unsigned(cout))) := to_integer(SIGNED(DOUT));
		end if; 
		if insample = '1' then
			outvals <= intoutvals;
		end if; 
	end if; 
  end process output_proc;
  
  -- offset write test
  oswrite: process(CLK) is
  	variable counter: integer :=0;
  begin
  	if rising_edge(CLK) then
		counter := counter + 1;

		if counter = 2000 then 
			OSWE <= '1';
			OSD <= "0111111111111111";
			OSC <= "0000";
		elsif counter = 2600 then
			OSWE <= '1';
			OSD <= "1000000000000000";
			OSC <= "0001";
		else
			OSWE <= '0';
		end if; 
	end if; 
  end process oswrite; 
   
END;
