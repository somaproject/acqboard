
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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT input
	PORT(
		CLK : IN std_logic;
		INSAMPLE : IN std_logic;
		RESET : IN std_logic;
		SDIN : IN std_logic_vector(4 downto 0);
		OSC : IN std_logic_vector(3 downto 0);
		OSCALL : in std_logic; 
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
	SIGNAL CONVST :  std_logic;
	SIGNAL ADCCS :  std_logic;
	SIGNAL SCLK :  std_logic;
	SIGNAL SDIN :  std_logic_vector(4 downto 0);
	SIGNAL DOUT :  std_logic_vector(15 downto 0);
	SIGNAL COUT :  std_logic_vector(3 downto 0);
	SIGNAL WEOUT :  std_logic;
	SIGNAL OSC :  std_logic_vector(3 downto 0);
	SIGNAL OSEN :  std_logic;
	SIGNAL OSWE :  std_logic;
	SIGNAL OSD :  std_logic_vector(15 downto 0);
	signal OSCALL : std_logic; 

	component test_ADC is
	    Generic (filename : string := "adcin.dat" ); 
	    Port ( RESET : in std_logic;
	           SCLK : in std_logic := '0';
	           CONVST : in std_logic;
	           CS : in std_logic;
	           SDOUT : out std_logic;
			 	CHA_VALUE: in integer;
			 	CHB_VALUE: in integer;
				CHA_OUT : out integer;
				CHB_OUT : out integer; 
			 	FILEMODE: in std_logic; 
			 	BUSY: out std_logic; 
			 	INPUTDONE: out std_logic);
	end component;

	signal adcbusy, adcinputdone : std_logic_vector(4 downto 0)
		:= (others => '0');
	signal adcreset : std_logic := '1';	
	type intarray is array (9 downto 0) of integer; 	 
	signal syscnt, chan : integer := 0;
	
	signal ch_out, ch_outbipolar, ch_outbipolarl, offsets : intarray := (others => 0); 
	signal error : std_logic := '0'; 
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
		OSCALL => OSCALL, 
		OSEN => OSEN,
		OSWE => OSWE,
		OSD => OSD
	);	 

	adc0 : test_ADC generic map (
		filename => "adc.0.dat")
		port map(
		RESET => adcreset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(0),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => ch_out(0),
		CHB_OUT => ch_out(1),
		FILEMODE => '1',
		BUSY => adcbusy(0),
		INPUTDONE => adcinputdone(0));

	adc1 : test_ADC generic map (
		filename => "adc.1.dat")
		port map(
		RESET => adcreset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(1),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => ch_out(2),
		CHB_OUT => ch_out(3),
		FILEMODE => '1',
		BUSY => adcbusy(1),
		INPUTDONE => adcinputdone(1));


	adc2 : test_ADC generic map (
		filename => "adc.2.dat")
		port map(
		RESET => adcreset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(2),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => ch_out(4),
		CHB_OUT => ch_out(5),
		FILEMODE => '1',
		BUSY => adcbusy(2),
		INPUTDONE => adcinputdone(2));

	adc3 : test_ADC generic map (
		filename => "adc.3.dat")
		port map(
		RESET => adcreset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(3),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => ch_out(6),
		CHB_OUT => ch_out(7),
		FILEMODE => '1',
		BUSY => adcbusy(3),
		INPUTDONE => adcinputdone(3));

	adc4 : test_ADC generic map (
		filename => "adc.4.dat")
		port map(
		RESET => adcreset,
		SCLK => SCLK,
		CONVST => CONVST,
		CS => ADCCS,
		SDOUT => SDIN(4),
		CHA_VALUE => 0,
		CHB_VALUE => 0,
		CHA_OUT => ch_out(8),
		CHB_OUT => ch_out(9),
		FILEMODE => '1',
		BUSY => adcbusy(4),
		INPUTDONE => adcinputdone(4));


	process (ch_out) is
	begin
 		for i in 0 to 9 loop
			ch_outbipolar(i) <= ch_out(i) - 32768; 
		end loop; 
	end process; 

	sdin <= (others => 'L'); 

  	reset <= '0' after 100 ns;
	clk <= not clk after 7.8125 ns;

	counter: process(clk) is
	begin
		if rising_edge(clk) then
			syscnt <= syscnt + 1;
	
		end if;
	end process counter; 


   -- main testbench code:
	testbench: process is
	begin

		 -- normal operation

		 wait until rising_edge(clk) and syscnt = 100; 
		 adcreset <= '0'; 
		 wait until rising_edge(clk) and syscnt = 1000; 
		 while adcinputdone(0) = '0' loop
		 	wait until rising_edge(clk);
			INSAMPLE <= '1';
			
			for j in 0 to 9 loop
				ch_outbipolarl(j) <= ch_outbipolar(j);
			end loop; 
			wait until rising_edge(clk);
			INSAMPLE <= '0';
			for j in 0 to 247 loop
				wait until rising_edge(clk);

			end loop;
		end loop; 

		-- set, load offsets
		offsets(0) <= -1;
		offsets(1) <= 1;
		offsets(2) <= 0;
		offsets(3) <= 100;
		offsets(4) <= -100;
		offsets(5) <= -32768; 
		offsets(6) <= 32767; 
		offsets(7) <= 00;
		offsets(8) <= 10088;
		offsets(9) <= -15678;
		
		-- write them 
		for i in 0 to 9 loop
		  wait until rising_edge(clk);
		  osc <= std_logic_vector(TO_UNSIGNED(i, 4));
		  osd <= std_logic_vector(TO_SIGNED(offsets(i), 16)); 
		  wait until rising_edge(clk);
		  oswe <= '1';
		  wait until rising_edge(clk); 
		  oswe <= '0';

		  for j in 0 to 32 loop wait until rising_edge(clk); end loop;

		end loop; 
		
	  wait until rising_edge(clk); 
	  osen <= '1';

	  adcreset <= '1'; 

 	  -- test with this
		 for j in 0 to 100 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 adcreset <= '0'; 
		 for j in 0 to 400 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 while adcinputdone(0) = '0' loop
		 	wait until rising_edge(clk);
			INSAMPLE <= '1';
																				  
			for j in 0 to 9 loop
				ch_outbipolarl(j) <= ch_outbipolar(j);
			end loop; 
			wait until rising_edge(clk);
			INSAMPLE <= '0';
			for j in 0 to 247 loop
				wait until rising_edge(clk);

			end loop;
		end loop; 

	  osen <= '0';
	  
	  wait until rising_edge(clk);
	  adcreset <= '1'; 
	  offsets <= (others => 0); 
	  -- now, test with offsets disabled
		 for j in 0 to 100 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 adcreset <= '0'; 
		 for j in 0 to 400 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 while adcinputdone(0) = '0' loop
		 	wait until rising_edge(clk);
			INSAMPLE <= '1';
																				  
			for j in 0 to 9 loop
				ch_outbipolarl(j) <= ch_outbipolar(j);
			end loop; 
			wait until rising_edge(clk);
			INSAMPLE <= '0';
			for j in 0 to 247 loop
				wait until rising_edge(clk);

			end loop;
		end loop; 

	 
	  adcreset <= '1'; 
	  
 	  
	  oscall <= '1';
	  osd <= X"0000";
	  oswe <= '1';
	  wait until rising_edge(clk);
	  oswe <= '0'; 
	  
 	  -- now, test after resetting offsets
	   osen <= '1'; 
		 for j in 0 to 100 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 adcreset <= '0'; 
		 for j in 0 to 400 loop 
		 wait until rising_edge(clk); 
		 end loop;

		 while adcinputdone(0) = '0' loop
		 	wait until rising_edge(clk);
			INSAMPLE <= '1';
																				  
			for j in 0 to 9 loop
				ch_outbipolarl(j) <= ch_outbipolar(j);
			end loop; 
			wait until rising_edge(clk);
			INSAMPLE <= '0';
			for j in 0 to 247 loop
				wait until rising_edge(clk);

			end loop;
		end loop; 
	  		  
		
		 
	end process testbench; 	

	verify: process(clk, COUT) is 
		--variable chan : integer := 0; 
	begin
		chan <= to_integer(unsigned(cout)); 

		if rising_edge(clk) then
			if WEOUT = '1' then	
				if osen = '1' then 
					if (ch_outbipolarl(chan) + offsets(chan)) > 32767 then
						if to_integer(signed(dout)) /= 32767 then
							error <= '1';
						else
							error <= '0';
						end if; 
					elsif  (ch_outbipolarl(chan) + offsets(chan)) < -32768 then
						if to_integer(signed(dout)) /= -32768 then
							error <= '1';
						else
							error <= '0';
						end if; 
					else 
						if to_integer(signed(dout)) /= 
							(ch_outbipolarl(chan) + offsets(chan)) then
							error <= '1';
						else
							error <= '0';
						end if; 
					end if;  
				else
					if to_integer(signed(dout)) /=  ch_outbipolarl(chan)  then
						error <= '1';
					else
						error <= '0';
					end if; 
				end if; 
			end if;
		end if; 
	end process verify; 

END;
