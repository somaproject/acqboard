 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

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
   signal sdinl : std_logic_vector(4 downto 0) := (others => '0');
   signal convwait : integer range 0 to 150 := 0; 
   signal bitaddr: std_logic_vector(3 downto 0) := (others => '1');


   -- bit-serial adder signals
   signal inen, adden : std_logic := '0';
   signal douta, doutb : std_logic_vector(4 downto 0) := (others => '0');
   signal chan : std_logic_vector(3 downto 0) := (others => '0');
   signal  spen, inr : std_logic := '0';
   signal ina, inb , da, db: std_logic := '0';
   signal suma, sumb : std_logic := '0';
   signal cina, cinb, couta, coutb : std_logic := '0';
   signal osa, osb: std_logic := '0';
   signal pda, pdb : std_logic_vector(15 downto 0) := (others => '0');
   signal outsel, outsell : std_logic_vector(1 downto 0) := (others => '0');
   signal sclkcnt : std_logic_vector(4 downto 0) := (others => '0');
   signal od : std_logic_vector(9 downto 0) := (others => '0');
   
      
   -- output state machine
   type ostates is (none, oneinc, incbitaddr, extraadd, nop1,  nextchan1, nop2, nextchan2);
   signal ocs, ons : ostates := none;

   -- input state machine
   type istates is (none, conv_start, conv_wait, conv_done, sclkh0,
   				sclkl0, sclkl1, sclkh1,  sclkl2, sclkl3,
				sclkw0, sclkw1, sclkw2);
   signal ics, ins : istates := none;


   -- offset-related signals
   signal oswes, osin : std_logic := '0';
   signal oswen : std_logic_vector(9 downto 0) := (others => '0');
   signal osinbitsel : std_logic_vector(3 downto 0) := (others => '0');
   signal osdin : std_logic_vector(15 downto 0) := (others => '0');

   -- offset state machine
   type osstates  is (none, oswinc);
   signal oscs, osns : osstates := none; 



	component SRL16E
	  generic (
	       INIT : bit_vector := X"0000");
	  port (D   : in STD_logic;
	        CE  : in STD_logic;
	        CLK : in STD_logic;
	        A0  : in STD_logic;
	        A1  : in STD_logic;
	        A2  : in STD_logic;
	        A3  : in STD_logic;
	        Q   : out STD_logic); 
	end component;
begin

    -- generate statement to wire things up
    serial_input : for i in 0 to 4 generate
	   begin
		chanB_slr16e: SRL16E generic map (
			INIT => X"8000" )
			port map (
			D => sdinl(i),
			CE => inen,
			CLK => CLK,
			A0 => bitaddr(0),
			A1 => bitaddr(1),
			A2 => bitaddr(2),
			A3 => bitaddr(3),
			Q => doutb(i));
		chanA_slr16e: SRL16E  generic map (
			INIT => X"8000" )
			port map (
			D => doutb(i),
			CE => inen,
			CLK => CLK,
			A0 => bitaddr(0),
			A1 => bitaddr(1),
			A2 => bitaddr(2),
			A3 => bitaddr(3),
			Q => douta(i));

	   end generate; 

	-- Input: clock portion
	inclock: process(CLK, RESET) is 
	begin
	   if RESET = '1' then
	   	ics <= none;
 	   else
	   	if rising_edge(CLK) then
		    ics <= ins;

		    ADCCS <= ladccs;
		    CONVST <= lconvst;
		    SCLK <= lsclk; 
		    sdinl <= SDIN; 

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

	-- input : FSM
	infsm : process(ics, INSAMPLE, convwait, sclkcnt, bitaddr) is
	begin
		case ics is
			when none => 
				lconvst <= '1';
				ladccs <= '1';
				inen <= '0';
				lsclk <= '0';
				if INSAMPLE = '1' then
					ins <= conv_start; 	
				else 
					ins <= none;
				end if;
			when conv_start => 
				lconvst <= '0';
				ladccs <= '1';
				inen <= '0';
				lsclk <= '0';
				ins <= conv_wait;
			when conv_wait => 
				lconvst <= '1';
				ladccs <= '1';
				inen <= '0';
				lsclk <= '0';
				if convwait = 139 then
					ins <= conv_done; 	
				else 
					ins <= conv_wait;
				end if;
			when conv_done => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkh0;
			when sclkh0 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '1';
				ins <= sclkl0;
			when sclkl0 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkl1;
			when sclkl1 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkh1;
			when sclkh1 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '1';
				ins <= sclkl2;
			when sclkl2 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkl3;
			when sclkl3 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '1';
				lsclk <= '0';
				if sclkcnt = "11110" then
					ins <= sclkw0;
				else
					ins <= sclkh1;
				end if;
			when sclkw0 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkw1;
			when sclkw1 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '0';
				lsclk <= '0';
				ins <= sclkw2;
			when sclkw2 => 
				lconvst <= '1';
				ladccs <= '0';
				inen <= '1';
				lsclk <= '0';
				ins <= none;
			when others => 
				lconvst <= '1';
				ladccs <= '1';
				inen <= '0';
				lsclk <= '0';
				ins <= none;
		end case; 
	end process infsm; 

	-- Output calculation : clock portion
	outclock: process(CLK, reset) is 
	begin
	   if RESET = '1' then
	   	ocs <= none;
 	   else
	   	if rising_edge(CLK) then
		    ocs <= ons;

		    if adden = '1' then 
		    	  pda <= suma & pda(15 downto 1); 
			  pdb <= sumb & pdb(15 downto 1);
		    end if; 

		    -- output channel counter
		    if ocs = none then
		    	  chan <= (others => '0');	
		    else
		       if ocs = nextchan1 or ocs = nextchan2 then
			  	chan <= chan + 1;
			  end if;
              end if; 

		    outsell <= outsel; 

		    -- output bit counter
			       if ocs = incbitaddr or ocs = oneinc then
				  	 bitaddr <= bitaddr + 1;
	 			  end if; 
		    -- carry registers for bit-serial math
		    if inr = '1' then 	
		    	  cina <= '0';
			  cinb <= '0';
		    else
			  if adden = '1' then
			  	cina <= couta;
				cinb <= coutb;
			  end if;
		    end if; 	 

		end if;
	   end if;
	end process outclock; 

    -- Output : full adders 
	fulladders : process(ina, inb, osa, osb, cina, cinb, OSEN) is
		variable suma_temp, sumb_temp : std_logic; 
	begin
	   suma_temp := ina xor osa;
	   sumb_temp := inb xor osb;

	   if OSEN = '1' then 
	       suma <= suma_temp xor cina;
		  sumb <= sumb_temp xor cinb; 
	   else 
	   	  suma <= ina;
		  sumb <= inb; 
	   end if; 
	   couta <= (ina and osa) or (ina and cina) or (osa and cina); 
	   coutb <= (inb and osb) or (inb and cinb) or (osb and cinb); 


	end process fulladders;    
    			
    -- Output : general signals
	da <= douta(0) when chan(3 downto 1) = "000" else
		  douta(1) when chan(3 downto 1) = "001" else
		  douta(2) when chan(3 downto 1) = "010" else
		  douta(3) when chan(3 downto 1) = "011" else
		  douta(4); 
	db <= doutb(0) when chan(3 downto 1) = "000" else
		  doutb(1) when chan(3 downto 1) = "001" else
		  doutb(2) when chan(3 downto 1) = "010" else
		  doutb(3) when chan(3 downto 1) = "011" else
		  doutb(4);

	ina <= (not da) when bitaddr = "1111" else da;
	inb <= (not db) when bitaddr = "1111" else db; 

		   
	--Output : overflow calculatons
	outsel <= "00" when ((ina = not osa) or 
					 (ina = osa and ina = pda(15))) 	
					 and chan(0) = '0' else
 			"01" when ((inb = not osb) or 
					 (inb = osb and inb = pdb(15))) 	
					 and chan(0) = '1' else
			"10" when ((ina = '0' and osa = '0' and pda(15) = '1' 
						and chan(0) = '0') or
					 (inb = '0' and osb = '0' and pdb(15) = '1'
					 	and chan(0) = '1')) else
			"11" when ((ina = '1' and osa = '1' and pda(15) = '0'
						and chan(0) = '0') or
					 (inb = '1' and osb = '1' and pdb(15) = '0'
					 	and chan(0) = '1')) else

		     "00";
 
	DOUT <= pda when outsell = "00" else
		   pdb when outsell = "01" else
		   "0111111111111111" when outsell = "10" else
		   "1000000000000000" when outsell = "11"; 

	COUT <= chan; 

	-- Output : FSM
	outfsm : process(ocs, INSAMPLE, outsel, chan, bitaddr ) is
	begin
		case ocs is
			when none => 
				inr <= '1';
				WEOUT <= '0';
				adden <= '0';
				if INSAMPLE = '1' then
				   ons <= oneinc;
				else
					ons <= none; 
				end if;
			when oneinc => 
				inr <= '0';
				WEOUT <= '0';
				adden <= '0'; 
				ons <= incbitaddr;		
			when incbitaddr => 
				inr <= '0';
				WEOUT <= '0';
				adden <= '1'; 
				if bitaddr = "1110" then
				   ons <= extraadd;
				else
					ons <= incbitaddr; 
				end if;
			when extraadd => 
				inr <= '0';
				WEOUT <= '0';
				adden <= '1'; 
				ons <= nop1;
			when nop1 => 
				inr <= '0';
				WEOUT <= '0';
				adden <= '0'; 
				ons <= nextchan1;
			when nextchan1 => 
				inr <= '0';
				WEOUT <= '1';
				adden <= '0'; 
				ons <= nop2;
			when nop2 => 
				inr <= '0';
				WEOUT <= '0';
				adden <= '0'; 
				ons <= nextchan2;
			when nextchan2 => 
				inr <= '1';
				WEOUT <= '1';
				adden <= '0'; 
				if chan = "1001" then
				   ons <= none;
				else
					ons <= oneinc; 
				end if; 		 
			when others =>
				inr <= '0';
				WEOUT <= '0';
				adden <= '0';
		end case; 
	end process outfsm; 
	
	-- Offset : clock portion
	offsetclock: process(CLK, RESET, oscs) is 
	begin
	   if RESET = '1' then
	   	oscs <= none;
 	   else
	   	if rising_edge(CLK) then
		   oscs <= osns;

		   if oscs = none then
		   	osinbitsel <= (others => '1');
 		   elsif oscs = oswinc then
		   	osinbitsel <= osinbitsel - 1;
		   end if;

		end if;
	  end if;
	end process offsetclock;

	-- Offset : general signals
    offset_registers : for j in 0 to 9 generate
    	   signal ce: std_logic := '0'; 
	   begin
		osreg: SRL16E generic map (
			INIT => X"0000")
			port map (
			D => osin,
			CE => ce,
			CLK => CLK,
			A0 => bitaddr(0),
			A1 => bitaddr(1),
			A2 => bitaddr(2),
			A3 => bitaddr(3),
			Q => od(j));
		ce <= oswen(j) and oswes; 
	  end generate; 	   	

	oswen(0) <= '1' when osc = "0000" else '0';
	oswen(1) <= '1' when osc = "0001" else '0';
	oswen(2) <= '1' when osc = "0010" else '0';
	oswen(3) <= '1' when osc = "0011" else '0';
	oswen(4) <= '1' when osc = "0100" else '0';
	oswen(5) <= '1' when osc = "0101" else '0';
	oswen(6) <= '1' when osc = "0110" else '0';
	oswen(7) <= '1' when osc = "0111" else '0';
	oswen(8) <= '1' when osc = "1000" else '0';
	oswen(9) <= '1' when osc = "1001" else '0';



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

     osa <= od(0) when chan(3 downto 1) = "000" else
		  od(2) when chan(3 downto 1) = "001" else
		  od(4) when chan(3 downto 1) = "010" else
		  od(6) when chan(3 downto 1) = "011" else
		  od(8);
     osb <= od(1) when chan(3 downto 1) = "000" else
		  od(3) when chan(3 downto 1) = "001" else
		  od(5) when chan(3 downto 1) = "010" else
		  od(7) when chan(3 downto 1) = "011" else
		  od(9);

	-- Offset: FSM
	offsetfsm: process(oscs, insample, osinbitsel, oswe) is
	begin
		case oscs is
			when none =>
				oswes <= '0';
				if OSWE = '1' then
				   osns <= oswinc;
				else
				   osns <= none;
				end if;
			when oswinc =>
				oswes <= '1';
				if osinbitsel = "0000" then
					osns <= none;
				else
					osns <= oswinc;
				end if;
			when others =>
				oswes <= '0';
				osns <= none;
		end case;
	end process offsetfsm;
	
	 																																									
end Behavioral;
																														    						