library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 
use std.textio.all; 


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity test_EEPROM is
    Generic (  FILEIN : string := "eeprom_in.dat"; 
    			FILEOUT : string := "eeprom_out.dat"); 
    Port ( CLK : in std_logic;
           CS : in std_logic;
           SCK : in std_logic;
		 SI : in std_logic;
		 SO : out std_logic; 
		 RESET : in std_logic;
		 SAVE : in std_logic);
end test_EEPROM;

architecture Behavioral of test_EEPROM is
-- test_EEPROM.VHD. A testbench implementation of the serial EEPROM
-- with the ability to read from and write the output to a file.
-- The data itself is actually kept in RAM. It's loaded from FILEIN
-- passed as a generic, and written to FILEOUT passed as a generic, 
-- following the rising_edge of SAVE. 

   signal address : std_logic_vector(11 downto 0) := (others => '0');
   signal numaddress : integer; 
   signal data : std_logic_vector(7 downto 0) := (others => '0');

   
   type storage_array is 
   	array ( 0 to 4095) of std_logic_vector(7 downto 0);

   signal read_byte, write_byte : std_logic_vector(7 downto 0) := (others => '0');

   signal bitpos : natural := 0;
   signal temp_byte : std_logic_vector(7 downto 0) :=  (others => '0'); 
	signal readmode : integer := 0;  -- 0 for write, 1 for read   
   signal testbyte, currentbyte : std_logic_vector(7 downto 0);
   type modes is (read, write);
   signal mode : modes ;
   signal write_enable : std_logic := '0'; 
   signal  tempbits : std_logic_vector(47 downto 0); 
begin
      
    

   -- if start
      -- get control byte
	 -- get address low byte
	 -- get address high byte
   main: process is

   	type load_file_type is file of std_logic_vector(7 downto 0);
	type save_file_type is file of std_logic_vector(7 downto 0);
	file load_file : text open read_mode is FILEIN;
	file save_file : text open write_mode is FILEOUT;
	variable WL, RL : line; 

	variable index : natural; 
	variable dword : bit_vector(7 downto 0); 
	variable PROM : storage_array := (others => "00000000"); 
	

   begin
     wait until falling_edge(RESET);
	   index:= 0;
	   while not endfile(load_file) loop
		 readline(load_file, RL);
		 read(RL, dword); 
		 PROM(index) := TO_X01(dword); 
		 index := index + 1;
	   end loop; 
	 

     -- falling edge starts cmd; read in 8 bits, then decide what to do
	while 0 < 1 loop 
		wait until falling_edge(CS) or rising_edge(SAVE);
		     if rising_edge(SAVE) then
			   for i in 0 to 4095 loop 
			   	 write (WL, TO_BITVECTOR(PROM(i)));
				 writeline(save_file, WL);
		  
			   end loop; 
			end if; 		 
			if falling_edge(CS) then
				-- new command start
				bitpos <= 0;
				wait for 1 ps;  
				if mode = write then
					write_enable <= '0';
				end if; 

				while bitpos < 47 loop
				   wait until rising_edge(CS) or rising_edge(SCK);
				   if rising_edge(CS) then
				   	bitpos <= 100;
					wait for 1 ps;  
				   elsif rising_edge(SCK) then
				     if bitpos < 48 then 
				   	   tempbits(bitpos) <= SI;
					end if;
					wait for 1 ns;  
					if bitpos = 7 then -- we have a full command
					   if tempbits(7 downto 0) = "11000000" then
					   	mode <= read; 
					   elsif tempbits(7 downto 0) = "01000000" then
					   	mode <= write; 
					   elsif tempbits(7 downto 0) = "01100000" then
					   	-- write enable;
						write_enable <= '1';
						mode <= read;  
						bitpos <= 100;
						wait for 1 ns;  
				        end if; 
					end if;
					
					if bitpos = 23 then -- we've gotten the full address
					   address <= tempbits(12) & tempbits(13) & tempbits(14) & tempbits(15) &
					   		    tempbits(16) & tempbits(17) & tempbits(18) & tempbits(19) & 
							    tempbits(20) & tempbits(21) & tempbits(22) & tempbits(23);
					   wait for 1 ns;  
					   numaddress <= to_integer(unsigned(address));
					   wait for 1 ns; 
					   if mode = read then 
					   	currentbyte <= PROM(numaddress); 
					   end if; 
					end if; 

					if bitpos > 22 and bitpos < 100 then 
						if mode = read then 
						   wait until falling_edge(SCK); 
						   SO <= currentbyte((bitpos - 23) mod 8);
						end if;
					end if; 

					if bitpos > 30 and bitpos < 100 and ((bitpos +1) mod 8) = 0 then 
						if mode = write then
						   if write_enable = '1' then
						       PROM(numaddress) := tempbits(bitpos downto bitpos - 7);
						   end if; 
						   numaddress <= numaddress + 1; 					   
						elsif mode = read then
						   numaddress <=numaddress + 1;
						   wait for 1 ns;  
						   currentbyte <= PROM(numaddress); 
						   wait for 1 ns; 
						   
						   SO <= currentbyte((bitpos - 23) mod 8);	
						   -- load new word
						end if; 
					end if;

					bitpos <= bitpos + 1;
					wait for 1 ns; 

				  end if;  
				end loop;
			end if; 
	end loop; 

	wait; 

   end process main; 




   
end Behavioral;
