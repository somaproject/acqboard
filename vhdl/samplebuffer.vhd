library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity samplebuffer is
    Port ( CLK2X : in std_logic;
           RESET : in std_logic;
           DIN : in std_logic_vector(15 downto 0);
           CHANIN : in std_logic_vector(3 downto 0);
           WE : in std_logic;
           AIN : in std_logic_vector(6 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           AOUT : in std_logic_vector(6 downto 0);
           CHANOUT : in std_logic_vector(3 downto 0));
end samplebuffer;

architecture Behavioral of samplebuffer is
-- SAMPLEBUFFER.VHD -- sample buffers. Use 5 BlockSelect+ RAMs with
-- high half for odd channels (CHAN(0)=0) and low half for odds. 
-- note that output is an extra clock cycle late!

	signal data1, data2, data3, data4, data5 : 
		std_logic_vector(15 downto 0) := (others => '0');
	signal we1, we2, we3, we4, we5 : std_logic := '0'; 
	signal addra, addrb : std_logic_vector(7 downto 0) := (others => '0');


	 component RAMB4_S16_S16
	  generic (
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
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
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
   RAM1: RAMB4_S16_S16 port map (
   		DIA => DIN,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => WE1,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK2X,
		CLKB => CLK2X,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => DATA1);

   RAM2: RAMB4_S16_S16 port map (
   		DIA => DIN,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => WE2,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK2X,
		CLKB => CLK2X,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => DATA2);

   RAM3: RAMB4_S16_S16 port map (
   		DIA => DIN,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => WE3,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK2X,
		CLKB => CLK2X,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => DATA3);

   RAM4: RAMB4_S16_S16 port map (
   		DIA => DIN,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => WE4,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK2X,
		CLKB => CLK2X,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => DATA4);

   RAM5: RAMB4_S16_S16 port map (
   		DIA => DIN,
		DIB => "0000000000000000",
		ENA => '1',
		ENB => '1',
		WEA => WE5,
		WEB => '0',
		RSTA => RESET,
		RSTB => RESET,
		CLKA => CLK2X,
		CLKB => CLK2X,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => DATA5);

   -- signals
     addra <= (chanin(0) & ain);
	addrb <= (chanout(0) & aout);
   -- write enable decoding
   	WE1 <= '1' when WE = '1' and CHANIN(3 downto 1) = "000" else '0';
  	WE2 <= '1' when WE = '1' and CHANIN(3 downto 1) = "001" else '0';
  	WE3 <= '1' when WE = '1' and CHANIN(3 downto 1) = "010" else '0';
  	WE4 <= '1' when WE = '1' and CHANIN(3 downto 1)= "011" else '0';
  	WE5 <= '1' when WE = '1' and CHANIN(3 downto 1) = "100" else '0';


   -- output register
   process(CLK2X) is
   begin
   	if rising_edge(CLK2X) then
		case CHANOUT(3 downto 1) is
			when "000" => DOUT <= DATA1;
			when "001" => DOUT <= DATA2;
			when "010" => DOUT <= DATA3;
			when "011" => DOUT <= DATA4;
			when "100" => DOUT <= DATA5;
			when others => Null;
		end case; 
	end if;
   end process; 

end Behavioral;
