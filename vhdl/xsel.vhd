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
           CLK2X : in std_logic;
           CLR : in std_logic;
           SAMPCNT : in std_logic_vector(6 downto 0);
           ADDRA7 : in std_logic;
			  RESET : in std_logic; 
           XD : out std_logic_vector(13 downto 0) := "00000000000000";
           DOTS : in std_logic_vector(2 downto 0);
           DATAIN : in std_logic_vector(13 downto 0);
           WEB : in std_logic_vector(4 downto 0);
           ADDRB : in std_logic_vector(7 downto 0));
end XSEL;

architecture Behavioral of XSEL is
	signal addraindex, sampcntl: std_logic_vector(6 downto 0) := "0000000";
	signal DOA0, DOA1, DOA2, DOA3, DOA4 : std_logic_vector(13 downto 0) := "00000000000000"; 
	signal doal0, DoAl1, DoAl2, DoAl3, DoAl4 : std_logic_vector(13 downto 0) := "00000000000000"; 


	signal DOA_dummy: std_logic_vector(1 downto 0); 
	component RAMB4_S16_S16
	--
	  generic (
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000");
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
	xcount: process(CLR, CLK2X, sampcntl) is
	begin
		if rising_edge(CLK2X) then
			if CLR ='1' then
				addraindex <= sampcntl;
			else
				addraindex <= addraindex -1;
			end if;
		end if; 
	end process xcount; 

	-- sample number latch
	sampcntlatch: process (CLK2X, OUTSAMPCLK, SAMPCNT) is
	begin
		if rising_edge(CLK2X) then
			if OUTSAMPCLK = '1' then
				sampcntl <= SAMPCNT;
			end if;
		end if; 
	end process sampcntlatch;

	-- instantiation of the five ram blocks. 
	-- ram block 0 : holds channel 1 for input A and B
	SampleRAM0:  RAMB4_S16_S16	  generic map (
		      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
 		port map (
				DIA => "0000000000000000",
				DIB(13 downto 0) => DATAIN,
				DIB(15 downto 14) => "00", 
				ENA => '1',
				ENB => '1',
				WEA => '0',
				WEB => WEB(0),
				RSTA => RESET,
				RSTB => RESET,
				CLKA => CLK2X,
				CLKB => CLK2X,
				ADDRA(7) => ADDRA7,
				ADDRA(6 downto 0) =>addraindex,
				ADDRB => ADDRB,
				DOA(13 downto 0) => DOA0,
				DOA(15 downto 14) => DOA_dummy,
				DOB => open); 

	-- ram block 1 : holds channel 2 for input A and B
	SampleRAM1:  RAMB4_S16_S16  generic map (
		      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
 		port map (
				DIA => "0000000000000000",
				DIB(13 downto 0) => DATAIN,
				DIB(15 downto 14) => "00", 
				ENA => '1',
				ENB => '1',
				WEA => '0',
				WEB => WEB(1),
				RSTA => RESET,
				RSTB => RESET,
				CLKA => CLK2X,
				CLKB => CLK2X,
				ADDRA(7) => ADDRA7,
				ADDRA(6 downto 0) =>addraindex,
				ADDRB => ADDRB,
				DOA(13 downto 0) => DOA1,
				DOA(15 downto 14) => DOA_dummy,
				DOB => open); 
		 
	-- ram block 2 : holds channel 3 for input A and B
	SampleRAM2:  RAMB4_S16_S16  generic map (
		      INIT_00 => X"0000000000000000000000000000000000000006000500040003000200010000",
		      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
 		port map (
				DIA => "0000000000000000",
				DIB(13 downto 0) => DATAIN,
				DIB(15 downto 14) => "00", 
				ENA => '1',
				ENB => '1',
				WEA => '0',
				WEB => WEB(2),
				RSTA => RESET,
				RSTB => RESET,
				CLKA => CLK2X,
				CLKB => CLK2X,
				ADDRA(7) => ADDRA7,
				ADDRA(6 downto 0) =>addraindex,
				ADDRB => ADDRB,
				DOA(13 downto 0) => DOA2,
				DOA(15 downto 14) => DOA_dummy,
				DOB => open); 

	-- ram block 3 : holds channel 4 for input A and B
	SampleRAM3:  RAMB4_S16_S16  generic map (
		      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
 		port map (
				DIA => "0000000000000000",
				DIB(13 downto 0) => DATAIN,
				DIB(15 downto 14) => "00", 
				ENA => '1',
				ENB => '1',
				WEA => '0',
				WEB => WEB(3),
				RSTA => RESET,
				RSTB => RESET,
				CLKA => CLK2X,
				CLKB => CLK2X,
				ADDRA(7) => ADDRA7,
				ADDRA(6 downto 0) =>addraindex,
				ADDRB => ADDRB,
				DOA(13 downto 0) => DOA3,
				DOA(15 downto 14) => DOA_dummy,
				DOB => open); 

	-- ram block 4 : holds channel C for input A and B
	SampleRAM4:  RAMB4_S16_S16  generic map (
		      INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
		      INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
 		port map (
				DIA => "0000000000000000",
				DIB(13 downto 0) => DATAIN,
				DIB(15 downto 14) => "00", 
				ENA => '1',
				ENB => '1',
				WEA => '0',
				WEB => WEB(4),
				RSTA => RESET,
				RSTB => RESET,
				CLKA => CLK2X,
				CLKB => CLK2X,
				ADDRA(7) => ADDRA7,
				ADDRA(6 downto 0) =>addraindex,
				ADDRB => ADDRB,
				DOA(13 downto 0) => DOA4,
				DOA(15 downto 14) => DOA_dummy,
				DOB => open); 

	 test: process(CLK2X, CLR, DOTS) is
	 begin
	 	if rising_edge(CLK2X) then
	 	case DOTS is
			when "001" =>
				XD <= DOA0;
			when "010" =>
				XD <= DOA1;
			when "011" =>
				XD <= DOA2;
			when "100" =>
				XD <= DOA3;
			when "101" =>
				XD <= DOA4;
			when others =>
				XD <= "00000000000000";
		end case;  
		end if; 
	end process test; 	 
end Behavioral;
