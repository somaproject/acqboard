library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Loader is
    Port ( CLK : in std_logic;
           LOAD : in std_logic;
           DONE : out std_logic;
		 RESET : in std_logic; 
           SWE : out std_logic;
           FWE : out std_logic;
		 EEPROMEN : in std_logic; 
           ADDR : out std_logic_vector(9 downto 0);
           EEEN : out std_logic;
           EEDONE : in std_logic);
end Loader;

architecture Behavioral of Loader is
-- LOADER.VHD -- Basic FSM and address counter to load the contents of
-- the EEPROM into both the filter and the sample buffer. Note that
-- the address lines are combined with WEs to map filter and sample
-- buffer into the same address space, and data is stored in the 
-- eeprom so things can be easily read in. 
--
-- note that if EEPROMEN = 0, this function just returns done
   signal address : std_logic_vector(9 downto 0) := (others => '0');
   signal we : std_logic := '0';

   type states is (none, enable, ewait, write, incaddr, ldone);
   signal cs, ns : states := none;



begin
   FWE <= (not address(8)) and we;
   SWE <= address(8) and we;
   ADDR <= address;

   clock: process(CLK) is
   begin
   	if RESET = '1' then
		cs <= none;
	else
		if rising_edge(CLK) then
			cs <= ns;

			if cs = none then 
				address <= (others => '0');
			elsif cs = incaddr then
				address <= address + 1;
			end if; 

		end if;
	end if;
   end process clock; 


   fsm: process(cs, LOAD, EEDONE, address, EEPROMEN) is
   begin
   	case cs is
		when none => 
			EEEN <= '0';
			WE <= '0';
			DONE <= '0';
			if LOAD = '1' and EEPROMEN = '1' then
				ns <= enable;
			elsif LOAD = '1' and EEPROMEN = '0' then
				ns <= ldone;
			else 
				ns <= none;
			end if;
		when enable => 
			EEEN <= '1';
			WE <= '0';
			DONE <= '0';
			ns <= ewait;
		when ewait => 
			EEEN <= '0';
			WE <= '0';
			DONE <= '0';
			if EEDONE = '1' then
				ns <= write;
			else
				ns <= ewait;
			end if;		
		when write => 
			EEEN <= '0';
			WE <= '1';
			DONE <= '0';
			ns <= incaddr;		
		when incaddr => 
			EEEN <= '0';
			WE <= '0';
			DONE <= '0';
			if address = "101111111" then
				ns <= ldone;
			else
				ns <= enable;
			end if;
		when ldone => 
			EEEN <= '0';
			WE <= '0';
			DONE <= '1';
			ns <= none;		
		when others => 
			EEEN <= '0';
			WE <= '0';
			DONE <= '1';
			ns <= none;
	  end case;
   end process fsm; 
end Behavioral;
