library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity acqboard is
    Port ( CLKIN : in std_logic;
           ADCIN : in std_logic_vector(4 downto 0);
           ADCCLK : out std_logic;
           ADCCS : out std_logic;
           ADCCONVST : out std_logic;
           PGARCK : out std_logic;
           PGASRCK : out std_logic;
           PGASERA : out std_logic;
           EESCL : out std_logic;
           EESCA : inout std_logic;
           FIBERIN : in std_logic;
           FIBEROUT : out std_logic;
           RESET : in std_logic);
end acqboard;

architecture Behavioral of acqboard is
-- ACQBOARD.VHD -- master file for entire Acquisition Board FPGA. 
-- See Overview.ai for details. 

-- signals

-- clock-related signals
   signal clk, clk8, insample, outsample, outbyte, i2cclk : 
   	 std_logic := '0';

-- pga and input select signals
   signal gain : std_logic_vector(2 downto 0) := (others => '0');
   signal filter : std_logic_vector(1 downto 0) := (others => '0'); 
   signal pgachan : std_logic_vector(3 downto 0) := (others => '0');
   signal gset, iset, fset : std_logic := '0';
   signal isel : std_logic_vector(3 downto 0) := (others => '0');

-- loader and EEPROM-related signals
   signal edin, edout : std_logic_vector(15 downto 0);
   signal laddr, ewaddr, ea : std_logic_vector(10 downto 0) := (others => '0');
   signal edone, ceen, een, len : std_logic := '0';
   signal lfwe, lswe, load, ldone : std_logic := '0';

-- offset-connected signals from input, to sample buffer, and control
   signal din, dout : std_logic_vector(15 downto 0) := (others => '0');
   signal cin, cout : std_logic_vector(3 downto 0) := (others => '0');
   signal wein, weout : std_logic  := '0';
   signal osen, oswe : std_logic := '0';

-- control signals
   
   signal bufsel, eesel : std_logic := '0';

-- buffer signals
   signal bdin : std_logic_vector (15 downto 0) := (others => '0');
   signal bwe : std_logic := '0';
   signal ain : std_logic_vector(6 downto 0) := (others => '0'); 

-- MAC & MAC control signals
   signal x, y : std_logic_vector(15 downto 0) := (others => '0');
   signal xa, xbase, ha, sample : 
   	     std_logic_vector(6 downto 0) := (others => '0');
   signal h : std_logic_vector(21 downto 0) := (others => '0');
   signal startmac, macdone : std_logic := '0';
   signal macchan : std_logic_vector(3 downto 0) := (others => '0');

-- component definitions
	component input is
	    Port ( CLK : in std_logic;				   
	           INSAMPLE : in std_logic;
			 RESET : in std_logic; 
	           CONVST : out std_logic;
	           ADCCS : out std_logic;
	           SCLK : out std_logic;
	           SIN : in std_logic_vector(4 downto 0);
	           DATA : out std_logic_vector(15 downto 0);
	           CHAN : out std_logic_vector(3 downto 0);
	           WE : out std_logic);

	end component;

	component offset is
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

	end component;

	component samplebuffer is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           DIN : in std_logic_vector(15 downto 0);
	           CHANIN : in std_logic_vector(3 downto 0);
	           WE : in std_logic;
	           AIN : in std_logic_vector(6 downto 0);
	           DOUT : out std_logic_vector(15 downto 0);
	           AOUT : in std_logic_vector(6 downto 0);
	           CHANOUT : in std_logic_vector(3 downto 0));
	end component;

	component RMACcontrol is
	    Port ( CLK : in std_logic;
	           INSAMPLE : in std_logic;
	           OUTSAMPLE : in std_logic;
	           RESET : in std_logic;
	           STARTMAC : out std_logic;
	           MACDONE : in std_logic;
	           SAMPLE : out std_logic_vector(6 downto 0);
	           SAMPBASE : out std_logic_vector(6 downto 0);
	           RMACCHAN : out std_logic_vector(3 downto 0));
	end component;

	component FilterArray is
	    Port ( CLK : in std_logic;
	           RESET : in std_logic;
	           WE : in std_logic;
	           H : out std_logic_vector(21 downto 0);
	           HA : in std_logic_vector(6 downto 0);
	           AIN : in std_logic_vector(7 downto 0);
	           DIN : in std_logic_vector(15 downto 0));
	end component;

	component RMAC is
	    Port ( CLK : in std_logic;
	           X : in std_logic_vector(15 downto 0);
	           XA : out std_logic_vector(6 downto 0);
	           H : in std_logic_vector(21 downto 0);
	           HA : out std_logic_vector(6 downto 0);
	           XBASE : in std_logic_vector(6 downto 0);
	           STARTMAC : in std_logic;
			 MACDONE  : out std_logic; 
			 RESET : in std_logic; 
	           Y : out std_logic_vector(15 downto 0));
	end component;

	component PGAload is
	    Port ( CLK : in std_logic;
	    		 RESET : in std_logic; 
	           SCLK : out std_logic;
	           RCLK : out std_logic;
	           SOUT : out std_logic;
	           CHAN : in std_logic_vector(3 downto 0);
			 FILTER : in std_logic_vector(1 downto 0); 
	           GAIN : in std_logic_vector(2 downto 0);
	           GSET : in std_logic;
	           ISET : in std_logic;
			 FSET : in std_logic; 
	           ISEL : in std_logic_vector(3 downto 0));
	end component;


begin

		


end Behavioral;
