library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input is
    Port ( CLK : in std_logic;				   
           INSAMPLE : in std_logic;
		 RESET : in std_logic; 
           CONVST : out std_logic;
           ADCCS : out std_logic;
           SCLK : out std_logic;
           SDIN : in std_logic_vector(4 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           COUT : out std_logic_vector(3 downto 0);
           WEOUT : out std_logic;
		 OSC : in std_logic_vector(3 downto 0);
		 OSEN : in std_logic;
		 OSWE : in std_logic; 
		 OSD : in std_logic_vector(15 downto 0)
		 );

end input;

architecture Behavioral of input is
-- INPUT.VHD : input from serial converter, also performs offset math. 

   -- ADC interface signals
   signal ladccs, lconvst, lsclk : std_logic := '0';
   signal lsdin : std_logic_vector(4 downto 0) := (others => '0');
   signal convwait : integer range 0 to 150 := 0; 

   -- bit-serial adder signals
   signal inena, inenb : std_logic := '0';
   signal douta, doutb : std_logic_vector(4 downto 0) := (others => '0');
   signal chan : std_logic_vector(3 downto 0) := (others => '0');
   signal sda, sdb, spen, inr : std_logic := '0';
   signal pda, pdb : std_logic_vector(15 downto 0) := (others => '0');
   signal outsel : std_logic_vector(3 downto 0) := (others => '0');
   signal shiften : std_logic := '0';
   signal sclkcnt : std_logic_vector(4 downto 0) := (others => '0');
      
   -- output state machine
   type ostates is (none, incoutsel, nextchan1, nextchan2);
   signal ocs, ons : ostates := none;

   -- input state machine
   type istates is (none, conv_start, conv_wait, conv_done, sclkh0,
   				sclkl0, sclkl1, sclkh1,  sclkl2, sclkl3,
				sclkw0, sclkw1, sclkw2);
   signal ics, ins : istates := none;


   -- offset-related signals
   signal oswen, osin : std_logic := '0';
   signal oswena, oswenb : std_logic_vector(4 downto 0) := (others => '0');
   signal osasel : std_logic_vector(3 downto 0) := (others => '0');
   signal osinbitsel : std_logic_vector(3 downto 0) := (others => '0');

   -- offset state machine
   type osstates  is (none, oswinc);
   signal oscs, osns : osstates := none; 

	component bitserial is
	    Port ( CLK : in std_logic;
	           DIN : in std_logic;
	           OSIN : in std_logic;
	           OSASEL : in std_logic_vector(3 downto 0);
	           OSWEN : in std_logic;
			 OSEN : in std_logic; 
	           INR : in std_logic;
	           INEN : in std_logic;
	           OUTSEL : in std_logic_vector(3 downto 0);
	           DOUT : out std_logic);
	end component;


begin

    -- generate statement to wire things up
    bit_serial_input : for i in 0 to 4 generate
		   signal osasela, osaselb : std_logic := '0';
	   begin
	 		adder_A : bitserial port map (
			   		CLK => clk,
					DIN => lsdin(i),
					OSIN => osin,
					OSASEL => osasel,
					OSWEN => osasela,
					OSEN => OSEN,
					INR => inr,
					INEN => inena,
					OUTSEL => outsel,
					DOUT => douta(i));
	 		adder_B : bitserial port map (
			   		CLK => clk,
					DIN => lsdin(i),
					OSIN => osin,
					OSASEL => osasel,
					OSWEN => osaselb,
					OSEN => OSEN,
					INR => inr,
					INEN => inenb,
					OUTSEL => outsel,
					DOUT => doutb(i));
			osasela <= '1' when oswen = '1' and oswena(i) = '1' else '0';
			osaselb <= '1' when oswen = '1' and oswenb(i) = '1' else '0';
	   end generate; 

	-- Input: clock portion
	inclock: process(CLK) is 
	begin
	   if RESET = '1' then
	   	ics <= none;
 	   else
	   	if rising_edge(CLK) then
		    ics <= ins;

		    ADCCS <= ladccs;
		    CONVST <= lconvst;
		    SCLK <= lsclk; 
		    LSDIN <= SDIN; 

		    if ics = sclkh0 then
		    	   sclkcnt <= (others => '0');
		    else
		       if ics = sclkl3 then
			     sclkcnt <= sclkcnt + 1;
 			  end if;
 		    end if; 

		    	if ics = conv_start  then 
		    		convwait <= 0;
			else
				if ics = conv_wait then
					convwait <= convwait + 1;
				end if;
			end if;
			 

		
		end if; 
	   end if;
	end process inclock; 

     -- input : general signals
	inena <= '1' when shiften = '1' and sclkcnt(4) = '0' else '0';
	inenb <= '1' when shiften = '1' and sclkcnt(4) = '1' else '0'; 
	osasel <= sclkcnt(3 downto 0); 

	-- input : FSM
	infsm : process(ics, INSAMPLE, convwait, sclkcnt) is
	begin
		case ics is
			when none => 
				lconvst <= '1';
				ladccs <= '1';
				shiften <= '0';
				lsclk <= '0';
				if INSAMPLE = '1' then
					ins <= conv_start; 	
				else 
					ins <= none;
				end if;
			when conv_start => 
				lconvst <= '0';
				ladccs <= '1';
				shiften <= '0';
				lsclk <= '0';
				ins <= conv_wait;
			when conv_wait => 
				lconvst <= '1';
				ladccs <= '1';
				shiften <= '0';
				lsclk <= '0';
				if convwait = 139 then
					ins <= conv_done; 	
				else 
					ins <= conv_wait;
				end if;
			when conv_done => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkh0;
			when sclkh0 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '1';
				ins <= sclkl0;
			when sclkl0 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkl1;
			when sclkl1 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkh1;
			when sclkh1 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '1';
				ins <= sclkl2;
			when sclkl2 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkl3;
			when sclkl3 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '1';
				lsclk <= '0';
				if sclkcnt = "11110" then
					ins <= sclkw0;
				else
					ins <= sclkh1;
				end if;
			when sclkw0 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkw1;
			when sclkw1 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '0';
				lsclk <= '0';
				ins <= sclkw2;
			when sclkw2 => 
				lconvst <= '1';
				ladccs <= '0';
				shiften <= '1';
				lsclk <= '0';
				ins <= none;
			when others => 
				lconvst <= '1';
				ladccs <= '1';
				shiften <= '0';
				lsclk <= '0';
				ins <= none;
		end case; 
	end process infsm; 

	-- Output : clock portion
	outclock: process(CLK) is 
	begin
	   if RESET = '1' then
	   	ocs <= none;
 	   else
	   	if rising_edge(CLK) then
		    ocs <= ons;

		    if spen = '1' then 
		    	  pda <= sda & pda(15 downto 1); 
			  pdb <= sdb & pdb(15 downto 1);
		    end if; 

		    -- output channel counter
		    if ocs = none then
		    	  chan <= (others => '0');	
		    else
		       if ocs = nextchan1 or ocs = nextchan2 then
			  	chan <= chan + 1;
			  end if;
              end if; 


		    -- output bit counter
		    if ocs = none then
		    	  outsel <= (others => '0');
		    else
		       if ocs = incoutsel then
			  	 outsel <= outsel + 1;
 			  end if;
		    end if; 


		end if;
	   end if;
	end process outclock; 

			
    -- Output : general signals
	sda <= douta(0) when chan(3 downto 1) = "000" else
		  douta(1) when chan(3 downto 1) = "001" else
		  douta(2) when chan(3 downto 1) = "010" else
		  douta(3) when chan(3 downto 1) = "011" else
		  douta(4); 
	sdb <= doutb(0) when chan(3 downto 1) = "000" else
		  doutb(1) when chan(3 downto 1) = "001" else
		  doutb(2) when chan(3 downto 1) = "010" else
		  doutb(3) when chan(3 downto 1) = "011" else
		  doutb(4); 

	DOUT <= PDA when chan(0) = '0' else PDB; 

	COUT <= chan; 

	-- Output : FSM
	outfsm : process(ocs, INSAMPLE, outsel, chan ) is
	begin
		case ocs is
			when none => 
				inr <= '1';
				WEOUT <= '0';
				spen <= '0';
				if INSAMPLE = '1' then
				   ons <= incoutsel;
				else
					ons <= none; 
				end if; 
			when incoutsel => 
				inr <= '0';
				WEOUT <= '0';
				spen <= '1'; 
				if outsel = "11111" then
				   ons <= nextchan1;
				else
					ons <= incoutsel; 
				end if; 
			when nextchan1 => 
				inr <= '0';
				WEOUT <= '1';
				spen <= '0'; 
				ons <= nextchan2;
			when nextchan2 => 
				inr <= '0';
				WEOUT <= '1';
				spen <= '0'; 
				if chan = "1001" then
				   ons <= none;
				else
					ons <= incoutsel; 
				end if; 		 
			when others =>
				inr <= '1';
				WEOUT <= '0';
				spen <= '0';
		end case; 
	end process outfsm; 
	
	-- Offset : clock portion
	offsetclock: process(CLK) is 
	begin
	   if RESET = '1' then
	   	oscs <= none;
 	   else
	   	if rising_edge(CLK) then
		   oscs <= osns;

		   if oscs = none then
		   	osinbitsel <= (others => '0');
 		   elsif oscs = oswinc then
		   	osinbitsel <= osinbitsel + 1;
		   end if;

		end if;
	  end if;
	end process offsetclock;

	-- Offset : general signals
	osin <= osd(0) when osinbitsel = "0000" else
		   osd(1) when osinbitsel = "0001" else
		   osd(2) when osinbitsel = "0010" else
		   osd(3) when osinbitsel = "0011" else
		   osd(4) when osinbitsel = "0100" else
		   osd(5) when osinbitsel = "0101" else
		   osd(6) when osinbitsel = "0110" else
		   osd(7) when osinbitsel = "0111" else
		   osd(8) when osinbitsel = "1000" else
		   osd(9) when osinbitsel = "1001" else
		   osd(10) when osinbitsel = "1010" else
		   osd(11) when osinbitsel = "1011" else
		   osd(12) when osinbitsel = "1100" else
		   osd(13) when osinbitsel = "1101" else
		   osd(14) when osinbitsel = "1110" else
		   osd(15);

	oswena(0) <= '1' when osc = "0000" else '0';
	oswena(1) <= '1' when osc = "0010" else '0';
	oswena(2) <= '1' when osc = "0100" else '0';
	oswena(3) <= '1' when osc = "0110" else '0';
	oswena(4) <= '1' when osc = "1000" else '0';
	oswenb(0) <= '1' when osc = "0001" else '0';
	oswenb(1) <= '1' when osc = "0011" else '0';
	oswenb(2) <= '1' when osc = "0101" else '0';
	oswenb(3) <= '1' when osc = "0111" else '0';
	oswenb(4) <= '1' when osc = "1001" else '0';

	
	-- Offset: FSM
	offsetfsm: process(oscs, insample, osinbitsel) is
	begin
		case oscs is
			when none =>
				oswen <= '0';
				if OSWE = '1' then
				   osns <= oswinc;
				else
				   osns <= none;
				end if;
			when oswinc =>
				oswen <= '1';
				if osinbitsel = "1111" then
					osns <= none;
				else
					osns <= oswinc;
				end if;
			when others =>
				oswen <= '0';
				osns <= none;
		end case;
	end process offsetfsm;
	
	 																																									
end Behavioral;
																														    						