library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

-- CLOCKS.VHD -----------------------------------------------------
-- This generates all the clocks and clock-enables for the acquisiton
-- board from the single 16 MHz input clock. See "Soma Acquisition Board
-- Overview.ai" for a more detailed explanation. reset goes low once
-- all DLLs are locked. 

entity CLOCKS is
    Port ( CLKIN : in std_logic;
	 		  RESETIN: in std_logic; 
           CLK4X : out std_logic;
           CLK8 : out std_logic;
           INSAMPCLK : out std_logic;
           OUTSAMPCLK : out std_logic;
           OUTBYTE : out std_logic;
			  reset : out std_logic);
end clocks;

architecture Behavioral of clocks is
	signal clk2x_fb, clk2x_out, clk2x_outg, locked2x, locked2x_inv : std_logic; 
	signal clk4x_fb, clk4x_out, clk4x_outg, locked4x, locked4x_inv : std_logic; 


	signal insampletoggle, outsampletoggle, outbytetoggle : std_logic; 
	 

begin
	dll2x  : CLKDLL port map (clkin=>clkin,   clkfb=>clk2x_outg, rst=>resetin,
	                          clk0=>open, clk90=>open, clk180=>open, clk270=>open,
	                          clk2x=>clk2x_out, clkdv=>open, locked=>locked2x);
	clk2xg : BUFG   port map (I=>clk2x_out,   O=>clk2x_outg);
	locked2x_inv <= not locked2x; 

	dll4x  : CLKDLL port map (clkin=>clk2x_outg,   clkfb=>clk4x_outg, rst=>locked2x_inv,
	                          clk0=>open, clk90=>open, clk180=>open, clk270=>open,
	                          clk2x=>clk4x_out, clkdv=>open, locked=>locked4x);
	clk4xg : BUFG   port map (I=>clk4x_out,   O=>clk4x_outg);
	locked4x_inv <= not locked4x;

	CLK4X <= clk4x_out; 

	RESET <= locked4x_inv; 

	INSAMPCLK <= insampletoggle; 
	OUTSAMPCLK <= outsampletoggle;
	OUTBYTE <= outbytetoggle;

	clocks: process (clk4x_out, locked4x_inv) is
		variable countInSample : integer range 250 downto 0 := 0;
		variable countOutSample: integer range 2000 downto 0 := 0;
		variable countOutByte : integer range 80 downto 0 := 0; 

		 
	begin
		if locked4x_inv = '1' then
			countInSample := 0;
			countOutSample := 0; 
			insampletoggle <= '0'; 
		else
			if rising_edge(clk4x_out) then	 

				-- INSAMPLE -- every 250 clk4x				
				if countInSample = 249 then
					countInSample := 0;
					insampletoggle <= '1';
				else
					countInSample := countInSample +1;
					insampletoggle <= '0';
				end if;

				-- OUTSAMPLE -- every 2000 clk4x
				if countOutSample = 1999 then
					countOutSample := 0;
					outsampletoggle <= '1';
				else
					countOutSample := countOutSample +1;
					outsampletoggle <= '0';
				end if;

				-- OUTBYTE -- every 80 clk4x
				if countOutByte = 79 then
					countOutByte := 0;
					outbytetoggle <= '1';
				else
					countOutByte := countOutByte +1;
					outbytetoggle <= '0';
				end if;

			end if;
		end if;
	end process clocks; 

end Behavioral;
