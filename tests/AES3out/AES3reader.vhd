
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AES3reader is
    Port ( CLK : in std_logic;
           CLKEN : in std_logic;
           DIN : in std_logic; 
		 AOUT : out integer;
		 BOUT : out integer );
end AES3reader;

architecture Behavioral of AES3reader is
	signal subframe, subframel: std_logic_vector(63 downto 0)
		:= (others => '0');
	signal subframebits : std_logic_vector(27 downto 0)
		:= (others => '0'); 


begin

	main: process(CLK) is
	begin
		if rising_edge(CLK) then
			if CLKEN = '1' then
				subframe <= subframe(62 downto 0) & DIN;
			end if; 
		end if; 
	end process; 

	process is
	begin	   	
		while 1 = 1 loop
			wait until subframe(63 downto 56) = "00011101" or
					 subframe(63 downto 56) = "00011011" or
					 subframe(63 downto 56) = "00010111" or
					 subframe(63 downto 56) = "11100010" or
					 subframe(63 downto 56) = "11100100" or
					 subframe(63 downto 56) = "11101000";
			subframel <= subframe; 
			for i in 27 downto 0 loop
				if subframel(2*i+1 downto 2*i) = "00" or
					subframel(2*i+1 downto 2*i) = "11" then
					subframebits(27 - i) <= '0';
				else
					subframebits(27 - i) <= '1';
				end if; 

					
			end loop;
			AOUT <= TO_INTEGER(SIGNED(subframebits(15 downto 0)));
			
			 			
		end loop;
	end process; 


end Behavioral;
