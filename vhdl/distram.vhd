library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity distRAM is
    Port ( CLK : in std_logic;
           WE : in std_logic;
           A : in std_logic_vector(3 downto 0);
           DI : in std_logic;
           DO : out std_logic);
end distRAM;


architecture Behavioral of distRAM is
-- DISTRAM.VHD -- a 16x1bit ram to be implemented (hopefully) using a single
-- LUT.  
   type ram_type is array(15 downto 0) of std_logic;
   signal RAM : ram_type := "0000000000000000";

begin
   process(CLK) is
   begin
   	if rising_edge(CLK) then 
	   if WE = '1' then 
	   	RAM(conv_integer(A)) <= DI;
	   end if;

	end if;
   end process;

   DO <= RAM(conv_integer(a));

end Behavioral;
