library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;




entity test_PGA is
    Port ( SCLK : in std_logic;
           RCLK : in std_logic;
           SIN : in std_logic;
			  bouts: out std_logic_vector(10*8-1 downto 0));
end test_PGA;

architecture Behavioral of test_PGA is
-- simple systme to map the serial input stream to actual values for the
-- PGAs, filters, and input selection

   signal rbits, fbits : std_logic_vector(10*8-1 downto 0) := (others => '0'); 

begin

	process (SCLK) is
	begin
		if rising_edge(SCLK) then
			rbits <= rbits(10*8-2 downto 0) & SIN;
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
