library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity offset is
    Port ( CLK : in std_logic;				   
           DIN : in std_logic_vector(15 downto 0);
		 DOUT : out std_logic_vector(15 downto 0);
		 CIN : in std_logic_vector(3 downto 0);
		 COUT : out std_logic_vector(3 downto 0);
		 RESET : in std_logic; 
		 WEIN : in std_logic;
		 WEOUT : out std_logic; 
		 OSC : in std_logic_vector(3 downto 0);
		 OSD : in std_logic_vector(15 downto 0);
		 OSWE : in std_logic;
		 OSEN : in std_logic);

end offset;

architecture Behavioral of offset is
-- OFFSET.VHD -- subtracts channel-dependent offsets


	signal chanl, chanll, chanlll :
			std_logic_vector(3 downto 0)  := (others => '0');
	signal wel, well, welll: std_logic := '0';
	signal  aus, as, ain, bin, osout, youtmux :
			std_logic_vector(15 downto 0) := (others => '0');
	signal yout, youtl : std_logic_vector(16 downto 0) := (others => '0');
	
	-- offset LUT signals
	signal os1, os2, os3, os4, os5, os6, os7, os8, os9, os10, osdatar : 
			std_logic_vector(15 downto 0) := (others => '0');
	signal oschanr : std_logic_vector(3 downto 0) := (others => '0');



begin
	clock: process (CLK, RESET,  aus, as, yout,  
				OSWE, OSD, OSC) is
	begin
		if rising_edge(CLK) then
		   aus <= din; 
		   ain <= as;
		   if osen = '1' then 
		   	  bin <= osdatar;
		   else
		   	  bin <= (others => '0');
		   end if; 
		   youtl <= yout;
		   DOUT <= youtmux; 

		   -- pipeline stages for channel, write-enable
		   chanl <= cin;
		   chanll <= chanl;
		   chanlll <= chanll;
		   COUT <= chanlll;
		   wel <= wein;
		   well <= wel;
		   welll <= well;
		   WEOUT <= welll;


		   -- latch in offset values
		   if OSWE = '1' then 
		   	case OSC is
				when "0000" => os1 <= OSD;
				when "0001" => os2 <= OSD;
				when "0010" => os3 <= OSD;
				when "0011" => os4 <= OSD;
				when "0100" => os5 <= OSD;
				when "0101" => os6 <= OSD;
				when "0110" => os7 <= OSD;
				when "0111" => os8 <= OSD;
				when "1000" => os9 <= OSD;
				when "1001" => os10 <= OSD;
				when others => Null;
			end case;
		   end if;
		end if; 
	end process clock; 


     -- twos-complementer
		as <= aus - "1000000000000000"; 
	
	-- adder 
		yout <= (ain(15) & ain) + (bin(15) & bin);
	
	-- output overflow detection
		youtmux <= youtl(15 downto 0) when youtl(16 downto 15) = "00" else
				 "1000000000000000" when youtl(16 downto 15) = "01" else
				 "0111111111111111" when youtl(16 downto 15) = "10" else
				 youtl(15 downto 0); 

	-- outputs of offset LUT
		osdatar <= os1 when chanl = "0000" else
				 os2 when chanl = "0001" else
				 os3 when chanl = "0010" else
				 os4 when chanl = "0011" else
				 os5 when chanl = "0100" else
				 os6 when chanl = "0101" else
				 os7 when chanl = "0110" else
				 os8 when chanl = "0111" else
				 os9 when chanl = "1000" else
				 os10 when chanl = "1001" else
				 "0000000000000000";


																																											
end Behavioral;
																														    						