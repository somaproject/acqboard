library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity AES3 is
    Port ( CLKIN : in std_logic;
           SDIN : in std_logic_vector(4 downto 0);		 
           CONVST : out std_logic;
           ADCCS : out std_logic;
           SCLK : out std_logic;
           FIBEROUT : out std_logic;
		 CLKENOUT : out std_logic;
		 BITENOUT : out std_logic; 
		 SAMPLEOUT : out std_logic;
		 BITOUT : out std_logic;
		 CLKOUT : out std_logic);
end AES3;

architecture Behavioral of AES3 is
-- clock is 38.4 MHz
-- input clock is 32 Mhz. 

	component DCM
	--
	    generic ( 
	             DFS_FREQUENCY_MODE : string := "LOW";
	             CLKFX_DIVIDE : integer := 1;
			   CLKFX_MULTIPLY : integer := 4 ;
			   STARTUP_WAIT : boolean := False;
	             CLK_FEEDBACK : string := "NONE" 
	            );  
	--
	    port ( CLKIN     : in  std_logic;
	           CLKFB     : in  std_logic;
	           DSSEN     : in  std_logic;
	           PSINCDEC  : in  std_logic;
	           PSEN      : in  std_logic;
	           PSCLK     : in  std_logic;
	           RST       : in  std_logic;
	           CLK0      : out std_logic;
	           CLK90     : out std_logic;
	           CLK180    : out std_logic;
	           CLK270    : out std_logic;
	           CLK2X     : out std_logic;
	           CLK2X180  : out std_logic;
	           CLKDV     : out std_logic;
	           CLKFX     : out std_logic;
	           CLKFX180  : out std_logic;
	           LOCKED    : out std_logic;
	           PSDONE    : out std_logic;
	           STATUS    : out std_logic_vector(7 downto 0)
	          );
	end component;

	component input is
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
			 OSD : in std_logic_vector(15 downto 0)
			 );

	end component;

	component bitencode is
	    Port ( CLK : in std_logic;
	    		 RESET : in std_logic; 
	           EN : in std_logic;
	           BITEN : in std_logic;
			 DIN : in std_logic; 
	           PRED : in std_logic_vector(1 downto 0);
	           DOUT : out std_logic);
	end component;

    component TOC 
        port (O : out std_logic); 
    end component; 
	component RAMB16_S18
	--
	  generic (
	       WRITE_MODE : string := "WRITE_FIRST";
	       INIT  : bit_vector  := X"00000";
	       SRVAL : bit_vector  := X"00000";
	       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );
	--
	  port (DI     : in STD_LOGIC_VECTOR (15 downto 0);
	        DIP    : in STD_LOGIC_VECTOR (1 downto 0);
	        EN     : in STD_logic;
	        WE     : in STD_logic;
	        SSR    : in STD_logic;
	        CLK    : in STD_logic;
	        ADDR   : in STD_LOGIC_VECTOR (9 downto 0);
	        DO     : out STD_LOGIC_VECTOR (15 downto 0);
	        DOP    : out STD_LOGIC_VECTOR (1 downto 0)
	       ); 

	end component;

	-- timings 
	signal sample, clken, biten  : std_logic := '0';
	signal clkencnt : integer range 0 to 2; 
	signal bitencnt : integer range 0 to 5;
	signal samplecnt : integer range 0 to 191;  
	signal clk, reset : std_logic := '0'; 
	signal dout : std_logic_vector(15 downto 0);
	signal chan : std_logic_vector(3 downto 0);
	signal weout : std_logic := '0';
	signal framepos : integer range 0 to 63 := 63; 
	signal parityA, parityB : std_logic := '0';
	signal dataA, dataB : std_logic_vector(23 downto 0) := (others => '0'); 
	signal bitdin : std_logic := '0';
	signal lfiberout : std_logic := '0';
	signal  pred : std_logic_vector(1 downto 0) := (others => '0'); 
	signal framecnt : integer range 0 to 191; 
	signal mainclken : std_logic := '0';

	signal ramdata : std_logic_vector(15 downto 0) := (others => '0');
	signal ramaddr : std_logic_vector(9 downto 0) := (others => '0'); 

begin
    

   U1: TOC port map (O=>reset);

   freqsyn: dcm generic map (
   		DFS_FREQUENCY_MODE => "LOW",
		CLKFX_DIVIDE => 5,
		CLKFX_MULTIPLY=> 1,
		STARTUP_WAIT => False,
		CLK_FEEDBACK => "NONE"	  
   	) port map (

            CLKIN =>    CLKIN,
            CLKFB =>    '0',
            DSSEN =>    '0',
            PSINCDEC => '0',
            PSEN =>     '0',
            PSCLK =>    '0',
            RST =>      RESET,
            CLKFX =>    CLK,
		  CLKFX180 => open,
            LOCKED =>   open); 
		  		
   datarom : RAMB16_S18 generic map (
		INIT_00 => X"63D45EFC59C8543E4E62483B41CE3B22343D2D2525E21E7B16F60F5B07B10000",
		INIT_01 => X"769E78E57AB87C157CFA7D677D5B7CD67BD97A64787A761B734B700C6C60684D",
		INIT_02 => X"1FF827592E9435A23C7C431C497C4F9455605AD95FFC64C169266D2570BB73E4",
		INIT_03 => X"ACE8B2D3B909BF83C63BCD2BD44BDB96E304EA8EF22CF9D8018A093A10E21879",
		INIT_04 => X"83B482E6829282B68353846885F487F68A6C8D5290A8946898909D1CA207A74D",
		INIT_05 => X"C8FBC22CBB98B547AF3DA981A4199F099A569606921B8E9B8B8788E486B484F8",
		INIT_06 => X"3F2A3866316C2A4222F01B7C13ED0C4C049EFCECF53DED98E605DE8BD731CFFF",
		INIT_07 => X"7D347C7F7B5279AE77957509720C6EA16ACB668F61F05CF2579B51EF4BF545B1",
		INIT_08 => X"4BF551EF579B5CF261F0668F6ACB6EA1720C7509779579AE7B527C7F7D347D71",
		INIT_09 => X"D731DE8BE605ED98F53DFCEC049E0C4C13ED1B7C22F02A42316C38663F2A45B1",
		INIT_0A => X"86B488E48B878E9B921B96069A569F09A419A981AF3DB547BB98C22CC8FBCFFF",
		INIT_0B => X"A2079D1C9890946890A88D528A6C87F685F48468835382B6829282E683B484F8",
		INIT_0C => X"10E2093A018AF9D8F22CEA8EE304DB96D44BCD2BC63BBF83B909B2D3ACE8A74D",
		INIT_0D => X"70BB6D25692664C15FFC5AD955604F94497C431C3C7C35A22E9427591FF81879",
		INIT_0E => X"6C60700C734B761B787A7A647BD97CD67D5B7D677CFA7C157AB878E5769E73E4",
		INIT_0F => X"07B10F5B16F61E7B25E22D25343D3B2241CE483B4E62543E59C85EFC63D4684D",
		INIT_10 => X"9C2CA104A638ABC2B19EB7C5BE32C4DECBC3D2DBDA1EE185E90AF0A5F84F0000",
		INIT_11 => X"8962871B854883EB8306829982A5832A8427859C878689E58CB58FF493A097B3",
		INIT_12 => X"E008D8A7D16CCA5EC384BCE4B684B06CAAA0A527A0049B3F96DA92DB8F458C1C",
		INIT_13 => X"53184D2D46F7407D39C532D52BB5246A1CFC15720DD40628FE76F6C6EF1EE787",
		INIT_14 => X"7C4C7D1A7D6E7D4A7CAD7B987A0C780A759472AE6F586B98677062E45DF958B3",
		INIT_15 => X"37053DD444684AB950C3567F5BE760F765AA69FA6DE571657479771C794C7B08",
		INIT_16 => X"C0D6C79ACE94D5BEDD10E484EC13F3B4FB6203140AC3126819FB217528CF3001",
		INIT_17 => X"82CC838184AE8652886B8AF78DF4915F953599719E10A30EA865AE11B40BBA4F",
		INIT_18 => X"B40BAE11A865A30E9E1099719535915F8DF48AF7886B865284AE838182CC828F",
		INIT_19 => X"28CF217519FB12680AC30314FB62F3B4EC13E484DD10D5BECE94C79AC0D6BA4F",
		INIT_1A => X"794C771C747971656DE569FA65AA60F75BE7567F50C34AB944683DD437053001",
		INIT_1B => X"5DF962E467706B986F5872AE7594780A7A0C7B987CAD7D4A7D6E7D1A7C4C7B08",
		INIT_1C => X"EF1EF6C6FE7606280DD415721CFC246A2BB532D539C5407D46F74D2D531858B3",
		INIT_1D => X"8F4592DB96DA9B3FA004A527AAA0B06CB684BCE4C384CA5ED16CD8A7E008E787",
		INIT_1E => X"93A08FF48CB589E58786859C8427832A82A58299830683EB8548871B89628C1C",
		INIT_1F => X"F84FF0A5E90AE185DA1ED2DBCBC3C4DEBE32B7C5B19EABC2A638A1049C2C97B3"
		   	)
   	port map  (
   	
		DI => X"0000",
		DIP => "00",
		EN => '1',
		SSR => '0',
		WE => '0',
		CLK => clk,
		ADDR => ramaddr,
		DO => ramdata,
		dop => open); 
	
		
   inputuut : input port map (
   	CLK => clk,
	INSAMPLE => sample,
	RESET => reset,
	CONVST => CONVST,
	ADCCS => ADCCS, 
	SCLK => SCLK,
	SDIN => SDIN,
	DOUT => dout,
	COUT => chan,
	WEOUT => weout,
	OSC => "0000",
	OSRST => '0',
	OSEN => '0',
	OSWE => '0',
	OSD => X"0000"); 

	bitouts : bitencode port map (
		CLK => clk,
		RESET => reset,
		EN => clken, 
		BITEN => biten, 
		DIN => bitdin,
		PRED => pred, 
		DOUT => lfiberout); 

	CLKOUT <= clk; 

	pred <= "11" when framepos < 4 and framecnt = 0 else
		   "01" when framepos < 4 and framecnt > 0 else
		   "10" when framepos > 31 and framepos < 36 else
		   "00";
	bitdin <=	 -- the first seven are for the frame preamble 
			-- for subframe 1
			'0' when framepos = 0 else
			'0' when framepos = 1 else
			'0' when framepos = 2 else
			'0' when framepos = 3 else
			-- data for subframe 1
			dataA(0) when framepos = 4 else
			dataA(1) when framepos = 5 else
			dataA(2) when framepos = 6 else
			dataA(3) when framepos = 7 else
			dataA(4) when framepos = 8 else
			dataA(5) when framepos = 9 else
			dataA(6) when framepos = 10 else
			dataA(7) when framepos = 11 else
			dataA(8) when framepos = 12 else
			dataA(9) when framepos = 13 else
			dataA(10) when framepos = 14 else
			dataA(11) when framepos = 15 else
			dataA(12) when framepos = 16 else
			dataA(13) when framepos = 17 else
			dataA(14) when framepos = 18 else
			dataA(15) when framepos = 19 else
			dataA(16) when framepos = 20 else
			dataA(17) when framepos = 21 else
			dataA(18) when framepos = 22 else
			dataA(19) when framepos = 23 else
			dataA(20) when framepos = 24 else
			dataA(21) when framepos = 25 else
			dataA(22) when framepos = 26 else
			dataA(23) when framepos = 27 else
			'1' when framepos = 28 else -- validity
			'0' when framepos = 29 else -- user
			'0' when framepos = 30 else -- custom
			parityA when framepos = 31 else -- parity 
			-- preamble for the subframe 2
			'0' when framepos = 32 else
			'0' when framepos = 33 else
			'0' when framepos = 34 else
			'0' when framepos = 35 else
			-- data for subframe 2
			dataB(0) when framepos = 36 else
			dataB(1) when framepos = 37 else
			dataB(2) when framepos = 38 else
			dataB(3) when framepos = 39 else
			dataB(4) when framepos = 40 else
			dataB(5) when framepos = 41 else
			dataB(6) when framepos = 42 else
			dataB(7) when framepos = 43 else
			dataB(8) when framepos = 44 else
			dataB(9) when framepos = 45 else
			dataB(10) when framepos = 46 else
			dataB(11) when framepos = 47 else
			dataB(12) when framepos = 48 else
			dataB(13) when framepos = 49 else
			dataB(14) when framepos = 50 else
			dataB(15) when framepos = 51 else
			dataB(16) when framepos = 52 else
			dataB(17) when framepos = 53 else
			dataB(18) when framepos = 54 else
			dataB(19) when framepos = 55 else
			dataB(20) when framepos = 56 else
			dataB(21) when framepos = 57 else
			dataB(22) when framepos = 58 else
			dataB(23) when framepos = 59 else
			'1' when framepos = 60 else -- validity
			'0' when framepos = 61 else -- user
			'0' when framepos = 62 else -- custom
			parityB when framepos = 63; --parity
			
	clocks : process(reset, CLK, clkencnt, bitencnt, samplecnt) is
	begin
		if reset = '1' then
		   samplecnt <= 0; 
		   bitencnt <= 0;
		   clkencnt <= 0; 
		   framepos <= 63; 
		else
			if rising_edge(CLK) then
					BITOUT <= bitdin; 
					CLKENOUT <= CLKEN;
					BITENOUT <= BITEN; 
					SAMPLEOUT <= SAMPLE;
					FIBEROUT <= lfiberout; 
					if weout = '1' and chan(3 downto 0) = "0000" then
						dataA <= "00000000" & ramdata; 
						dataB <= "00000000" & ramdata; 
					end if;  

					if sample = '1' then
						if ramaddr = "0111111111" then
							ramaddr <= (others => '0');
						else
							ramaddr <= ramaddr + 1;
						end if;  
					end if; 

					if bitencnt = 0 then
						if framepos = 63 then
							framepos <= 0;
						else
							framepos <= framepos + 1; 
						end if; 
					end if; 
					if samplecnt = 0 and framepos = 63 then
						if framecnt = 191 then
							framecnt <= 0;
						else
							framecnt <= framecnt + 1;
						end if;
					end if; 

					if samplecnt = 191 then
						samplecnt <= 0;
					else
						samplecnt <= samplecnt + 1;
					end if; 
					if samplecnt = 0 then
						sample <= '1';
					else
						sample <= '0';
					end if; 

					if bitencnt = 5 then
						bitencnt <= 0;
					else
						bitencnt <= bitencnt + 1;
					end if; 
					if bitencnt = 0 then
						biten <= '1';
					else
						biten <= '0';
					end if; 

					if clkencnt = 2 then
						clkencnt <= 0;
					else
						clkencnt <= clkencnt + 1;
					end if; 
					if clkencnt = 0 then
						clken <= '1';
					else
						clken <= '0';
					end if; 
			    end if; 
		end if; 
	end process clocks;


end Behavioral;
