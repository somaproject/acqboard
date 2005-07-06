
-- VHDL Test Bench Created from source file input.vhd  -- 12:34:13 04/04/2004
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inputtest is
end inputtest;

architecture behavior of inputtest is

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

  signal CLK        : std_logic                     := '0';
  signal INSAMPLE   : std_logic                     := '0';
  signal RESET      : std_logic                     := '1';
  signal CNV        : std_logic                     := '0';
  signal SCK        : std_logic                     := '0';
  signal SDIA, SDIB : std_logic                     := (others => '0');
  signal DOUT       : std_logic_vector(15 downto 0) := (others => '0');
  signal COUT       : std_logic_vector(3 downto 0)  := (others => '0');
  signal WEOUT      : std_logic                     := '0';
  signal OSC        : std_logic_vector(3 downto 0)  := (others => '0');
  signal OSEN       : std_logic                     := '0';
  signal OSWE       : std_logic                     := '0';
  signal OSD        : std_logic_vector(15 downto 0) := (others => '0');
  signal OSCALL     : std_logic                     := '0';
  signal err        : std_logic                     := '0';
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

  signal adcbusy, adcinputdone :
    std_logic_vector(4 downto 0)
    := (others => '0');
  signal adcreset     : std_logic                    := '1';
  type intarray is array (9 downto 0) of integer;
  signal chan_in, chan_inl,
    chan_out, offsets : intarray                     := (others => 0);
  signal sdi, sdo     : std_logic_vector(9 downto 0) := (others => '0');


begin

  uut : input port map(
    CLK      => CLK,
    INSAMPLE => INSAMPLE,
    RESET    => RESET,
    CNV      => CNV,
    SCK      => SCK,
    SINA     => SINA
    DOUT     => DOUT,
    COUT     => COUT,
    WEOUT    => WEOUT,
    OSC      => OSC,
    OSRST    => OSCALL,
    OSEN     => OSEN,
    OSWE     => OSWE,
    OSD      => OSD
    );


  reset <= '0'     after 100 ns;
  clk   <= not clk after 6.94 ns;

  adcs   : for i in 0 to 9 generate
    ADCi : AD7685 generic map
      (filename   => "adc." & integer'image(i) & ".dat")
      port map (
        RESET     => adcreset,
        SCK       => SCK,
        CNV       => CNV,
        SDO       => sdo(i),
        SDI       => sdi(i),
        CH_VALUE  => 0,
        CH_OUT    => chan_in(i),
        FILEMODE  => '1',
        BUSY      => adcbusy(i),
        inputdone => adcinputdone(i));
  end generate;


  -- configuration:
  sdi(0) <= '0';
  sdi(1) <= sdo(0);
  sdi(2) <= sdo(1);
  sdi(3) <= sdo(2);
  sdi(4) <= sdo(3);
  SDIA   <= sdo(4);

  sdi(5) <= '0';
  sdi(6) <= sdo(5);
  sdi(7) <= sdo(6);
  sdi(8) <= sdo(7);
  sdi(9) <= sdo(8);
  SDIA   <= sdo(9);



  clock          : process(clk)
    variable cnt : integer := 0;

  begin
    if rising_edge(clk) then
      if cnt = 250 then
        INSAMPLE <= '1';
        cnt := 0;
        chan_inl <= chan_in;
      else
        INSAMPLE <= '0';
        cnt := cnt + 1;
      end if;
    end if;
  end process;


  offsets(0) <= 127;
  offsets(1) <= 0;
  offsets(2) <= 19755;
  offsets(3) <= 0;
  offsets(4) <= 0;
  offsets(5) <= -1;
  offsets(6) <= -128;
  offsets(7) <= -15715;
  offsets(8) <= 0;
  offsets(9) <= 0;


  sequencer : process
  begin
    wait for 100 ns;
    -- write some offsets:
    for i in 0 to 9 loop
      OSC  <= std_logic_vector(TO_UNSIGNED(i, OSC'length));
      OSD  <= std_logic_vector(TO_SIGNED(offsets(i), 16));
      OSWE <= '1';
      wait until rising_edge(CLK);
      OSWE <= '0';
      wait until rising_edge(CLK);


    end loop;
    wait for 20 ns;
    adcreset <= '0';
    wait until adcinputdone(0) = '1';
    adcreset <= '1';
    OSEN     <= '1';
    wait until rising_edge(clk);
    adcreset <= '0';
    wait until adcinputdone(0) = '1';
    assert false
      report "End of simulation"
      severity failure;

  end process;

  channelreader : process(clk)
  begin
    if rising_edge(clk) then
      if WEOUT = '1' then
        chan_out(TO_INTEGER(unsigned(COUT)))
 <= TO_INTEGER(signed(DOUT));
      end if;

    end if;
  end process channelreader;


  channelverify         : process(WEOUT, adcreset)
    variable firstread  : integer := 3;
    variable tempresult : integer;
  begin
    if adcreset = '1' then
      firstread                   := 3;
    else
      if falling_edge(WEOUT) then
        if firstread > 0 then
          firstread               := firstread - 1;
        else
          if osen = '0' then
            for i in 0 to 9 loop

              assert chan_out(i) = (chan_inl(i) -32768)
                report "Incorrect output in chan " & integer'image(i)
                severity error;
            end loop;

          else
            for i in 0 to 9 loop
              tempresult   := (chan_inl(i) -32768) + offsets(i);
              if tempresult < -32768 then
                tempresult := -32768;
              elsif tempresult > 32767 then
                tempresult := 32767;
              end if;
              assert chan_out(i) = tempresult
                report "Incorrect output in chan " & integer'image(i)
                severity error;
            end loop;
          end if;

        end if;
      end if;
    end if;


  end process;
end;
