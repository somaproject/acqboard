library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;


-- XSEL --------------------------------------------------------
--  Input and sample buffer for data samples. 
-- 
-- 
-- 
-- 
entity XSEL is
    Port ( OUTSAMPCLK : in std_logic;
           CLK4X : in std_logic;
           CLR : in std_logic;
           SAMPCNT : in std_logic_vector(6 downto 0);
           ADDRA7 : in std_logic;
			  RESET : in std_logic; 
           XD : out std_logic_vector(13 downto 0);
           DOTS : in std_logic_vector(4 downto 0);
           DATAIN : in std_logic_vector(13 downto 0);
           WEB : in std_logic_vector(4 downto 0);
           ADDRB : in std_logic_vector(7 downto 0));
end XSEL;

architecture Behavioral of XSEL is
	signal addraindex, addraindex_ld: std_logic_vector(6 downto 0) := "0000000";
	signal DOA0, DOA1, DOA2, DOA3, DOA4 : std_logic_vector(13 downto 0) := "00000000000000"; 

	component RAMB4_S16_S16
	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (15 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        RSTA   : in STD_logic;
	        RSTB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (7 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (7 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (15 downto 0)); 
	end component;

begin

	-- x output sample counter
	xcount: process(CLR, CLK4X, addraindex_ld) is
	begin
		if rising_edge(CLK4X) then
			if CLR ='1' then
				addraindex <= addraindex_ld;
			else
				addraindex <= addraindex -1;
			end if;
		end if; 
	end process xcount; 

	-- sample number latch
	sampcntlatch: process (CLK4X, OUTSAMPCLK, SAMPCNT) is
	begin
		if rising_edge(CLK4X) then
			if OUTSAMPCLK = '1' then
				addraindex_ld <= SAMPCNT;
			end if;
		end if; 
	end process sampcntlatch;

	-- instantiation of the five ram blocks. 
	-- ram block 0 : holds channel 1 for input A and B
	SampleRAM0:  RAMB4_S16_S16 port map (
		DIA => "0000000000000000",
		DIB(13 downto 0) => DATAIN,
		DIB(15 downto 14) => "00", 
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => WEB(0),
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK4X,
		CLKB => CLK4X,
		ADDRA(7) => ADDRA7,
		ADDRA(6 downto 0) =>addraindex,
		ADDRB => ADDRB,
		DOA(13 downto 0) => DOA0,
		DOA(15 downto 14) => open,
		DOB => open); 

	-- ram block 1 : holds channel 2 for input A and B
	SampleRAM1:  RAMB4_S16_S16 port map (
		DIA => "0000000000000000",
		DIB(13 downto 0) => DATAIN,
		DIB(15 downto 14) => "00", 
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => WEB(1),
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK4X,
		CLKB => CLK4X,
		ADDRA(7) => ADDRA7,
		ADDRA(6 downto 0) =>addraindex,
		ADDRB => ADDRB,
		DOA(13 downto 0) => DOA1,
		DOA(15 downto 14) => open,
		DOB => open); 
		 
	-- ram block 2 : holds channel 3 for input A and B
	SampleRAM2:  RAMB4_S16_S16 port map (
		DIA => "0000000000000000",
		DIB(13 downto 0) => DATAIN,
		DIB(15 downto 14) => "00", 
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => WEB(2),
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK4X,
		CLKB => CLK4X,
		ADDRA(7) => ADDRA7,
		ADDRA(6 downto 0) =>addraindex,
		ADDRB => ADDRB,
		DOA(13 downto 0) => DOA2,
		DOA(15 downto 14) => open,
		DOB => open); 

	-- ram block 3 : holds channel 4 for input A and B
	SampleRAM3:  RAMB4_S16_S16 port map (
		DIA => "0000000000000000",
		DIB(13 downto 0) => DATAIN,
		DIB(15 downto 14) => "00", 
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => WEB(3),
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK4X,
		CLKB => CLK4X,
		ADDRA(7) => ADDRA7,
		ADDRA(6 downto 0) =>addraindex,
		ADDRB => ADDRB,
		DOA(13 downto 0) => DOA3,
		DOA(15 downto 14) => open,
		DOB => open); 

	-- ram block 4 : holds channel C for input A and B
	SampleRAM4:  RAMB4_S16_S16 port map (
		DIA => "0000000000000000",
		DIB(13 downto 0) => DATAIN,
		DIB(15 downto 14) => "00", 
		ENA => '1',
		ENB => '1',
		WEA => '0',
		WEB => WEB(4),
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK4X,
		CLKB => CLK4X,
		ADDRA(7) => ADDRA7,
		ADDRA(6 downto 0) =>addraindex,
		ADDRB => ADDRB,
		DOA(13 downto 0) => DOA4,
		DOA(15 downto 14) => open,
		DOB => open); 


	XD <= DOA0 when DOTS = "00001" else
			DOA1 when DOTS = "00010" else
			DOA2 when DOTS = "00100" else
			DOA3 when DOTS = "01000" else
			DOA4 when DOTS = "10000"; 
			
		 
end Behavioral;
