
-- VHDL Test Bench Created from source file input.vhd -- 12:34:13 04/04/2004
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

ENTITY rawsystemtest IS
END rawsystemtest;

ARCHITECTURE behavior OF rawsystemtest IS 

	COMPONENT input
	PORT(
		CLK : IN std_logic;
		INSAMPLE : IN std_logic;
		RESET : IN std_logic;
		SDIN : IN std_logic_vector(4 downto 0);
		OSC : IN std_logic_vector(3 downto 0);
		OSRST : in std_logic; 
		OSEN : IN std_logic;
		OSWE : IN std_logic;
		OSD : IN std_logic_vector(15 downto 0);          
		CONVST : OUT std_logic;
		ADCCS : OUT std_logic;
		SCLK : OUT std_logic;
		DOUT : OUT std_logic_vector(15 downto 0);
		COUT : OUT std_logic_vector(3 downto 0);
		WEOUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL INSAMPLE :  std_logic := '0';
	SIGNAL RESET :  std_logic := '1';
	SIGNAL CONVST :  std_logic := '0';
	SIGNAL ADCCS :  std_logic := '0';
	SIGNAL SCLK :  std_logic := '0';
	SIGNAL SDIN :  std_logic_vector(4 downto 0) := (others => '0');
	SIGNAL DOUT :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL COUT :  std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL WEOUT :  std_logic := '0';
	SIGNAL OSC :  std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL OSEN :  std_logic := '0';
	SIGNAL OSWE :  std_logic := '0';
	SIGNAL OSD :  std_logic_vector(15 downto 0) := (others => '0');
	signal OSCALL : std_logic := '0'; 
	signal err : std_logic := '0';
	component ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic := '0';
	           CONVST : in std_logic;
	           CS : in std_logic;
	           SDOUT : out std_logic;
			 	CHA_VALUE: in integer;
			 	CHB_VALUE: in integer;
				CHA_OUT : out integer := 32768;
				CHB_OUT : out integer := 32768; 
			 	FILEMODE: in std_logic; 
			 	BUSY: out std_logic; 
			 	INPUTDONE: out std_logic);
	end component;

	signal adcbusy, adcinputdone : std_logic_vector(4 downto 0)
		:= (others => '0');
	signal adcreset : std_logic := '1';	
	type intarray is array (9 downto 0) of integer;
	signal chan_in, chan_inl,
	 chan_out, offsets : intarray := (others => 0); 
	


BEGIN

	uut: input PORT MAP(
		CLK => CLK,
		INSAMPLE => INSAMPLE,
		RESET => RESET,
		CONVST => CONVST,
		ADCCS => ADCCS,
		SCLK => SCLK,
		SDIN => SDIN,
		DOUT => DOUT,
		COUT => COUT,
		WEOUT => WEOUT,
		OSC => OSC,
		OSRST => OSCALL, 
		OSEN => OSEN,
		OSWE => OSWE,
		OSD => OSD
	);	 


 	reset <= '0' after 100 ns;
	clk <= not clk after 7.8125 ns;

	adcs: for i in 0 to 4 generate
		ADCi : ADC generic map 
			(filename => "adc." & integer'image(i) & ".dat")
			port map (
			RESET => adcreset,
			SCLK => SCLK,
			CONVST => CONVST,
			CS => ADCCS,
			SDOUT => SDIN(i),
			CHA_VALUE => 0,
			CHB_VALUE => 0,
			CHA_OUT => chan_in(2*i),
			CHB_OUT => chan_in(2*i+1),
			FILEMODE => '1',
			BUSY => adcbusy(i),
			inputdone => adcinputdone(i)); 
	end generate; 
	

	clock: process(clk) is
		variable cnt : integer := 0; 

	begin
		if rising_edge(clk) then
			if cnt = 250 then
				INSAMPLE <= '1';
				cnt := 0; 
				chan_inl <= chan_in; 
			else
				INSAMPLE <= '0';
				cnt := cnt + 1; 
			end if; 
		end if; 
	end process;
	
	
	offsets(0) <= 127;
	offsets(1) <= 0; 
	offsets(2) <= 19755;
	offsets(3) <= 0;
	offsets(4) <= 0;
	offsets(5) <= -1;
	offsets(6) <= -128;
	offsets(7) <= -15715;
	offsets(8) <= 0;
	offsets(9) <= 0; 


	sequencer: process is
	begin
		wait for 100 ns; 
		-- write some offsets:
		for i in 0 to 9 loop 
			OSC <= std_logic_vector(TO_UNSIGNED(i, OSC'Length));
			OSD <= std_logic_vector(TO_SIGNED(offsets(i), 16)); 
			OSWE <= '1';
			wait until rising_edge(CLK);
			OSWE <= '0';
			wait until rising_edge(CLK); 


		end loop; 
		wait for 20 ns; 
		adcreset <= '0';
		wait until adcinputdone(0) = '1';
		adcreset <= '1';
		OSEN <= '1';
		wait until rising_edge(clk);
		adcreset <= '0';
		wait until adcinputdone(0) = '1';
		assert false
			report "End of simulation"
			severity failure; 

	end process;
	
	channelreader: process(clk) is
	begin
		if rising_edge(clk) then
			if WEOUT = '1' then
				chan_out(TO_INTEGER(UNSIGNED(COUT)))
					 <= TO_INTEGER(SIGNED(DOUT));
			end if; 
				
		end if;
	end process channelreader; 


	channelverify: process(WEOUT, adcreset) is
		variable firstread : integer := 3; 
		variable tempresult: integer; 
	begin
		if adcreset = '1' then
			firstread := 3;
		else
			if falling_edge(WEOUT) then
				if firstread >0 then
					firstread := firstread - 1;
				else
					if osen = '0' then
						for i in 0 to 9 loop

						assert chan_out(i) = (chan_inl(i) -32768) 
							report "Incorrect output in chan " & integer'image(i)
							severity error;
						end loop; 

					else 
						for i in 0 to 9 loop
						 	tempresult := (chan_inl(i) -32768) + offsets(i);
							if tempresult < -32768 then
								tempresult := -32768;
							elsif tempresult > 32767 then
								tempresult := 32767;
							end if;
							assert chan_out(i) = tempresult 
								report "Incorrect output in chan " & integer'image(i)
								severity error;
						end loop; 
					end if;
						
				end if; 
			end if; 
		end if; 


	end process; 
END;
