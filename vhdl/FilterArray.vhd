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
	           HA : in std_logic_vector(7 downto 0);
	           AIN : in std_logic_vector(8 downto 0);
	           DIN : in std_logic_vector(15 downto 0));
	end entity;

architecture Behavioral of FilterArray is
-- FILTERARRAY.VHD -- Array of filter coefficients. 22-bit values, 
-- which via creative input ram mapping are easily loaded sequentially. 

	signal addra : std_logic_vector(9 downto 0) := (others => '0'); 
	signal addrb : std_logic_vector(8 downto 0) := (others => '0'); 
	signal dob : std_logic_vector(31 downto 0) := (others => '0');
	 
	----- Component RAMB16_S18_S36 -----
	component RAMB16_S18_S36
	--
	  generic (
	       WRITE_MODE_A : string := "WRITE_FIRST";
	       WRITE_MODE_B : string := "WRITE_FIRST";
	       INIT_A : bit_vector  := X"00000";
	       SRVAL_A : bit_vector := X"00000";

	       INIT_B : bit_vector  := X"000000000";
	       SRVAL_B : bit_vector := X"000000000";

	       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );

	--
	  port (DIA    : in STD_LOGIC_VECTOR (15 downto 0);
	        DIB    : in STD_LOGIC_VECTOR (31 downto 0);
	        DIPA    : in STD_LOGIC_VECTOR (1 downto 0);
	        DIPB    : in STD_LOGIC_VECTOR (3 downto 0);
	        ENA    : in STD_logic;
	        ENB    : in STD_logic;
	        WEA    : in STD_logic;
	        WEB    : in STD_logic;
	        SSRA   : in STD_logic;
	        SSRB   : in STD_logic;
	        CLKA   : in STD_logic;
	        CLKB   : in STD_logic;
	        ADDRA  : in STD_LOGIC_VECTOR (9 downto 0);
	        ADDRB  : in STD_LOGIC_VECTOR (8 downto 0);
	        DOA    : out STD_LOGIC_VECTOR (15 downto 0);
	        DOB    : out STD_LOGIC_VECTOR (31 downto 0);
	        DOPA    : out STD_LOGIC_VECTOR (1 downto 0);
	        DOPB    : out STD_LOGIC_VECTOR (3 downto 0)); 
	end component;


begin
	fbuf: RAMB16_S18_S36 port map (
		DIA => DIN,
		DIB => X"00000000",
		DIPA => "00",
		DIPB => "0000",
		ENA => '1',
		ENB => '1',
		WEA => WE,
		WEB => '0',
		SSRA => RESET,
		SSRB => RESET,
		CLKA => CLK,
		CLKB => CLK,
		ADDRA => addra,
		ADDRB => addrb,
		DOA => open,
		DOB => dob, 
		DOPA => open,
		DOPB => open);


	addra <= '0' & AIN;
	addrb <= '0' & HA;
	process(clk) is
	begin
		if rising_edge(CLK) then
			H <= dob(21 downto 0); 
		end if; 
	end process; 
		
  
end Behavioral;
