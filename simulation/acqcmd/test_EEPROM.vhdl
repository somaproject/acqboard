
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.ALL;

use IEEE.numeric_std.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_EEPROM is
    Port ( SCK : in std_logic;
           SO : out std_logic;
           SI : in std_logic;
           CS : in std_logic;
           ADDR : in integer;
			  DOUT : out integer;
			  DIN : in integer; 
			  WE : in std_logic);
end test_EEPROM;

architecture Behavioral of test_EEPROM is
-- test_EEPROM: simple eeprom implmenetation that lets us also
-- read and write values externally. 

	signal areg: std_logic_vector(15 downto 0) := (others => '0'); 
	signal do, di : std_logic_vector(7 downto 0) := (others => '0');
	signal ir : std_logic_vector(7 downto 0) := (others => '0'); 

   type storage_array is 
   	array ( 0 to 4095) of std_logic_vector(7 downto 0);

	signal bitpos : integer := 0; 

	signal writeenable : std_logic := '0'; 
	 
begin
		
	 
				

	process(SCK, ADDR, WE, DIN,  areg, CS) is
		variable ram : storage_array := (others => X"00"); 

	begin

		--if rising_edge(RE) then
			DOUT <= TO_INTEGER(unsigned(ram(TO_INTEGER(unsigned(areg)))));
			do <= ram(TO_INTEGER(unsigned(areg))); 
		--end if; 

		if rising_edge(sck) then
			if cs = '1' then
				bitpos <= 0;
			else
				bitpos <= bitpos + 1;
			end if; 
		
			-- instruction
			if bitpos < 8 then
				ir <=  ir(6 downto 0 ) & SI;
			end if; 

			-- address
			if bitpos > 7 and bitpos < 24 then
				areg <= areg(14 downto 0) & SI; 
			end if; 

			if bitpos >23 and bitpos < 32 then 
				SO <= do(7-(bitpos - 24)); 
			end if; 

			if bitpos >23 and bitpos < 32 then 
				di(7-(bitpos - 24)) <= SI; 
			end if; 


		end if; 

		if rising_edge(WE) then
			ram(addr) := std_logic_vector(to_signed(din, 16))
		end if; 

		if rising_edge(CS) then
			-- here's where we check to commit, etc. 
			if ir = "00000110" then
				writeenable <= '1';
			end if; 

			if ir = "00000010" and writeenable = '1' then
				ram(TO_INTEGER(unsigned(areg))) := di; 
				writeenable <= '0'; 
			end if; 

	  end if;
			
	end process; 

end Behavioral;
