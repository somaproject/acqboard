library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulator is
    Generic ( n: positive := 36); 
    Port ( CLK : in std_logic;
		 P : in std_logic_vector(n-1 downto 0);
           ACC : out std_logic_vector((n-1)+7 downto 0);
           CLR : in std_logic);
end accumulator;

architecture Behavioral of accumulator is
-- ACCUMULATOR.VHD -- extended precision fixed-point accumulator. 
-- note that we need separate accint signal because we can't read the
-- value of entity out signals. 
    signal accint, sum : std_logic_vector((n-1)+7 downto 0) := (others => '0');
    signal pl : std_logic_vector(n-1 downto 0) := (others => '0'); 
   

begin
	clock: process (CLK, clr) is
	begin
		if rising_edge(CLK) then
		   pl <= P; 
		   if clr = '0' then
		   	accint <= sum;
		   else 
		   	accint <= (others => '0');
		   end if;  

		end if; 
	
	
	end process clock;  

	ACC <= accint;

	adder: process(pl, accint) is
	begin
		sum <= SXT(pl, n) + accint; 
	end process adder; 



end Behavioral;
