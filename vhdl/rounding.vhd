library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rounding is
    Generic ( n: positive := 36); 
       Port ( ACCL : in std_logic_vector((n-1)+7 downto 0);
	         YRND : out std_logic_vector(22 downto 0));
end rounding;

architecture Behavioral of rounding is
-- ROUNDING.VHD -- system for convergent rounding of variable-width
-- input. 
   signal roundout : std_logic := '0';
     signal bigor_y: std_logic; 

begin
   lut: process(ACCL,  bigor_y) is
   begin
	  if(ACCL((n-15)-2)='1' and bigor_y = '0') then
	  	if ACCL((n-15)-1) = '1' then 
			roundout <= '1';
		else 
			roundout <= '0';
		end if;
	  else
	  	roundout <= ACCL((n-15)-2);
	  end if; 

   end process lut;
   
   YRND <=  ACCL((7+(n-1)) downto (n-16)) + ("0000000000000000000000" & roundout);



  bigor: process(ACCL) is
	  	variable x: std_logic ; 
  begin
  	for i in 0 to (n-15)-3 loop
	    if i = 0 then
	      	x := ACCL(0);
	    else
		 	x := x or ACCL(i);
		end if; 
	end loop;
	bigor_y <= x; 
  end process;  


end Behavioral;
