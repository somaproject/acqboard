library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity acqboard is
  port ( CLKIN     : in  std_logic;
         ADCSDIA   : in  std_logic;
         ADCSDIB   : in  std_logic;
         ADCSCK    : out std_logic;
         ADCCNV    : out std_logic;
         PGARCK    : out std_logic;
         PGASRCK   : out std_logic;
         PGASERA   : out std_logic;
         ESI       : out std_logic;
         ESCK      : out std_logic;
         ECS       : out std_logic;
         ESO       : in  std_logic;
         EEPROMLEN : in  std_logic;
         FIBERIN   : in  std_logic;
         FIBEROUT  : out std_logic;
         CLK8_OUT  : out std_logic;
         LEDCMD    : out std_logic;
         LEDLINK   : out std_logic);
end acqboard;

architecture Behavioral of acqboard is
-- ACQBOARD.VHD : master file for entire Acquisition Board FPGA.
-- See FPGA.svg for details.

-- signals
  signal reset     : std_logic := '1';
  signal debugdata : std_logic_vector(15 downto 0);
  signal debugen   : std_logic := '0';
-- clock-related signals
  signal clk, clk8, insample, outsample, outbyte, spiclk :
    std_logic                  := '0';

-- pga and input select signals
  signal gain         : std_logic_vector(2 downto 0) := (others => '0');
  signal filter       : std_logic                    := '0';
  signal pgachan      : std_logic_vector(3 downto 0) := (others => '0');
  signal gset, iset   : std_logic                    := '0';
  signal fset, pgarst : std_logic                    := '0';
  signal isel         : std_logic_vector(1 downto 0) := (others => '0');

-- loader and EEPROM-related signals
  signal edin, edout   : std_logic_vector(15 downto 0);
  signal laddr         : std_logic_vector(9 downto 0)  := (others => '0');
  signal ewaddr        : std_logic_vector(10 downto 0) := (others => '0');
  signal ea            : std_logic_vector(10 downto 0) := (others => '0');
  signal edone, ceen   : std_logic                     := '0';
  signal een, len, erw : std_logic                     := '0';
  signal lfwe, lswe    : std_logic                     := '0';
  signal load, ldone   : std_logic                     := '0';

-- offset-connected signals from input, to sample buffer, and control
  signal din, dout  : std_logic_vector(15 downto 0) := (others => '0');
  signal cin, cout  : std_logic_vector(3 downto 0)  := (others => '0');
  signal weout      : std_logic                     := '0';
  signal osen, oswe : std_logic                     := '0';

-- control signals

  signal bufsel, eesel : std_logic := '0';

-- buffer signals
  signal bin : std_logic_vector (15 downto 0) := (others => '0');
  signal bwe : std_logic                      := '0';
  signal ain : std_logic_vector(7 downto 0)   := (others => '0');

-- MAC & MAC control signals
  signal x, ymac, y        : std_logic_vector(15 downto 0) := (others => '0');
  signal xa, xabase, ha, sample :
    std_logic_vector(7 downto 0)                           := (others => '0');
  signal yenmac, yen       : std_logic                     := '0';
  signal h                 : std_logic_vector(21 downto 0) := (others => '0');
  signal startmac, macdone : std_logic                     := '0';
  signal macchan           : std_logic_vector(3 downto 0)  := (others => '0');
  signal sampouten         : std_logic                     := '0';

-- raw signals
  signal yraw    : std_logic_vector(15 downto 0) := (others => '0');
  signal rawsel  : std_logic                     := '0';
  signal rawchan : std_logic_vector(3 downto 0)  := (others => '0');
  signal yenraw  : std_logic                     := '0';

-- command-related signals
  signal cmddata         : std_logic_vector(31 downto 0) := (others => '0');
  signal cmd             : std_logic_vector(3 downto 0)  := (others => '0');
  signal newcmd, pending : std_logic                     := '0';
  signal cmdid           : std_logic_vector(3 downto 0)  := (others => '0');
  signal chksum          : std_logic_vector(7 downto 0)  := (others => '0');
  signal cmdsuccess      : std_logic                     := '0';
  signal cmddone         : std_logic                     := '0';
  signal cmdsts          : std_logic_vector(3 downto 0)  := (others => '0');
  signal mode            : std_logic_vector(1 downto 0)  := (others => '0');

  signal jtag1, jtag2 : std_logic_vector(63 downto 0) := (others => '0');
  


-- component definitions

  component STARTUP_VIRTEX
    port (GSR : in std_logic);
  end component;


  component TOC
    port (O : out std_logic);
  end component;


  component clocks
    port ( CLKIN     : in  std_logic;
           CLK       : out std_logic;
           CLK8      : out std_logic;
           RESET     : in  std_logic;
           INSAMPLE  : out std_logic;
           OUTSAMPLE : out std_logic;
           OUTBYTE   : out std_logic;
           SPICLK    : out std_logic);
  end component;

  component input
    port ( CLK      : in  std_logic;
           INSAMPLE : in  std_logic;
           RESET    : in  std_logic;
           CNV      : out std_logic;
           SCK      : out std_logic;
           SDIA     : in  std_logic;
           SDIB     : in  std_logic;
           DOUT     : out std_logic_vector(15 downto 0);
           COUT     : out std_logic_vector(3 downto 0);
           WEOUT    : out std_logic;
           OSC      : in  std_logic_vector(3 downto 0);
           OSEN     : in  std_logic;
           OSRST    : in  std_logic;
           OSWE     : in  std_logic;
           OSD      : in  std_logic_vector(15 downto 0)
           );

  end component;

  component samplebuffer
    port ( CLK       : in  std_logic;
           RESET     : in  std_logic;
           DIN       : in  std_logic_vector(15 downto 0);
           CHANIN    : in  std_logic_vector(3 downto 0);
           WE        : in  std_logic;
           AIN       : in  std_logic_vector(7 downto 0);
           DOUT      : out std_logic_vector(15 downto 0);
           AOUT      : in  std_logic_vector(7 downto 0);
           SAMPOUTEN : in  std_logic;
           ALLCHAN   : in  std_logic;
           CHANOUT   : in  std_logic_vector(3 downto 0));
  end component;

  component RMACcontrol
    port ( CLK       : in  std_logic;
           INSAMPLE  : in  std_logic;
           OUTSAMPLE : in  std_logic;
           OUTBYTE   : in  std_logic;
           RESET     : in  std_logic;
           STARTMAC  : out std_logic;
           MACDONE   : in  std_logic;
           SAMPLE    : out std_logic_vector(7 downto 0);
           SAMPBASE  : out std_logic_vector(7 downto 0);
           SAMPOUTEN : out std_logic;
           RMACCHAN  : out std_logic_vector(3 downto 0));
  end component;

  component FilterArray
    port ( CLK   : in  std_logic;
           RESET : in  std_logic;
           WE    : in  std_logic;
           H     : out std_logic_vector(21 downto 0);
           HA    : in  std_logic_vector(7 downto 0);
           AIN   : in  std_logic_vector(8 downto 0);
           DIN   : in  std_logic_vector(15 downto 0));
  end component;

  component RMAC
    port ( CLK      : in  std_logic;
           X        : in  std_logic_vector(15 downto 0);
           XA       : out std_logic_vector(7 downto 0);
           H        : in  std_logic_vector(21 downto 0);
           HA       : out std_logic_vector(7 downto 0);
           XBASE    : in  std_logic_vector(7 downto 0);
           STARTMAC : in  std_logic;
           MACDONE  : out std_logic;
           RESET    : in  std_logic;
           Y        : out std_logic_vector(15 downto 0));
  end component;

  component PGAload
    port ( CLK      : in  std_logic;
           RESET    : in  std_logic;
           SCLK     : out std_logic;
           RCLK     : out std_logic;
           SOUT     : out std_logic;
           CHAN     : in  std_logic_vector(3 downto 0);
           FILTER   : in  std_logic;
           GAIN     : in  std_logic_vector(2 downto 0);
           GSET     : in  std_logic;
           ISET     : in  std_logic;
           FSET     : in  std_logic;
           PGARESET : in  std_logic;
           ISEL     : in  std_logic_vector(1 downto 0));
  end component;


  component FiberTX
    port ( CLK        : in  std_logic;
           CLK8       : in  std_logic;
           RESET      : in  std_logic;
           OUTSAMPLE  : in  std_logic;
           FIBEROUT   : out std_logic;
           CMDDONE    : in  std_logic;
           Y          : in  std_logic_vector(15 downto 0);
           YEN        : in  std_logic;
           CMDSTS     : in  std_logic_vector(3 downto 0);
           CMDID      : in  std_logic_vector(3 downto 0);
           CMDSUCCESS : in  std_logic;
           OUTBYTE    : in  std_logic;
           CHKSUM     : in  std_logic_vector(7 downto 0)
           );
  end component;

  component FiberRX
    port ( CLK     : in  std_logic;
           FIBERIN : in  std_logic;
           RESET   : in  std_logic;
           DATA    : out std_logic_vector(31 downto 0);
           CMD     : out std_logic_vector(3 downto 0);
           NEWCMD  : out std_logic;
           PENDING : in  std_logic;
           CMDID   : out std_logic_vector(3 downto 0);
           CHKSUM  : out std_logic_vector(7 downto 0);
           LINKUP : out std_logic);
  end component;

  component Loader
    port ( CLK      : in  std_logic;
           LOAD     : in  std_logic;
           DONE     : out std_logic;
           RESET    : in  std_logic;
           SWE      : out std_logic;
           FWE      : out std_logic;
           EEPROMEN : in  std_logic;
           ADDR     : out std_logic_vector(9 downto 0);
           EEEN     : out std_logic;
           EEDONE   : in  std_logic);
  end component;

  component EEPROMio
    port ( CLK    : in  std_logic;
           RESET  : in  std_logic;
           SPICLK : in  std_logic;
           DOUT   : out std_logic_vector(15 downto 0);
           DIN    : in  std_logic_vector(15 downto 0);
           ADDR   : in  std_logic_vector(10 downto 0);
           WR     : in  std_logic;
           EN     : in  std_logic;
           DONE   : out std_logic;
           ESCK   : out std_logic;
           ECS    : out std_logic;
           ESI    : out std_logic;
           ESO    : in  std_logic);
  end component;

  component Control
    port ( CLK        : in  std_logic;
           RESET      : in  std_logic;
           DATA       : in  std_logic_vector(31 downto 0);
           CMD        : in  std_logic_vector(3 downto 0);
           NEWCMD     : in  std_logic;
           CMDSTS     : out std_logic_vector(3 downto 0);
           CMDDONE    : out std_logic;
           PGACHAN    : out std_logic_vector(3 downto 0);
           PGAGAIN    : out std_logic_vector(2 downto 0);
           PGAISEL    : out std_logic_vector(1 downto 0);
           PGAFIL     : out std_logic;
           GSET       : out std_logic;
           ISET       : out std_logic;
           FSET       : out std_logic;
           PGARESET   : out std_logic;
           EADDR      : out std_logic_vector(10 downto 0);
           EEN        : out std_logic;
           EDONE      : in  std_logic;
           ERW        : out std_logic;
           EDATA      : out std_logic_vector(15 downto 0);
           EESEL      : out std_logic;
           BUFSEL     : out std_logic;
           CMDSUCCESS : out std_logic;
           RAWSEL     : out std_logic;
           RAWCHAN    : out std_logic_vector(3 downto 0);
           OSEN       : out std_logic;
           OSWE       : out std_logic;
           LOAD       : out std_logic;
           PENDING    : out std_logic;
           LDONE      : in  std_logic;
           MODEOUT    : out std_logic_vector(1 downto 0));
  end component;

  component raw
    port ( CLK  : in  std_logic;
           WEIN : in  std_logic;
           CIN  : in  std_logic_vector(3 downto 0);
           DIN  : in  std_logic_vector(15 downto 0);
           CHAN : in  std_logic_vector(3 downto 0);
           Y    : out std_logic_vector(15 downto 0);
           YEN  : out std_logic);
  end component;

  component jtaginterface
    generic (
      JTAG1N :    integer := 32;
      JTAG2N :    integer := 32);
    port (
      CLK    : in std_logic;
      DIN1   : in std_logic_vector(JTAG1N-1 downto 0);
      DIN2   : in std_logic_vector(JTAG2N-1 downto 0)
      );
  end component;

begin
  U1 : TOC port map (O => reset);

  clocks_inst : clocks port map (
    CLKIN     => CLKIN,
    CLK       => clk,
    CLK8      => clk8,
    RESET     => RESET,
    INSAMPLE  => insample,
    OUTSAMPLE => outsample,
    OUTBYTE   => outbyte,
    spiclk    => spiclk);

  input_inst : input port map (
    CLK      => clk,
    INSAMPLE => insample,
    RESET    => reset,
    CNV      => ADCCNV,
    SCK      => ADCSCK,
    SDIA     => ADCSDIA,
    SDIB     => ADCSDIB,
    DOUT     => dout,
    COUT     => cout,
    WEOUT    => weout,
    OSC      => pgachan,
    OSEN     => osen,
    OSRST    => pgarst,
    OSWE     => oswe,
    OSD      => edout
    );

  samplebuffer_inst : samplebuffer port map (
    CLK       => clk,
    RESET     => reset,
    DIN       => bin,
    CHANIN    => cout,
    WE        => bwe,
    AIN       => ain,
    DOUT      => x,
    AOUT      => xa,
    SAMPOUTEN => sampouten,
    ALLCHAN   => lswe,
    CHANOUT   => macchan);


  rmaccontrol_inst : RMACcontrol port map (
    CLK       => clk,
    INSAMPLE  => insample,
    OUTSAMPLE => outsample,
    OUTBYTE   => outbyte,
    RESET     => reset,
    STARTMAC  => startmac,
    MACDONE   => macdone,
    SAMPLE    => sample,
    SAMPBASE  => xabase,
    SAMPOUTEN => sampouten,
    RMACCHAN  => macchan);

  filterarray_inst : FilterArray port map (
    CLK   => clk,
    RESET => RESET,
    WE    => lfwe,
    H     => h,
    HA    => ha,
    AIN   => laddr(8 downto 0),
    DIN   => edout);

  rmac_inst : RMAC port map (
    CLK      => clk,
    X        => x,
    XA       => xa,
    H        => h,
    HA       => ha,
    XBASE    => xabase,
    STARTMAC => startmac,
    MACDONE  => macdone,
    RESET    => reset,
    Y        => ymac);

  pgaload_inst : PGAload port map (
    CLK      => clk,
    RESET    => reset,
    SCLK     => PGASRCK,
    RCLK     => PGARCK,
    SOUT     => PGASERA,
    CHAN     => pgachan,
    GAIN     => gain,
    FILTER   => filter,
    GSET     => gset,
    ISET     => iset,
    FSET     => fset,
    PGARESET => pgarst,
    ISEL     => isel);

  fibertx_inst : FiberTX port map (
    CLK        => clk,
    CLK8       => clk8,
    RESET      => RESET,
    OUTSAMPLE  => outsample,
    FIBEROUT   => FIBEROUT,
    CMDDONE    => cmddone,
    Y          => y,
    YEN        => yen,
    CMDSTS     => cmdsts,
    CMDID      => cmdid,
    CMDSUCCESS => cmdsuccess,
    OUTBYTE    => outbyte,
    CHKSUM     => chksum);


  fiberrx_inst : FiberRX port map (
    CLK     => clk,
    FIBERIN => FIBERIN,
    RESET   => RESET,
    DATA    => cmddata,
    CMD     => cmd,
    NEWCMD  => newcmd,
    PENDING => pending,
    CMDID   => cmdid,
    CHKSUM  => chksum,
    LINKUP => LEDLINK);

  loader_inst : Loader port map (
    CLK      => clk,
    LOAD     => load,
    DONE     => ldone,
    RESET    => RESET,
    SWE      => lswe,
    FWE      => lfwe,
    ADDR     => laddr,
    EEPROMEN => EEPROMLEN,
    EEEN     => len,
    EEDONE   => edone);

  eepromio_inst : EEPROMio port map (
    CLK    => clk,
    RESET  => reset,
    SPICLK => spiclk,
    DOUT   => edout,
    din    => edin,
    ADDR   => ea,
    WR     => erw,
    EN     => een,
    DONE   => edone,
    ESCK   => ESCK,
    ECS    => ECS,
    ESI    => ESI,
    ESO    => ESO);

  control_inst : Control port map (
    CLK        => clk,
    RESET      => reset,
    DATA       => cmddata,
    CMD        => cmd,
    NEWCMD     => newcmd,
    CMDSTS     => cmdsts,
    CMDDONE    => cmddone,
    PGACHAN    => pgachan,
    PGAGAIN    => gain,
    PGAISEL    => isel,
    PGAFIL     => filter,
    GSET       => gset,
    ISET       => iset,
    FSET       => fset,
    PGARESET   => pgarst,
    EADDR      => ewaddr,
    EEN        => ceen,
    EDONE      => edone,
    ERW        => erw,
    EDATA      => edin,
    EESEL      => eesel,
    BUFSEL     => bufsel,
    RAWSEL     => rawsel,
    RAWCHAN    => rawchan,
    CMDSUCCESS => cmdsuccess,
    OSEN       => osen,
    OSWE       => oswe,
    LOAD       => load,
    PENDING    => pending,
    LDONE      => ldone,
    MODEOUT    => mode);

  raw_inst : raw port map (
    CLK  => clk,
    WEIN => weout,
    CIN  => cout,
    DIN  => dout,
    CHAN => rawchan,
    Y    => yraw,
    YEN  => yenraw);


  -- muxes
  y   <= yraw   when rawsel = '1' else ymac;
  yen <= yenraw when rawsel = '1' else macdone;
  bin <= dout   when bufsel = '0' else edout;
  bwe <= weout  when bufsel = '0' else lswe;

  ain <= laddr(7 downto 0) when bufsel = '1' else sample;

  ea  <= ('0' & laddr) when eesel = '1' else (ewaddr);
  een <= len           when eesel = '1' else ceen;


  LEDCMD  <= cmdsuccess;

  CLK8_OUT <= clk8;

  jtaginterface_inst : jtaginterface
    generic map (
      JTAG1N => 64,
      JTAG2N => 64)
    port map (
      CLK    => clk,
      DIN1   => jtag1,
      DIN2   => jtag2);

  jtag1(63 downto 48) <= X"0123";
  jtag1(35 downto 32) <= cmdsts; 
  jtag1(31 downto 0) <= cmd & X"0" & cmdid & X"000" & chksum;
  
  
  jtag2(63 downto 48) <= X"ABCD"; 
  jtag2(31 downto 0) <= cmddata; 

end Behavioral;
