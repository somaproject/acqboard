library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;




entity PGA is
    Port ( SCLK : in std_logic;
           RCLK : in std_logic;
           SIN : in std_logic;
		 BOUTS: out std_logic_vector(6*8-1 downto 0) );
end  PGA;

architecture Behavioral of PGA is
-- simple systme to map the serial input stream to actual values for the
-- PGAs, filters, and input selection

   signal rbits, fbits : std_logic_vector(6*8-1 downto 0) := (others => '0'); 

begin

	process (SCLK) is
	begin
		if rising_edge(SCLK) then
			rbits <= rbits(6*8-2 downto 0) & SIN;42

		end if;
	end process; 



	process (RCLK) is
	begin
		if rising_edge(RCLK) then
			fbits <= rbits; 
		end if;
	end process; 
	bouts <= fbits; 



end Behavioral;
