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
		 OSRST : in std_logic; 
		 OSEN : in std_logic;
		 OSWE : in std_logic; 
		 OSD : in std_logic_vector(15 downto 0);
		 SDINDEBUG : out std_logic  
		  		);

end input;

architecture Behavioral of input is
-- INPUT.VHD : input from serial converter, also performs offset math. 

   -- ADC interface signals
   signal ladccs, lconvst, lsclk : std_logic := '0';
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
   signal oswes, osin, osinmux, osrstl : std_logic := '0';
   signal oswen : std_logic_vector(9 downto 0) := (others => '0');
   signal osinbitsel, oscl : std_logic_vector(3 downto 0) := (others => '0');
   signal osdl : std_logic_vector(15 downto 0) := (others => '0');

   -- offset state machine
   type osstates  is (none, oswinc);
   signal oscs, osns : osstates := none; 

   -- THIS IS DEBUGGING CODE!!!
   signal outbits1, outbits2, outbits3, outbits4, outbits5
   	 : std_logic_vector(31 downto 0) := (others => '0'); 
   signal d0, d1, d2, d3, d4, d5, d6, d7, d8, d9 :
   	std_logic_vector(15 downto 0) := (others => '0'); 


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

	-- Input: clock portion
	inclock: process(CLK, RESET) is 
	begin
	   if RESET = '1' then
	   	ics <= none;
 	   else
	   	if rising_edge(CLK) then
		    ics <= ins;

		    ADCCS <= ladccs;
		    CONVST <= not INSAMPLE;

		    if inen = '1' then
		    	  SDINDEBUG <= SDIN(0); 
		    end if;
		    
		     
		    if ics = conv_done then
		    	   sclkcnt <= (others => '0');
		    else
		       if ics = sclkl2 then
			     sclkcnt <= sclkcnt + 1;
 			  end if;
 		    end if; 


		    	if INSAMPLE = '1'  then 
		    		convwait <= 0;
			else
				if convwait /= 140 then
					convwait <= convwait + 1;
				end if;
			end if;
		    -- debugging!!!

		    if inen = '1' then
		    	outbits1 <= outbits1(30 downto 0) & SDIN(0); 
		    	outbits2 <= outbits2(30 downto 0) & SDIN(1); 
		    	outbits3 <= outbits3(30 downto 0) & SDIN(2); 
		    	outbits4 <= outbits4(30 downto 0) & SDIN(3); 
		    	outbits5 <= outbits5(30 downto 0) & SDIN(4); 
		    end if; 

		    d0 <= outbits1(15 downto 0) - 32768; 
		    d1 <= outbits1(31 downto 16) - 32768; 
		    d2 <= outbits2(15 downto 0) - 32768; 
		    d3 <= outbits2(31 downto 16) - 32768; 
		    d4 <= outbits3(15 downto 0) - 32768; 
		    d5 <= outbits3(31 downto 16) - 32768; 
		    d6 <= outbits4(15 downto 0) - 32768; 
		    d7 <= outbits4(31 downto 16) - 32768; 
		    d8 <= outbits5(15 downto 0) - 32768; 
		    d9 <= outbits5(31 downto 16) - 32768; 
		    	
		end if; 
	   end if;
	end process inclock; 

	dout <= d0 when convwait = 10 else
			d1 when convwait = 20 else
			d2 when convwait = 30 else
			d3 when convwait = 40 else
			d4 when convwait = 50 else
			d5 when convwait = 60 else
			d6 when convwait = 70 else
			d7 when convwait = 80 else
			d8 when convwait = 90 else
			d9;

	cout <= X"0" when convwait = 10 else
		   X"1" when convwait = 20 else
		   X"2" when convwait = 30 else
		   X"3" when convwait = 40 else
		   X"4" when convwait = 50 else
		   X"5" when convwait = 60 else
		   X"6" when convwait = 70 else
		   X"7" when convwait = 80 else
		   X"8" when convwait = 90 else
		   X"9";
	weout <= '1' when convwait =10 or convwait = 20 
	or convwait = 30 or convwait = 40 or convwait = 50
	or convwait =60 or convwait = 70 or convwait = 80 
	or convwait = 90 or convwait = 100 else '0'; 

		   	

	-- input : FSM
	infsm : process(ics, INSAMPLE, convwait, sclkcnt, bitaddr) is
	begin
		case ics is
			when none => 
				ladccs <= '1';
				inen <= '0';
				SCLK <= '0';
				if convwait = 123 then
					ins <= conv_wait; 	
				else 
					ins <= none;
				end if;
			when conv_wait => 
				ladccs <= '0';
				inen <= '0';
				SCLK <= '0';
				ins <= conv_done;
			when conv_done => 
				ladccs <= '0';
				inen <= '0';
				SCLK <= '0';
				ins <= sclkh0;
			when sclkh0 => 
				ladccs <= '0';
				inen <= '0';
				SCLK <= '1';
				ins <= sclkl0;
			when sclkl0 => 
				ladccs <= '0';
				inen <= '0';
				SCLK <= '0';
				ins <= sclkl1;
			when sclkl1 => 
				ladccs <= '0';
				inen <= '0';
				SCLK <= '0';
				ins <= sclkl2;
			when sclkl2 => 
				ladccs <= '0';
				inen <= '1';
				SCLK <= '0';
				if sclkcnt = "11111" then
					ins <= none;
				else
					ins <= sclkh0;
				end if;
			when others => 
				ladccs <= '1';
				inen <= '0';
				SCLK <= '0';
				ins <= none;
		end case; 
	end process infsm; 

	

	 																																									
end Behavioral;
																														    						