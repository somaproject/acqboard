library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is
    Port ( CLK2X : in std_logic;
           X : in std_logic_vector(15 downto 0);
           H : in std_logic_vector(21 downto 0);
           Y : out std_logic_vector(26 downto 0));
end multiplier;

architecture Behavioral of multiplier is
    signal xl, x1 : std_logic_vector(15 downto 0) := (others => '0');
    signal hl, h1: std_logic_vector(21 downto 0) := (others => '0');
    signal ly, y1, y2 : std_logic_vector(27 downto 0) := (others => '0'); 

begin
	process(CLK2X) is
	begin
		if rising_edge(CLK2X) then
			x1 <= X;
			xl <= x1;
			h1 <= H;
			hl <= h1; 
			y1 <= ly;
			y <= y1(26 downto 0);
		end if;
	end process; 

    ly <= xl * hl;  


end Behavioral;
