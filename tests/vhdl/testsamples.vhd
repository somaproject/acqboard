library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity testsamples is
    Port ( CLK : in std_logic;
	 		  KOUT : out std_logic;
			  --encodeddataout: out std_logic_vector(9 downto 0);
			  timerout: out std_logic;
			  CONVST: out std_logic;
			  DATAIN : in std_logic_vector(13 downto 0);
			  SAMP_OE: out std_logic; 
           DOUT : out std_logic);
end testsamples;

architecture Behavioral of testsamples is
-- samples the first channel ADC and sends the data over the fiber

	signal data, datacnt : std_logic_vector(7 downto 0) := "00000000";
	signal kin : std_logic := '0'; 

	signal timer: std_logic := '0';
	signal shift_timer: std_logic := '0';
		component encoder IS
			port (
			din: IN std_logic_VECTOR(7 downto 0);
			kin: IN std_logic;
			clk: IN std_logic;
			dout: OUT std_logic_VECTOR(9 downto 0);
			ce: IN std_logic);
		END component;				

	signal data_timer: std_logic_vector(4 downto 0) := "00000";
	signal encodeddata, encodeddata1, encodeddata2, outreg : std_logic_vector(9 downto 0);
	signal sample, convstl : std_logic := '0'; 
	signal samplecnt: integer range 4 downto 0 := 0; 
	type states is (none, sampconvst, wait_samp, OE, wait_oe, data_samp); 
	signal SAMPCS, SAMPNS : states := none; 

  	signal DATABUFFER : std_logic_vector(13 downto 0); 
begin

	encode: encoder port map (
		din => data,
		kin => kin,
		clk => clk,
		dout => encodeddata,
		ce => timer);
	dout <= outreg(0);
	
	KOUT <= KIN;
	--encodeddataout <= encodeddata;
	timerout <= timer; 
	timing: process(CLK, timer, convstl) is
		variable timecount: integer range 41 downto 0 := 0;
		 
		variable shiftcount : std_logic_vector(1 downto 0) := "00";
	begin
		if rising_edge(CLK) then
			if timecount = 39 then
				timecount := 0;
				timer <= '1'; 
			else
				timecount := timecount + 1;
				timer <= '0'; 
			end if;

			shiftcount := shiftcount + 1; 
			CONVST <= convstl; 
			if timer = '1' then
				if data_timer = "11000" then
					data_timer <= "00000";
				else
					data_timer <= data_timer + 1;
				end if;
			end if; 

			
				if timer = '1' then
					outreg <= encodeddata;
				else
					if shift_timer = '1'	 then
						outreg(8 downto 0) <= outreg(9 downto 1);
					end if; 
				end if; 

				if timer = '1' then
					if samplecnt = 4 then
						samplecnt <= 0;
						sample <= '1'; 
					else	
						samplecnt <= samplecnt +1;
						sample <= '0'; 
					end if;
				end if;
		end if; 
			if shiftcount = "00" then
				shift_timer <= '1';
			else
				shift_timer <= '0';
			end if; 		
							

		

	end process timing; 			
	output: process(CLK, data_timer, datacnt, samplecnt) is 
	begin
		if rising_edge(CLK) then
			if datacnt= "11101111" then
				datacnt <= "00000000";
			else
				if timer = '1' and  not (data_timer = "00000")  then
					datacnt <= datacnt + 1;
				end if;
			end if;

			if data_timer = "00000" then
				kin <= '1';
			else
				kin <= '0';
			end if; 

			if samplecnt = 0 then
				data <= "10111100";			-- wow, K28.5 instead of K28.7
			elsif samplecnt = 3 then
				data <= databuffer(7 downto 0);
			elsif samplecnt = 4 then
				data <= ("00" & databuffer(13 downto 8));
			end if; 
		end if; 
	end process output; 

   sampleclock: process(CLK, SAMPNS) is
	begin
		if rising_edge(CLK) then
			SAMPCS <= SAMPNS; --- !!!!!

			if SAMPNS = data_samp then
				DATABUFFER <= datain; 
			end if; 
		end if; 



	end process sampleclock; 


	sampleFSM: process(SAMPCS, TIMER, DATA, SAMPLE, SHIFT_TIMER) is
	begin
		case SAMPCS is
			when none =>
				if SAMPLE = '1' then
					SAMPNS <= sampconvst;
				else
					SAMPNS <= none;
				end if;
				CONVSTL <= '1';
				SAMP_OE <= '1';
			when sampconvst =>
				CONVSTL <= '0';
				SAMP_OE <= '1';
				SAMPNS <= wait_samp;
			when wait_samp =>
				CONVSTL <= '1';
				SAMP_OE <= '1'; 				
				if TIMER = '1' and SAMPLE = '0' then
					 SAMPNS <= OE; 
				else
					SAMPNS <=  wait_samp;
				end if;
			when OE =>
				CONVSTL <= '1';
				SAMP_OE <= '0'; 
				if SHIFT_TIMER = '1' then
					SAMPNS <= data_samp;
				else
					SAMPNS <= OE;
				end if; 
			when data_samp =>
				CONVSTL <= '1';
				SAMP_OE <= '0'; 				
		  		SAMPNS <= none;
			when others=>
				CONVSTL <= '1';
				SAMP_OE <= '1'; 				
		  		SAMPNS <= none;
		end case; 
	end process sampleFSM; 
end Behavioral;
