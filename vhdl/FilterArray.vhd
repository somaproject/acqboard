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
	       INIT_00 => X"EDA4F15AF4DDF803FAAEFCD4FE73FF96005000B300D700D100B10086005A0049",
	       INIT_01 => X"379C318328B01E1812B1075BFCD3F3AEEC50E6EFE394E223E261E400E6A7E9FA",
	       INIT_02 => X"B4E394DA81A37A757DEE8A3D9D41B4B7CE5FE821002C150925AB317538343A16",
	       INIT_03 => X"7ADAA779C32BCC8EC32BA7797ADA3F7FF84CA8A35437FECCAC065F311B15E1D8",
	       INIT_04 => X"9D418A3D7DEE7A7581A394DAB4E3E1D81B155F31AC06FECC5437A8A3F84C3F7F",
	       INIT_05 => X"FCD3075B12B11E1828B03183379C3A163834317525AB1509002CE821CE5FB4B7",
	       INIT_06 => X"FE73FCD4FAAEF803F4DDF15AEDA4E9FAE6A7E400E261E223E394E6EFEC50F3AE",
	       INIT_07 => X"00000000000000000000000000000049005A008600B100D100D700B30050FF96",
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
	       INIT_00 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000",
	       INIT_01 => X"000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	       INIT_02 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000",
	       INIT_03 => X"000200020002000200020002000200020001000100010000000000000000FFFF",
	       INIT_04 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000001000100010002",
	       INIT_05 => X"FFFF000000000000000000000000000000000000000000000000FFFFFFFFFFFF",
	       INIT_06 => X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
	       INIT_07 => X"000000000000000000000000000000000000000000000000000000000000FFFF",
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
