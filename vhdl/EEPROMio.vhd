library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity EEPROMio is
    Port ( CLK : in std_logic;
           I2CCLK : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           DIN : in std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(10 downto 0);
           WR : in std_logic;
           EN : in std_logic;
           DONE : out std_logic;
           SCL : out std_logic;
           SDA : inout std_logic);
end EEPROMio;

architecture Behavioral of EEPROMio is
-- EEPROMIO.VHD -- Interface to I2C serial EEPROM with BlockSelect+ ram
-- as a giant FSM 

   signal lutaddr, llutaddr : std_logic_vector(8 downto 0) := (others => '0');
   signal inbit, rombit, insel, sen, sclin, sclinl,
   		inrst, nextin, stop : std_logic := '0';
   signal sdats, sdaout, sdain, sdatsl, sdaoutl, lsdain : std_logic := '0';
   signal lutout, lutoutl : std_logic_vector(7 downto 0) := (others => '0'); 
   signal incnt:  integer range 0 to 27 := 0;
   signal input : std_logic_vector(27 downto 0); 
   signal outreg : std_logic_vector(15 downto 0) := (others => '0'); 
   signal donecnt : integer range 0 to 511 := 0; 
   signal enl : std_logic := '0';

-- io buffer instantiation

	component IOBUF
	      port (I, T: in std_logic; 
	            O: out std_logic; 
	            IO: inout std_logic);
	end component;   
   
	component OBUF
	      port (I: in std_logic; O: out std_logic);
	end component;   
 
begin 

   IO: IOBUF port map (I => sdaoutl, T => sdatsl,
              O => lsdain, IO => SDA);
   
   U1: OBUF port map (I => SCLINL, O => SCL);
 

   lutaddr(8) <= wr; 

   -- wire up LUTOUT to signals
   sclin <= lutout(0);
   sdats <= lutout(1);
   rombit <= lutout(2);
   insel <= lutout(3);
   nextin <= lutout(4);
   inrst <= lutout(5);
   sen <= lutout(6);
   stop <= lutout(7); 

  

   clock: process(CLK) is
   begin
   	if rising_edge(CLK) then
	   -- IO registers
	   sdain <= lsdain;
	   sdatsl <= not sdats;
	   sdaoutl <= sdaout; 
	   sclinl <= sclin; 
	   lutoutl <= lutout; 
	   -- now, the meat of the system 

	   -- LUT counter
	   if EN = '1' then
	    	enl <= '1'; 
	   	lutaddr(7 downto 0) <= (others => '0');
	   else
	   	if I2CCLK = '1' then 
		   	if stop = '0' and enl = '1' then 
				lutaddr(7 downto 0)  <= lutaddr(7 downto 0) + 1;
	 		else
				enl <= '0';
			end if; 
		end if; 
        end if; 
	   llutaddr <= lutaddr;
	    
	   -- input counter
	   if I2CCLK = '1' then
	   	 if inrst = '1' then 
		 	incnt <= 0;
		 elsif nextin = '1' then
		 	incnt <= incnt + 1;
		 end if;
         end if; 
	   
	   -- input shift register
	    
	   if I2CCLK = '1' and sen = '1' then
	   	outreg <= sdain & outreg(15 downto 1);
	   end if;  	

	   -- done register
	   if EN = '1' then
	   	donecnt <= 0;
		DONE <= '0'; 
        elsif I2CCLK = '1' then
		if donecnt = 510 then 
			DONE <= '1'; 
		 elsif stop = '1' then
		    DONE <= '0'; 
		    donecnt <= donecnt + 1;
		end if; 
	   end if; 



	end if; 



   end process clock; 

   DOUT <= outreg;

   -- input mux
   inbit <= input(incnt); 
   sdaout <= inbit when insel = '0' else
   		   rombit; 


   input(0) <= addr(10);
   input(1) <= addr(9);
   input(2) <= addr(8);
   input(3) <= addr(7);
   input(4) <= addr(6);
   input(5) <= addr(5);
   input(6) <= addr(4);
   input(7) <= addr(3);
   input(8) <= addr(2);
   input(9) <= addr(1);
   input(10) <= addr(0);
   input(11) <= '0';
   input(27 downto 12) <= din; 



   -- giant-ass LUT
   LUT: process(LUTADDR) is
   begin
   	case LLUTADDR is 
	  when "000000000" => lutout <= "00001010";-- start code
	  when "000000001" => lutout <= "00001110";
	  when "000000010" => lutout <= "00001111";
	  when "000000011" => lutout <= "00001011";
	  when "000000100" => lutout <= "00001010"; -- start done
	  when "000000101" => lutout <= "00001010";
	  when "000000110" => lutout <= "00001110"; -- control 0
	  when "000000111" => lutout <= "00001111";
	  when "000001000" => lutout <= "00001110"; 
	  when "000001001" => lutout <= "00001010"; -- control 1
	  when "000001010" => lutout <= "00001011";
	  when "000001011" => lutout <= "00001010";
	  when "000001100" => lutout <= "00001110"; -- control 2
	  when "000001101" => lutout <= "00001111";
	  when "000001110" => lutout <= "00001110";
	  when "000001111" => lutout <= "00001010"; -- control 3
	  when "000010000" => lutout <= "00001011";
	  when "000010001" => lutout <= "00001010";
	  when "000010010" => lutout <= "00001010"; -- control 4 (addr2)
	  when "000010011" => lutout <= "00001011";
	  when "000010100" => lutout <= "00001010";
	  when "000010101" => lutout <= "00001010"; -- control 5 (addr1)
	  when "000010110" => lutout <= "00001011";
	  when "000010111" => lutout <= "00001010";
	  when "000011000" => lutout <= "00001010"; -- control 6 (addr 0)
	  when "000011001" => lutout <= "00001011";
	  when "000011010" => lutout <= "00001010";
	  when "000011011" => lutout <= "00001010"; -- control 7
	  when "000011100" => lutout <= "00001011";
	  when "000011101" => lutout <= "00001010";
	  when "000011110" => lutout <= "00001000"; -- ack receive
	  when "000011111" => lutout <= "00101001"; -- reset cnt
	  when "000100000" => lutout <= "00001000";
	  when "000100001" => lutout <= "00001010"; -- address bit 15
	  when "000100010" => lutout <= "00001011";
	  when "000100011" => lutout <= "00001010";
	  when "000100100" => lutout <= "00001010"; -- address bit 14
	  when "000100101" => lutout <= "00001011";
	  when "000100110" => lutout <= "00001010";
	  when "000100111" => lutout <= "00001010"; -- address bit 13
	  when "000101000" => lutout <= "00001011";
	  when "000101001" => lutout <= "00001010";
	  when "000101010" => lutout <= "00001010"; -- address bit 12
	  when "000101011" => lutout <= "00001011";
	  when "000101100" => lutout <= "00001010";
	  when "000101101" => lutout <= "00000010"; -- address bit 11
	  when "000101110" => lutout <= "00000011";
	  when "000101111" => lutout <= "00010010";
	  when "000110000" => lutout <= "00000010"; -- address bit 10 
	  when "000110001" => lutout <= "00000011";
	  when "000110010" => lutout <= "00010010";
	  when "000110011" => lutout <= "00000010"; -- address bit 9
	  when "000110100" => lutout <= "00000011";
	  when "000110101" => lutout <= "00010010";
	  when "000110110" => lutout <= "00000010"; -- address bit 8 
	  when "000110111" => lutout <= "00000011";
	  when "000111000" => lutout <= "00000010";
	  when "000111001" => lutout <= "00000000"; -- ack
	  when "000111010" => lutout <= "00000001";
	  when "000111011" => lutout <= "00010000";
	  when "000111100" => lutout <= "00000010"; -- address bit 7
	  when "000111101" => lutout <= "00000011";
	  when "000111110" => lutout <= "00010010";
	  when "000111111" => lutout <= "00000010"; -- address bit 6
	  when "001000000" => lutout <= "00000011";
	  when "001000001" => lutout <= "00010010";
	  when "001000010" => lutout <= "00000010"; -- address bit 5
	  when "001000011" => lutout <= "00000011";
	  when "001000100" => lutout <= "00010010";
	  when "001000101" => lutout <= "00000010"; -- address bit 4
	  when "001000110" => lutout <= "00000011";
	  when "001000111" => lutout <= "00010010";
	  when "001001000" => lutout <= "00000010"; -- address bit 3
	  when "001001001" => lutout <= "00000011";
	  when "001001010" => lutout <= "00010010";
	  when "001001011" => lutout <= "00000010"; -- address bit 2
	  when "001001100" => lutout <= "00000011";
	  when "001001101" => lutout <= "00010010";
	  when "001001110" => lutout <= "00000010"; -- address bit 1
	  when "001001111" => lutout <= "00000011";
	  when "001010000" => lutout <= "00010010";
	  when "001010001" => lutout <= "00000010"; -- address bit 0
	  when "001010010" => lutout <= "00001011";
	  when "001010011" => lutout <= "00000010";
	  when "001010100" => lutout <= "00000000"; -- ack
	  when "001010101" => lutout <= "00000001";
	  when "001010110" => lutout <= "00010000";
	  when "001010111" => lutout <= "00000010"; -- data bit 0
	  when "001011000" => lutout <= "00000011"; 
	  when "001011001" => lutout <= "00010010";
	  when "001011010" => lutout <= "00000010"; -- data bit 1
	  when "001011011" => lutout <= "00000011";
	  when "001011100" => lutout <= "00010010";
	  when "001011101" => lutout <= "00000010"; -- data bit 2
	  when "001011110" => lutout <= "00000011";
	  when "001011111" => lutout <= "00010010";
	  when "001100000" => lutout <= "00000010"; -- data bit 3
	  when "001100001" => lutout <= "00000011";
	  when "001100010" => lutout <= "00010010";
	  when "001100011" => lutout <= "00000010"; -- data bit 4
	  when "001100100" => lutout <= "00000011";
	  when "001100101" => lutout <= "00010010";
	  when "001100110" => lutout <= "00000010"; -- data bit 5
	  when "001100111" => lutout <= "00000011";
	  when "001101000" => lutout <= "00010010";
	  when "001101001" => lutout <= "00000010"; -- data bit 6
	  when "001101010" => lutout <= "00000011";
	  when "001101011" => lutout <= "00010010";
	  when "001101100" => lutout <= "00000010"; -- data bit 7
	  when "001101101" => lutout <= "00000011";
	  when "001101110" => lutout <= "00000010";
	  when "001101111" => lutout <= "00000000"; -- ack
	  when "001110000" => lutout <= "00000001";
	  when "001110001" => lutout <= "00010000";
	  when "001110010" => lutout <= "00000010"; -- data bit 8
	  when "001110011" => lutout <= "00000011";
	  when "001110100" => lutout <= "00010010";
	  when "001110101" => lutout <= "00000010"; -- data bit 9
	  when "001110110" => lutout <= "00000011";
	  when "001110111" => lutout <= "00010010";
	  when "001111000" => lutout <= "00000010"; -- data bit 10
	  when "001111001" => lutout <= "00000011";
	  when "001111010" => lutout <= "00010010";
	  when "001111011" => lutout <= "00000010"; -- data bit 11
	  when "001111100" => lutout <= "00000011";
	  when "001111101" => lutout <= "00010010";
	  when "001111110" => lutout <= "00000010"; -- data bit 12
	  when "001111111" => lutout <= "00000011";
	  when "010000000" => lutout <= "00010010";
	  when "010000001" => lutout <= "00000010"; -- data bit 13
	  when "010000010" => lutout <= "00000011";
	  when "010000011" => lutout <= "00010010";
	  when "010000100" => lutout <= "00000010"; -- data bit 14
	  when "010000101" => lutout <= "00000011";
	  when "010000110" => lutout <= "00010010";
	  when "010000111" => lutout <= "00000010"; -- data bit 15
	  when "010001000" => lutout <= "00000011";
	  when "010001001" => lutout <= "00000010";
	  when "010001010" => lutout <= "00000010"; 
	  when "010001011" => lutout <= "00000010";
	  when "010001100" => lutout <= "00000010";
	  when "010001101" => lutout <= "00000000"; -- ack 
	  when "010001110" => lutout <= "00000001";
	  when "010001111" => lutout <= "00001000";
	  when "010010000" => lutout <= "00001010"; -- stop condition
	  when "010010001" => lutout <= "00001011";
	  when "010010010" => lutout <= "00001111";
	  when "010010011" => lutout <= "00001110";
	  when "010010100" => lutout <= "00000000"; -- done!
	  when "010010101" => lutout <= "10000000"; -- stop 
	  when "010010110" => lutout <= "00000000";
	  when "010010111" => lutout <= "00000000";
	  when "010011000" => lutout <= "00000000";
	  when "010011001" => lutout <= "00000000";
	  when "010011010" => lutout <= "00000000";
	  when "010011011" => lutout <= "00000000";
	  when "010011100" => lutout <= "00000000";
	  when "010011101" => lutout <= "00000000";
	  when "010011110" => lutout <= "00000000";
	  when "010011111" => lutout <= "00000000";
	  when "010100000" => lutout <= "00000000";
	  when "010100001" => lutout <= "00000000";
	  when "010100010" => lutout <= "00000000";
	  when "010100011" => lutout <= "00000000";
	  when "010100100" => lutout <= "00000000";
	  when "010100101" => lutout <= "00000000";
	  when "010100110" => lutout <= "00000000";
	  when "010100111" => lutout <= "00000000";
	  when "010101000" => lutout <= "00000000";
	  when "010101001" => lutout <= "00000000";
	  when "010101010" => lutout <= "00000000";
	  when "010101011" => lutout <= "00000000";
	  when "010101100" => lutout <= "00000000";
	  when "010101101" => lutout <= "00000000";
	  when "010101110" => lutout <= "00000000";
	  when "010101111" => lutout <= "00000000";
	  when "010110000" => lutout <= "00000000";
	  when "010110001" => lutout <= "00000000";
	  when "010110010" => lutout <= "00000000";
	  when "010110011" => lutout <= "00000000";
	  when "010110100" => lutout <= "00000000";
	  when "010110101" => lutout <= "00000000";
	  when "010110110" => lutout <= "00000000";
	  when "010110111" => lutout <= "00000000";
	  when "010111000" => lutout <= "00000000";
	  when "010111001" => lutout <= "00000000";
	  when "010111010" => lutout <= "00000000";
	  when "010111011" => lutout <= "00000000";
	  when "010111100" => lutout <= "00000000";
	  when "010111101" => lutout <= "00000000";
	  when "010111110" => lutout <= "00000000";
	  when "010111111" => lutout <= "00000000";
	  when "011000000" => lutout <= "00000000";
	  when "011000001" => lutout <= "00000000";
	  when "011000010" => lutout <= "00000000";
	  when "011000011" => lutout <= "00000000";
	  when "011000100" => lutout <= "00000000";
	  when "011000101" => lutout <= "00000000";
	  when "011000110" => lutout <= "00000000";
	  when "011000111" => lutout <= "00000000";
	  when "011001000" => lutout <= "00000000";
	  when "011001001" => lutout <= "00000000";
	  when "011001010" => lutout <= "00000000";
	  when "011001011" => lutout <= "00000000";
	  when "011001100" => lutout <= "00000000";
	  when "011001101" => lutout <= "00000000";
	  when "011001110" => lutout <= "00000000";
	  when "011001111" => lutout <= "00000000";
	  when "011010000" => lutout <= "00000000";
	  when "011010001" => lutout <= "00000000";
	  when "011010010" => lutout <= "00000000";
	  when "011010011" => lutout <= "00000000";
	  when "011010100" => lutout <= "00000000";
	  when "011010101" => lutout <= "00000000";
	  when "011010110" => lutout <= "00000000";
	  when "011010111" => lutout <= "00000000";
	  when "011011000" => lutout <= "00000000";
	  when "011011001" => lutout <= "00000000";
	  when "011011010" => lutout <= "00000000";
	  when "011011011" => lutout <= "00000000";
	  when "011011100" => lutout <= "00000000";
	  when "011011101" => lutout <= "00000000";
	  when "011011110" => lutout <= "00000000";
	  when "011011111" => lutout <= "00000000";
	  when "011100000" => lutout <= "00000000";
	  when "011100001" => lutout <= "00000000";
	  when "011100010" => lutout <= "00000000";
	  when "011100011" => lutout <= "00000000";
	  when "011100100" => lutout <= "00000000";
	  when "011100101" => lutout <= "00000000";
	  when "011100110" => lutout <= "00000000";
	  when "011100111" => lutout <= "00000000";
	  when "011101000" => lutout <= "00000000";
	  when "011101001" => lutout <= "00000000";
	  when "011101010" => lutout <= "00000000";
	  when "011101011" => lutout <= "00000000";
	  when "011101100" => lutout <= "00000000";
	  when "011101101" => lutout <= "00000000";
	  when "011101110" => lutout <= "00000000";
	  when "011101111" => lutout <= "00000000";
	  when "011110000" => lutout <= "00000000";
	  when "011110001" => lutout <= "00000000";
	  when "011110010" => lutout <= "00000000";
	  when "011110011" => lutout <= "00000000";
	  when "011110100" => lutout <= "00000000";
	  when "011110101" => lutout <= "00000000";
	  when "011110110" => lutout <= "00000000";
	  when "011110111" => lutout <= "00000000";
	  when "011111000" => lutout <= "00000000";
	  when "011111001" => lutout <= "00000000";
	  when "011111010" => lutout <= "00000000";
	  when "011111011" => lutout <= "00000000";
	  when "011111100" => lutout <= "00000000";
	  when "011111101" => lutout <= "00000000";
	  when "011111110" => lutout <= "00000000";
	  when "011111111" => lutout <= "00000000";
 -- RW = 1, i.e. reading code
	  when "100000000" => lutout <= "00000000";
	  when "100000001" => lutout <= "00000000";
	  when "100000010" => lutout <= "00000000";
	  when "100000011" => lutout <= "00000000";
	  when "100000100" => lutout <= "00000000";
	  when "100000101" => lutout <= "00000000";
	  when "100000110" => lutout <= "00000000";
	  when "100000111" => lutout <= "00000000";
	  when "100001000" => lutout <= "00000000";
	  when "100001001" => lutout <= "00000000";
	  when "100001010" => lutout <= "00000000";
	  when "100001011" => lutout <= "00000000";
	  when "100001100" => lutout <= "00000000";
	  when "100001101" => lutout <= "00000000";
	  when "100001110" => lutout <= "00000000";
	  when "100001111" => lutout <= "00000000";
	  when "100010000" => lutout <= "00000000";
	  when "100010001" => lutout <= "00000000";
	  when "100010010" => lutout <= "00000000";
	  when "100010011" => lutout <= "00000000";
	  when "100010100" => lutout <= "00000000";
	  when "100010101" => lutout <= "00000000";
	  when "100010110" => lutout <= "00000000";
	  when "100010111" => lutout <= "00000000";
	  when "100011000" => lutout <= "00000000";
	  when "100011001" => lutout <= "00000000";
	  when "100011010" => lutout <= "00000000";
	  when "100011011" => lutout <= "00000000";
	  when "100011100" => lutout <= "00000000";
	  when "100011101" => lutout <= "00000000";
	  when "100011110" => lutout <= "00000000";
	  when "100011111" => lutout <= "00000000";
	  when "100100000" => lutout <= "00000000";
	  when "100100001" => lutout <= "00000000";
	  when "100100010" => lutout <= "00000000";
	  when "100100011" => lutout <= "00000000";
	  when "100100100" => lutout <= "00000000";
	  when "100100101" => lutout <= "00000000";
	  when "100100110" => lutout <= "00000000";
	  when "100100111" => lutout <= "00000000";
	  when "100101000" => lutout <= "00000000";
	  when "100101001" => lutout <= "00000000";
	  when "100101010" => lutout <= "00000000";
	  when "100101011" => lutout <= "00000000";
	  when "100101100" => lutout <= "00000000";
	  when "100101101" => lutout <= "00000000";
	  when "100101110" => lutout <= "00000000";
	  when "100101111" => lutout <= "00000000";
	  when "100110000" => lutout <= "00000000";
	  when "100110001" => lutout <= "00000000";
	  when "100110010" => lutout <= "00000000";
	  when "100110011" => lutout <= "00000000";
	  when "100110100" => lutout <= "00000000";
	  when "100110101" => lutout <= "00000000";
	  when "100110110" => lutout <= "00000000";
	  when "100110111" => lutout <= "00000000";
	  when "100111000" => lutout <= "00000000";
	  when "100111001" => lutout <= "00000000";
	  when "100111010" => lutout <= "00000000";
	  when "100111011" => lutout <= "00000000";
	  when "100111100" => lutout <= "00000000";
	  when "100111101" => lutout <= "00000000";
	  when "100111110" => lutout <= "00000000";
	  when "100111111" => lutout <= "00000000";
	  when "101000000" => lutout <= "00000000";
	  when "101000001" => lutout <= "00000000";
	  when "101000010" => lutout <= "00000000";
	  when "101000011" => lutout <= "00000000";
	  when "101000100" => lutout <= "00000000";
	  when "101000101" => lutout <= "00000000";
	  when "101000110" => lutout <= "00000000";
	  when "101000111" => lutout <= "00000000";
	  when "101001000" => lutout <= "00000000";
	  when "101001001" => lutout <= "00000000";
	  when "101001010" => lutout <= "00000000";
	  when "101001011" => lutout <= "00000000";
	  when "101001100" => lutout <= "00000000";
	  when "101001101" => lutout <= "00000000";
	  when "101001110" => lutout <= "00000000";
	  when "101001111" => lutout <= "00000000";
	  when "101010000" => lutout <= "00000000";
	  when "101010001" => lutout <= "00000000";
	  when "101010010" => lutout <= "00000000";
	  when "101010011" => lutout <= "00000000";
	  when "101010100" => lutout <= "00000000";
	  when "101010101" => lutout <= "00000000";
	  when "101010110" => lutout <= "00000000";
	  when "101010111" => lutout <= "00000000";
	  when "101011000" => lutout <= "00000000";
	  when "101011001" => lutout <= "00000000";
	  when "101011010" => lutout <= "00000000";
	  when "101011011" => lutout <= "00000000";
	  when "101011100" => lutout <= "00000000";
	  when "101011101" => lutout <= "00000000";
	  when "101011110" => lutout <= "00000000";
	  when "101011111" => lutout <= "00000000";
	  when "101100000" => lutout <= "00000000";
	  when "101100001" => lutout <= "00000000";
	  when "101100010" => lutout <= "00000000";
	  when "101100011" => lutout <= "00000000";
	  when "101100100" => lutout <= "00000000";
	  when "101100101" => lutout <= "00000000";
	  when "101100110" => lutout <= "00000000";
	  when "101100111" => lutout <= "00000000";
	  when "101101000" => lutout <= "00000000";
	  when "101101001" => lutout <= "00000000";
	  when "101101010" => lutout <= "00000000";
	  when "101101011" => lutout <= "00000000";
	  when "101101100" => lutout <= "00000000";
	  when "101101101" => lutout <= "00000000";
	  when "101101110" => lutout <= "00000000";
	  when "101101111" => lutout <= "00000000";
	  when "101110000" => lutout <= "00000000";
	  when "101110001" => lutout <= "00000000";
	  when "101110010" => lutout <= "00000000";
	  when "101110011" => lutout <= "00000000";
	  when "101110100" => lutout <= "00000000";
	  when "101110101" => lutout <= "00000000";
	  when "101110110" => lutout <= "00000000";
	  when "101110111" => lutout <= "00000000";
	  when "101111000" => lutout <= "00000000";
	  when "101111001" => lutout <= "00000000";
	  when "101111010" => lutout <= "00000000";
	  when "101111011" => lutout <= "00000000";
	  when "101111100" => lutout <= "00000000";
	  when "101111101" => lutout <= "00000000";
	  when "101111110" => lutout <= "00000000";
	  when "101111111" => lutout <= "00000000";
	  when "110000000" => lutout <= "00000000";
	  when "110000001" => lutout <= "00000000";
	  when "110000010" => lutout <= "00000000";
	  when "110000011" => lutout <= "00000000";
	  when "110000100" => lutout <= "00000000";
	  when "110000101" => lutout <= "00000000";
	  when "110000110" => lutout <= "00000000";
	  when "110000111" => lutout <= "00000000";
	  when "110001000" => lutout <= "00000000";
	  when "110001001" => lutout <= "00000000";
	  when "110001010" => lutout <= "00000000";
	  when "110001011" => lutout <= "00000000";
	  when "110001100" => lutout <= "00000000";
	  when "110001101" => lutout <= "00000000";
	  when "110001110" => lutout <= "00000000";
	  when "110001111" => lutout <= "00000000";
	  when "110010000" => lutout <= "00000000";
	  when "110010001" => lutout <= "00000000";
	  when "110010010" => lutout <= "00000000";
	  when "110010011" => lutout <= "00000000";
	  when "110010100" => lutout <= "00000000";
	  when "110010101" => lutout <= "00000000";
	  when "110010110" => lutout <= "00000000";
	  when "110010111" => lutout <= "00000000";
	  when "110011000" => lutout <= "00000000";
	  when "110011001" => lutout <= "00000000";
	  when "110011010" => lutout <= "00000000";
	  when "110011011" => lutout <= "00000000";
	  when "110011100" => lutout <= "00000000";
	  when "110011101" => lutout <= "00000000";
	  when "110011110" => lutout <= "00000000";
	  when "110011111" => lutout <= "00000000";
	  when "110100000" => lutout <= "00000000";
	  when "110100001" => lutout <= "00000000";
	  when "110100010" => lutout <= "00000000";
	  when "110100011" => lutout <= "00000000";
	  when "110100100" => lutout <= "00000000";
	  when "110100101" => lutout <= "00000000";
	  when "110100110" => lutout <= "00000000";
	  when "110100111" => lutout <= "00000000";
	  when "110101000" => lutout <= "00000000";
	  when "110101001" => lutout <= "00000000";
	  when "110101010" => lutout <= "00000000";
	  when "110101011" => lutout <= "00000000";
	  when "110101100" => lutout <= "00000000";
	  when "110101101" => lutout <= "00000000";
	  when "110101110" => lutout <= "00000000";
	  when "110101111" => lutout <= "00000000";
	  when "110110000" => lutout <= "00000000";
	  when "110110001" => lutout <= "00000000";
	  when "110110010" => lutout <= "00000000";
	  when "110110011" => lutout <= "00000000";
	  when "110110100" => lutout <= "00000000";
	  when "110110101" => lutout <= "00000000";
	  when "110110110" => lutout <= "00000000";
	  when "110110111" => lutout <= "00000000";
	  when "110111000" => lutout <= "00000000";
	  when "110111001" => lutout <= "00000000";
	  when "110111010" => lutout <= "00000000";
	  when "110111011" => lutout <= "00000000";
	  when "110111100" => lutout <= "00000000";
	  when "110111101" => lutout <= "00000000";
	  when "110111110" => lutout <= "00000000";
	  when "110111111" => lutout <= "00000000";
	  when "111000000" => lutout <= "00000000";
	  when "111000001" => lutout <= "00000000";
	  when "111000010" => lutout <= "00000000";
	  when "111000011" => lutout <= "00000000";
	  when "111000100" => lutout <= "00000000";
	  when "111000101" => lutout <= "00000000";
	  when "111000110" => lutout <= "00000000";
	  when "111000111" => lutout <= "00000000";
	  when "111001000" => lutout <= "00000000";
	  when "111001001" => lutout <= "00000000";
	  when "111001010" => lutout <= "00000000";
	  when "111001011" => lutout <= "00000000";
	  when "111001100" => lutout <= "00000000";
	  when "111001101" => lutout <= "00000000";
	  when "111001110" => lutout <= "00000000";
	  when "111001111" => lutout <= "00000000";
	  when "111010000" => lutout <= "00000000";
	  when "111010001" => lutout <= "00000000";
	  when "111010010" => lutout <= "00000000";
	  when "111010011" => lutout <= "00000000";
	  when "111010100" => lutout <= "00000000";
	  when "111010101" => lutout <= "00000000";
	  when "111010110" => lutout <= "00000000";
	  when "111010111" => lutout <= "00000000";
	  when "111011000" => lutout <= "00000000";
	  when "111011001" => lutout <= "00000000";
	  when "111011010" => lutout <= "00000000";
	  when "111011011" => lutout <= "00000000";
	  when "111011100" => lutout <= "00000000";
	  when "111011101" => lutout <= "00000000";
	  when "111011110" => lutout <= "00000000";
	  when "111011111" => lutout <= "00000000";
	  when "111100000" => lutout <= "00000000";
	  when "111100001" => lutout <= "00000000";
	  when "111100010" => lutout <= "00000000";
	  when "111100011" => lutout <= "00000000";
	  when "111100100" => lutout <= "00000000";
	  when "111100101" => lutout <= "00000000";
	  when "111100110" => lutout <= "00000000";
	  when "111100111" => lutout <= "00000000";
	  when "111101000" => lutout <= "00000000";
	  when "111101001" => lutout <= "00000000";
	  when "111101010" => lutout <= "00000000";
	  when "111101011" => lutout <= "00000000";
	  when "111101100" => lutout <= "00000000";
	  when "111101101" => lutout <= "00000000";
	  when "111101110" => lutout <= "00000000";
	  when "111101111" => lutout <= "00000000";
	  when "111110000" => lutout <= "00000000";
	  when "111110001" => lutout <= "00000000";
	  when "111110010" => lutout <= "00000000";
	  when "111110011" => lutout <= "00000000";
	  when "111110100" => lutout <= "00000000";
	  when "111110101" => lutout <= "00000000";
	  when "111110110" => lutout <= "00000000";
	  when "111110111" => lutout <= "00000000";
	  when "111111000" => lutout <= "00000000";
	  when "111111001" => lutout <= "00000000";
	  when "111111010" => lutout <= "00000000";
	  when "111111011" => lutout <= "00000000";
	  when "111111100" => lutout <= "00000000";
	  when "111111101" => lutout <= "00000000";
	  when "111111110" => lutout <= "00000000";
	  when "111111111" => lutout <= "00000000";
	  when others => lutout <= "00000000"; 
    end case; 
   end process LUT; 


end Behavioral;
