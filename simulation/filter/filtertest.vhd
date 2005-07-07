library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity filtertest is
  generic (simname : string := "basic");
end filtertest;

architecture behavior of filtertest is

  component input
    port(
      CLK      : in  std_logic;
      INSAMPLE : in  std_logic;
      RESET    : in  std_logic;
      SDIA     : in  std_logic;
      SDIB     : in  std_logic;
      OSC      : in  std_logic_vector(3 downto 0);
      OSRST    : in  std_logic;
      OSEN     : in  std_logic;
      OSWE     : in  std_logic;
      OSD      : in  std_logic_vector(15 downto 0);
      CNV      : out std_logic;
      SCK      : out std_logic;
      DOUT     : out std_logic_vector(15 downto 0);
      COUT     : out std_logic_vector(3 downto 0);
      WEOUT    : out std_logic
      );
  end component;

  signal CLK            : std_logic := '0';
  signal INSAMPLE       : std_logic;
  signal RESET          : std_logic := '1';
  signal CNV            : std_logic := '0';
  signal SCK            : std_logic := '0';
  signal SDIA, SDIA_pre : std_logic := '-';
  signal SDIB, SDIB_pre : std_logic := '0';
  signal DOUT           : std_logic_vector(15 downto 0);
  signal COUT           : std_logic_vector(3 downto 0);
  signal WEOUT          : std_logic;
  signal OSC            : std_logic_vector(3 downto 0);
  signal OSRST          : std_logic;
  signal OSEN           : std_logic;
  signal OSWE           : std_logic;
  signal OSD            : std_logic_vector(15 downto 0);

  component samplebuffer
    port ( CLK       : in  std_logic;
           RESET     : in  std_logic;
           DIN       : in  std_logic_vector(15 downto 0);
           CHANIN    : in  std_logic_vector(3 downto 0);
           WE        : in  std_logic;
           AIN       : in  std_logic_vector(7 downto 0);
           DOUT      : out std_logic_vector(15 downto 0);
           AOUT      : in  std_logic_vector(7 downto 0);
           ALLCHAN   : in  std_logic;
           SAMPOUTEN : in  std_logic;
           CHANOUT   : in  std_logic_vector(3 downto 0));
  end component;

  signal X, fdin        : std_logic_vector(15 downto 0) := (others => '0');
  signal H              : std_logic_vector(21 downto 0) := (others => '0');
  signal XA, HA         : std_logic_vector(7 downto 0)  := (others => '0');
  signal XABASE, SAMPLE : std_logic_vector(7 downto 0)  := (others => '0');
  signal macdone, fwe   : std_logic                     := '0';
  signal startmac       : std_logic                     := '0';
  signal allchan        : std_logic                     := '0';
  signal fain           : std_logic_vector(8 downto 0)  := (others => '0');
  signal macchan        : std_logic_vector(3 downto 0)  := (others => '0');


  component FilterArray
    port ( CLK   : in  std_logic;
           RESET : in  std_logic;
           WE    : in  std_logic;
           H     : out std_logic_vector(21 downto 0);
           HA    : in  std_logic_vector(7 downto 0);
           AIN   : in  std_logic_vector(8 downto 0);
           DIN   : in  std_logic_vector(15 downto 0));
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

  signal y : std_logic_vector(15 downto 0) := (others => '0');

  signal outsample, outbyte : std_logic := '0';

  component AD7685

    generic (filename :     string    := "adcin.dat" );
    port ( RESET      : in  std_logic;
           SCK        : in  std_logic := '0';
           CNV        : in  std_logic;
           SDO        : out std_logic;
           SDI        : in  std_logic;
           CH_VALUE   : in  integer;
           CH_OUT     : out integer   := 32768;
           FILEMODE   : in  std_logic;
           BUSY       : out std_logic;
           INPUTDONE  : out std_logic);
  end component;

  type adc_intarray is array(0 to 4) of integer;
  signal cha_out, chb_out : adc_intarray := (others => 0);
  signal sampouten        : std_logic    := '0';
  signal adc_reset        : std_logic;

  signal clk_enable : std_logic := '0';
  signal syscnt     : integer   := 0;

  component FilterLoad
    generic (filename :     string                       := "adcin.dat" );
    port ( CLK        : in  std_logic;
           DOUT       : out std_logic_vector(15 downto 0);
           AOUT       : out std_logic_vector(8 downto 0);
           WEOUT      : out std_logic;
           LOAD       : in  std_logic);
  end component;
  signal loadfilter   :     std_logic                    := '0';
  signal adcinputdone :     std_logic_vector(9 downto 0) := (others => '0');


  signal sdi, sdo : std_logic_vector(9 downto 0) := (others => '0');


begin

  uut : input port map(
    CLK      => CLK,
    INSAMPLE => INSAMPLE,
    RESET    => RESET,
    CONVST   => CONVST,
    ADCCS    => ADCCS,
    SCLK     => SCLK,
    SDIN     => SDIN,
    DOUT     => DOUT,
    COUT     => COUT,
    WEOUT    => WEOUT,
    OSC      => OSC,
    OSRST    => OSRST,
    OSEN     => OSEN,
    OSWE     => OSWE,
    OSD      => OSD
    );




  -- configuration:
  sdi(0)   <= '0';
  sdi(1)   <= sdo(0);
  sdi(2)   <= sdo(1);
  sdi(3)   <= sdo(2);
  sdi(4)   <= sdo(3);
  SDIA_pre <= sdo(4);

  sdi(5)   <= '0';
  sdi(6)   <= sdo(5);
  sdi(7)   <= sdo(6);
  sdi(8)   <= sdo(7);
  sdi(9)   <= sdo(8);
  SDIB_pre <= sdo(9);

  -- circuit board and isolator delays

  SDIA <= SDIA_pre after 20 ns;
  SDIB <= SDIB_pre after 20 ns;

  SCK <= SCK_pre after 10 ns;

  adcs   : for i in 0 to 9 generate
    ADCi : AD7685 generic map
      (filename   => simname & ".adcin." & integer'image(i) & ".dat")
      port map (
        RESET     => adcreset,
        SCK       => SCK,
        CNV       => CNV,
        SDO       => sdo(i),
        SDI       => sdi(i),
        CH_VALUE  => 0,
        CH_OUT    => chan_in(i),
        FILEMODE  => '1',
        BUSY      => open,
        inputdone => adcinputdone(i));
  end generate;


  sample_UUT : samplebuffer port map (
    CLK       => clk,
    RESET     => RESET,
    DIN       => dout,
    CHANIN    => cout,
    WE        => WEOUT,
    AIN       => SAMPLE,
    DOUT      => X,
    AOUT      => XA,
    ALLCHAN   => allchan,
    SAMPOUTEN => SAMPOUTEN,
    CHANOUT   => macchan);



  filter : FilterArray port map (
    CLK   => CLK,
    RESET => RESET,
    WE    => fwe,
    H     => H,
    HA    => HA,
    AIN   => fain,
    DIN   => fdin);


  rmaccont : RMACcontrol port map(
    CLK       => clk,
    INSAMPLE  => insample,
    OUTSAMPLE => outsample,
    OUTBYTE   => outbyte,
    RESET     => RESET,
    STARTMAC  => startmac,
    MACDONE   => macdone,
    SAMPLE    => SAMPLE,
    SAMPBASE  => XABASE,
    SAMPOUTEN => sampouten,
    RMACCHAN  => MACCHAN);

  rmaccr : RMAC port map (
    CLK      => clk,
    X        => X,
    XA       => XA,
    H        => H,
    HA       => HA,
    XBASE    => XABASE,
    STARTMAC => startmac,
    MACDONE  => macdone,
    RESET    => RESET,
    Y        => Y);

  filload : FilterLoad generic map
    (filename => simname & ".filter.dat")
    port map(
      clk     => clk,
      DOUT    => fdin,
      AOUT    => fain,
      WEOUT   => fwe,
      load    => loadfilter);


  clk <= not clk after 6.944444 ns;


  process(clk, clk_enable)
    variable clkcnt : integer := 1;

  begin
    if rising_edge(clk_enable) then
      clkcnt     := 1;
    else
      if rising_edge(clk) then
        if clk_enable = '1' then
          clkcnt := clkcnt + 1;
        end if;
      end if;
    end if;
    if clkcnt mod 2250 = 0 then
      outsample <= '1';
    else
      outsample <= '0';
    end if;

    if clkcnt mod 375 = 0 then
      insample <= '1';
    else
      insample <= '0';
    end if;

    if clkcnt mod 90 = 0 then
      outbyte <= '1';
    else
      outbyte <= '0';
    end if;


  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      syscnt <= syscnt + 1;
    end if;
  end process;


  process(clk, reset)

    file outputfile : text;
    variable L      : line;
  begin
    if falling_edge(reset) then
      file_open(outputfile, simname & ".output.dat", write_mode);
    end if;
    if rising_edge(clk) then
      if outsample = '1' then
        writeline(outputfile, L);
      end if;

      if macdone = '1' then
        write(L, to_integer(signed(y)));
        write(L, ' ');
      end if;

    end if;
  end process;

  tb : process

  begin

    adc_reset  <= '0';
    loadfilter <= '1';
    wait until rising_edge(clk);
    adc_reset  <= '1';
    loadfilter <= '0';
    wait until syscnt > 1000;
    adc_reset  <= '0';
    wait until rising_edge(clk);

    reset      <= '0';
    clk_enable <= '1';
    wait until filedone = '1';
    wait;



  end process;


end;
