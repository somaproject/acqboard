library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

-- FILTER TEST --------------------------
--    designed to only test the filtering capabilities of the system. 
--    NOT FOR SYNTHESIS!


entity filter_test is
    Port ( CONVST : out std_logic ;
           CLKIN : in std_logic;
			  RESETIN: in std_logic; 
           DATAIN : in std_logic_vector(13 downto 0);
           OEB : out std_logic_vector(9 downto 0);
			  OUTBYTEOUT : out std_logic; 
           MACRND : out std_logic_vector(15 downto 0));
end filter_test;

architecture Behavioral of filter_test is

	signal clk2x, clk8, insampclk, outsampclk, outbyte, reset : std_logic; 
	signal sampcnt: std_logic_vector(6 downto 0);
	signal addrb7, clr, addra7 : std_logic;
	signal web, dots : std_logic_vector(4 downto 0); 
   signal xd: std_logic_vector(13 downto 0); 
	signal hd : std_logic_vector(17 downto 0); 

	component CLOCKS is
	    Port ( CLKIN : in std_logic;
		 		  RESETIN: in std_logic; 
	           CLK2X : out std_logic;
	           CLK8 : out std_logic;
	           INSAMPCLK : out std_logic;
	           OUTSAMPCLK : out std_logic;
	           OUTBYTE : out std_logic;
				  reset : out std_logic);
	end component;

	component INPUT is
	    Port ( CLK2X : in std_logic;
	           INSAMPCLK : in std_logic;
	           SAMPCNT : out std_logic_vector(6 downto 0);
	           ADDRB7 : out std_logic;
				  RESET : in std_logic; 
				  CONVST: out std_logic := '1'; 
	           WEB : out std_logic_vector(4 downto 0);
	           OEB : out std_logic_vector(9 downto 0));
	end component;

	component XSEL is
	    Port ( OUTSAMPCLK : in std_logic;
	           CLK2X : in std_logic;
	           CLR : in std_logic;
	           SAMPCNT : in std_logic_vector(6 downto 0);
	           ADDRA7 : in std_logic;
				  RESET : in std_logic; 
	           XD : out std_logic_vector(13 downto 0);
	           DOTS : in std_logic_vector(4 downto 0);
	           DATAIN : in std_logic_vector(13 downto 0);
	           WEB : in std_logic_vector(4 downto 0);
	           ADDRB : in std_logic_vector(7 downto 0));
	end component;

	component HSEL is
	    Port ( CLK2X : in std_logic;
	           CLR : in std_logic;
				  RESET : in std_logic; 
	           HD : out std_logic_vector(17 downto 0));
	end component;

 	component RMAC is
	    Port ( CLK2X : in std_logic;
	           CLR : in std_logic;
	           XD : in std_logic_vector(13 downto 0);
	           HD : in std_logic_vector(17 downto 0);
	           MACRND : out std_logic_vector(15 downto 0));
	end component;

	component rmacfsm is
	    Port ( CLK2X : in std_logic;
	           RESET : in std_logic;
	           OUTSAMPCLK : in std_logic;
	           OUTBYTE : in std_logic;
	           CLR : out std_logic;
	           DOTS : out std_logic_vector(4 downto 0);
				  MACMSB : out std_logic; 
	           ADDRA7 : out std_logic);
	end component;
begin

	clock: clocks port map (
		CLKIN => CLKIN,
		RESETIN => RESETIN,
		CLK2X => clk2x,
		CLK8 => clk8,
		INSAMPCLK => insampclk,
		OUTSAMPCLK => outsampclk,
		OUTBYTE => outbyte,
		RESET => reset);

	inputs: input port map (
		CLK2X => clk2x,
		INSAMPCLK => insampclk,
		SAMPCNT => sampcnt,
		ADDRB7 => addrb7,
		RESET => reset,
		CONVST => convst,
		WEB => web,
		OEB => OEB);

	xselent: xsel port map (
		OUTSAMPCLK => outsampclk,
		CLK2X => clk2x,
		CLR =>  clr,
		SAMPCNT => sampcnt,
		ADDRA7 => addra7,
		RESET => reset,
		XD =>  xd,
		DOTS => dots,
		DATAIN => DATAIN,
		WEB => web,
		ADDRB(7)=> addrb7,
		ADDRB(6 downto 0) =>  sampcnt); 

	hselent: hsel port map (
		CLK2X => clk2x,
		CLR => clr,
		RESET => reset,
		HD => hd);

  	rmacent : rmac port map (
		CLK2X => clk2x,
		CLR => clr,
		XD => xd,
		HD => hd,
		MACRND =>  MACRND); 

	rmacfsment : rmacfsm port map (
		CLK2X => clk2x,
		RESET => reset, 
		OUTSAMPCLK => outsampclk,
		OUTBYTE => outbyte,
		CLR => clr,
		DOTS => dots,
		ADDRA7 => addra7); 



	OUTBYTEOUT <= outbyte; 




end Behavioral;
