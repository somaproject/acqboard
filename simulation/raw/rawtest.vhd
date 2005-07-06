
-- VHDL Test Bench Created from source file input.vhd  -- 17:44:46 01/26/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;

entity rawtest is
end rawtest;

architecture behavior of rawtest is

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


  component clocks
    port ( CLKIN     : in  std_logic;
           CLK       : out std_logic;
           CLK8      : out std_logic;
           RESET     : in  std_logic;
           INSAMPLE  : out std_logic;
           OUTSAMPLE : out std_logic;
           OUTBYTE   : out std_logic := '0';
           SPICLK    : out std_logic);
  end component;



  component raw
    port ( CLK  : in  std_logic;
           DIN  : in  std_logic_vector(15 downto 0);
           CIN  : in  std_logic_vector(3 downto 0);
           WEIN : in  std_logic;
           CHAN : in  std_logic_vector(3 downto 0);
           Y    : out std_logic_vector(15 downto 0);
           YEN  : out std_logic);

  end component;
  component FiberTX
    port ( CLK        : in  std_logic;
           CLK8       : in  std_logic;
           RESET      : in  std_logic;
           OUTSAMPLE  : in  std_logic;
           FIBEROUT   : out std_logic;
           CMDDONE    : in  std_logic;
           Y          : in  std_logic_vector(15 downto 0);
           YEN        :     std_logic;
           CMDSTS     : in  std_logic_vector(3 downto 0);
           CMDID      : in  std_logic_vector(3 downto 0);
           CMDSUCCESS : in  std_logic;
           OUTBYTE    : in  std_logic;
           CHKSUM     : in  std_logic_vector(7 downto 0));
  end component;

  component AD7685
    generic (filename :     string    := "adcin.dat" );
    port ( RESET      : in  std_logic;
           SCK        : in  std_logic := '0';
           CNV        : in  std_logic;
           SDI        : in  std_logic;
           SDO        : out std_logic;
           CH_VALUE   : in  integer;
           CH_OUT     : out integer   := 32768;
           FILEMODE   : in  std_logic;
           BUSY       : out std_logic;
           INPUTDONE  : out std_logic);
  end component;

  component deserialize
    generic ( filename :     string := "deserialize.output.dat");
    port ( CLK8        : in  std_logic;
           FIBEROUT    : in  std_logic;
           newframe    : out std_logic;
           kchar       : out std_logic_vector(7 downto 0);
           cmdst       : out std_logic_vector(7 downto 0);
           data        : out std_logic_vector(159 downto 0);
           cmdid       : out std_logic_vector(7 downto 0)
           );
  end component;

  signal newframe            : std_logic := '0';
  signal kcharout            : std_logic_vector(7 downto 0)
                                         := (others => '0');
  signal cmdstsout, cmdidout : std_logic_vector(7 downto 0)
                                         := (others => '0');
  signal data                : std_logic_vector(159 downto 0)
                                         := (others => '0');


  signal sdi, sdo : std_logic_vector(9 downto 0) := (others => '0');

  signal CLK            : std_logic := '0';
  signal clkin          : std_logic := '0';
  signal INSAMPLE       : std_logic;
  signal RESET          : std_logic := '1';
  signal CNV            : std_logic;
  signal SCK, SCK_pre   : std_logic;
  signal SDIA, SDIA_pre : std_logic := '0';
  signal SDIB, SDIB_pre : std_logic := '0';
  signal DOUT           : std_logic_vector(15 downto 0);
  signal COUT           : std_logic_vector(3 downto 0);
  signal WEOUT          : std_logic;
  signal OSC            : std_logic_vector(3 downto 0);
  signal OSRST          : std_logic;
  signal OSEN           : std_logic;
  signal OSWE           : std_logic;
  signal OSD            : std_logic_vector(15 downto 0);


  signal y                        : std_logic_vector(15 downto 0);
  signal yen                      : std_logic;
  signal outsample : std_logic := '0';
  signal outbyte, clk8 : std_logic := '0';
  type sigvals is array (9 downto 0) of integer;

  signal ch_value : sigvals := (others => 0);
  signal spiclk   : std_logic := '0';
  signal fiberout : std_logic := '0';
  signal intout   : integer   := 0;


  type intlist is array(0 to 99) of integer;
  signal samplelist : intlist;
  signal adcdone    : std_logic := '0';

  signal adcbusy      : std_logic_vector(9 downto 0) := (others => '0');
  signal adcinputdone : std_logic_vector(9 downto 0) := (others => '0');


begin

  uut : input port map(
    CLK      => CLK,
    INSAMPLE => INSAMPLE,
    RESET    => RESET,
    CNV      => CNV,
    SCK      => SCK_pre,
    SDIA     => SDIA,
    SDIB     => SDIB,
    DOUT     => DOUT,
    COUT     => COUT,
    WEOUT    => WEOUT,
    OSC      => OSC,
    OSRST    => OSRST,
    OSEN     => OSEN,
    OSWE     => OSWE,
    OSD      => OSD
    );


  clock : clocks port map (
    CLKIN     => clkin,
    CLK       => clk,
    CLK8      => clk8,
    RESET     => RESET,
    INSAMPLE  => INSAMPLE,
    OUTSAMPLE => OUTSAMPLE,
    OUTBYTE   => OUTBYTE,
    SPICLK    => spiclk);

  rawio : raw port map (
    CLK  => clk,
    DIN  => DOUT,
    CIN  => COUT,
    WEIN => WEOUT,
    CHAN => "0000",
    Y    => y,
    YEN  => yen);

  fiber_uut : FiberTX port map (
    CLK        => clk,
    CLK8       => clk8,
    RESET      => reset,
    OUTSAMPLE  => outsample,
    FIBEROUT   => fiberout,
    CMDDONE    => '0',
    Y          => y,
    YEN        => yen,
    CMDSTS     => X"0",
    CMDID      => X"0",
    CMDSUCCESS => '0',
    OUTBYTE    => outbyte,
    CHKSUM     => X"00");


  adcs   : for i in 0 to 9 generate
    ADCi : AD7685 generic map
      (filename   => "adc.0.dat")
      port map (
        RESET     => RESET,
        SCK       => SCK,
        CNV       => CNV,
        SDO       => sdo(i),
        SDI       => sdi(i),
        CH_VALUE  => 0,
        CH_OUT    => ch_value(i),
        FILEMODE  => '1',
        BUSY      => adcbusy(i),
        inputdone => adcinputdone(i));
  end generate;

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

  deser : deserialize port map
    (CLK8     => clk8,
     FIBEROUT => FIBEROUT,
     newframe => newframe,
     kchar    => kcharout,
     cmdst    => cmdstsout,
     cmdid    => cmdidout,
     data     => data);

  clkin <= not clkin after 13.89 ns;
  RESET <= '0'       after 100 ns;


  getsamples : process
    -- responsible for extracting samples
    -- from 8b/10b deserializer data word
  begin
    wait until falling_edge(NEWFRAME);
    while(RESET = '0') loop
      wait until falling_edge(NEWFRAME);
      for i in 0 to 5 loop
        intout <= to_integer(signed(
          data(i*16+7 downto i*16) &
          data(i*16+15 downto i*16+8)));
        wait until CLK8 = '1';
      end loop;
    end loop;
  end process getsamples;

  checksamples             : process(intout, ch_value(0))
    variable inpos, outpos : integer := 0;
    variable starting      : integer := 1;
    variable tmp           : integer := 0;

  begin
    -- we're using intlist as a circular buffer
    if ch_value'event then
      samplelist(inpos) <= ch_value(0);
      inpos := (inpos + 1) mod 100;
    end if;

    if intout'event then
      if intout = -32768 and starting = 1 then
        -- this is just to pass over start-up
        -- artifacts                    
      else
        starting := 0;

        tmp   := samplelist(outpos);
        tmp   := tmp - 32768;
        if tmp < -32768 then
          tmp := -32768;
        end if;

        assert tmp = intout
          report "error reading value"
          severity error;
        outpos := (outpos + 1) mod 100;

      end if;
    end if;

  end process checksamples;


  ending : process(adcinputdone(0))
  begin
    if rising_edge(adcinputdone(0)) then
      assert false
        report "End of simulation"
        severity failure;

    end if;
  end process ending;
end;
