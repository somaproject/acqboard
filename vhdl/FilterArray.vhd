library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity FilterArray is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           WE : in std_logic;
           H : out std_logic_vector(21 downto 0);
           HA : in std_logic_vector(6 downto 0);
           AIN : in std_logic_vector(7 downto 0);
           DIN : in std_logic_vector(15 downto 0));
end FilterArray;

architecture Behavioral of FilterArray is
-- FILTERARRAY.VHD -- Array of filter coefficients. 22-bit values, 
-- which via creative input ram mapping are easily loaded sequentially. 

	signal we1, we2 : std_logic := '0';
	signal lh : std_logic_vector(31 downto 0) := (others => '0');
	signal addrin, addrout : std_logic_vector(7 downto 0) := (others => '0');


	 component RAMB4_S16_S16
	  generic (
	       INIT_00 : bit_vector ;
	       INIT_01 : bit_vector ;
	       INIT_02 : bit_vector ;
	       INIT_03 : bit_vector ;
	       INIT_04 : bit_vector ;
	       INIT_05 : bit_vector ;
	       INIT_06 : bit_vector ;
	       INIT_07 : bit_vector ;
	       INIT_08 : bit_vector ;
	       INIT_09 : bit_vector ;
	       INIT_0A : bit_vector ;
	       INIT_0B : bit_vector ;
	       INIT_0C : bit_vector ;
	       INIT_0D : bit_vector ;
	       INIT_0E : bit_vector ;
	       INIT_0F : bit_vector 
		  );


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
   addrin <= '0' & AIN(7 downto 1); 
   addrout <= '0' & HA; 
   we1 <= WE and (not AIN(0));
   we2 <= WE and AIN(0);

   low_word: RAMB4_S16_S16 
   	  generic map(
			INIT_00 => X"E1AAE7C8ED76F27DF6BBFA24FCBCFE97FFCF008400D800E800CF00A20070005C",
			INIT_01 => X"3D9C31CC2345134D031AF3BFE61FDADED265CCDACA2DCA20CC50D045D57ADB6E",
			INIT_02 => X"9BC77ECD701B6E8F785F8B44A4AAC1DFE046FD7C177E2CC13C3C45704860457E",
			INIT_03 => X"8E2ABF53DDE1E83EDDE1BF538E2A4CEFFEF2A8134C8AF09D9864478A011DC763",
			INIT_04 => X"A4AA8B44785F6E8F701B7ECD9BC7C763011D478A9864F09D4C8AA813FEF24CEF",
			INIT_05 => X"E61FF3BF031A134D234531CC3D9C457E486045703C3C2CC1177EFD7CE046C1DF",
			INIT_06 => X"FCBCFA24F6BBF27DED76E7C8E1AADB6ED57AD045CC50CA20CA2DCCDAD265DADE",
			INIT_07 => X"0000000000000000000000000000005C007000A200CF00E800D80084FFCFFE97",
	       INIT_08 => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_09 => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0A => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0B => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0C => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0D => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0E => X"000000000000000000000000000000000000000000000000000000000000001F",
	       INIT_0F => X"000000000000000000000000000000000000000000000000000000000000001F"
		  )
	  port map (
	  	  DIA => DIN,
		  DIB => "0000000000000000",
		  ENA => '1',
		  ENB => '1',
		  WEA => we1,
		  WEB => '0',
		  RSTA => RESET,
		  RSTB => RESET,
		  CLKA => CLK,
		  CLKB => CLK,
		  ADDRA => addrin,
		  ADDRB => addrout,
		  DOA => open,
		  DOB => LH(15 downto 0)
	 );

   high_word: RAMB4_S16_S16 
   	  generic map(
			INIT_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000",
			INIT_01 => X"00000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
			INIT_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000",
			INIT_03 => X"000200020002000200020002000200020001000100010000000000000000FFFF",
			INIT_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000001000100010002",
			INIT_05 => X"FFFFFFFF00000000000000000000000000000000000000000000FFFFFFFFFFFF",
			INIT_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
			INIT_07 => X"00000000000000000000000000000000000000000000000000000000FFFFFFFF",
	       INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
	       INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000"
		  )
	  port map (
	  	  DIA => DIN,
		  DIB => "0000000000000000",
		  ENA => '1',
		  ENB => '1',
		  WEA => we2,
		  WEB => '0',
		  RSTA => RESET,
		  RSTB => RESET,
		  CLKA => CLK,
		  CLKB => CLK,
		  ADDRA => addrin,
		  ADDRB => addrout,
		  DOA => open,
		  DOB => LH(31 downto 16)
	 );
	  	  

	process(CLK) is
	begin
	   if rising_edge(CLK) then
	      H <= lh(21 downto 0);
	   end if;								 
	end process; 

end Behavioral;
