library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.ALL;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serialize is
    Generic (filename : string := "input.dat"); 
    Port ( START : in std_logic;
           DOUT : out std_logic;
		 DONE : out std_logic);
end serialize;

architecture Behavioral of serialize is
-- SERIALIZE.VHD -- strictly behavioral implementation of
-- serializer for testbenches. We generate an internal 8 Mhz clock
-- and then 8b/10b encode the data from the input filename. 
-- That file has a '1' or a '0' based on whether or not this is
-- a K character, followed by 8 bits of data
-- 


   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal kchar : std_logic := '0';
   signal encdata : std_logic_vector(9 downto 0) := (others => '0');
   signal clk, encode : std_logic := '0'; 


   component encode8b10b IS
		port (
		din: IN std_logic_VECTOR(7 downto 0);
		kin: IN std_logic;
		clk: IN std_logic;
		dout: OUT std_logic_VECTOR(9 downto 0);
		ce: IN std_logic);
   END component;      
   signal pos : integer := 0; 
begin
   clk <= not clk after 62.5 ns; 

   encoder: encode8b10b port map (
   		din => data,
		kin => kchar,
		clk => clk,
		dout => encdata,
		ce => encode); 


   reading: process(clk) is
   	variable starting : std_logic := '0'; 
	variable ending : std_logic := '0';
	variable toencode : bit_vector(7 downto 0) ;
	variable tok : bit; 
	file inputfile : text open read_mode is filename;
	variable L: line; 

   begin
	if rising_edge(clk) then

	   if start = '1' then
	   	starting := '1';
	   end if; 
	   	
	   if pos = 9 then
	   	pos <= 0;
	   else
	   	pos <= pos + 1;
	   end if; 

	   if pos = 8 then
	   	if starting = '1' and (not endfile(inputfile)) then
		     readline(inputfile, L);
			read(L, tok); 
		   	read(L, toencode); 
			data <= TO_X01Z(toencode);
			kchar <= TO_X01Z(tok);  
		end if; 

	   end if; 

	   if endfile(inputfile) then
	   	done <= '1';
	   else
	   	done <= '0';
	   end if; 

	end if; 
	   if pos = 9 then
	   	encode <= '1';
	   else 
	   	encode <= '0';
	   end if; 
   end process reading; 

   DOUT <= encdata(pos);

end Behavioral;
