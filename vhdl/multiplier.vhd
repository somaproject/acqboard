library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is	   
    Generic ( n: positive := 24); 
    Port ( CLK : in std_logic;
           A : in std_logic_vector(15 downto 0);
           B : in std_logic_vector(21 downto 0);
           P : out std_logic_vector(n-1 downto 0));
end multiplier;

architecture Behavioral of multiplier is
-- MULTIPLIER.VHD -- configurable-width fixed-precision multiplier. 
-- This has a latency of five ticks, because the synthesis tools
-- will push those extra registers at the inputs and outputs
-- into the multiplier itself, giving us a pipelined implementation
-- for basically no effort. 

    signal al : std_logic_vector(15 downto 0) := (others => '0');
    signal bl: std_logic_vector(21 downto 0) := (others => '0');
    signal lp : std_logic_vector(37 downto 0) := (others => '0'); 
    signal p1, p2, p3 : std_logic_vector(n-1 downto 0) := (others => '0');

begin
	process(CLK) is
	begin
		if rising_edge(CLK) then
			--al <= a;
			--bl <= b;
			p1 <= lp(36 downto (36-n+1));
			p2 <= p1;
			P <= p2; 
		end if;
	end process; 

    lp <= a * b;  


end Behavioral;
