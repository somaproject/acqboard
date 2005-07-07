
-- VHDL Test Bench Created from source file acqboard.vhd  -- 15:06:42 04/05/2004
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

entity acqcmdtest is
end acqcmdtest;

architecture behavior of acqcmdtest is

  component acqboard
    port(
      CLKIN     : in  std_logic;
      ADCIN     : in  std_logic_vector(4 downto 0);
      ESO       : in  std_logic;
      EEPROMLEN : in  std_logic;
      FIBERIN   : in  std_logic;
      ADCCLK    : out std_logic;
      ADCCS     : out std_logic;
      ADCCONVST : out std_logic;
      PGARCK    : out std_logic;
      PGASRCK   : out std_logic;
      PGASERA   : out std_logic;
      ESI       : out std_logic;
      ESCK      : out std_logic;
      ECS       : out std_logic;
      FIBEROUT  : out std_logic
      );
  end component;

  signal CLKIN     : std_logic := '0';
  signal ADCIN     : std_logic_vector(4 downto 0);
  signal ADCCLK    : std_logic;
  signal ADCCS     : std_logic;
  signal ADCCONVST : std_logic;
  signal PGARCK    : std_logic;
  signal PGASRCK   : std_logic;
  signal PGASERA   : std_logic;
  signal ESI       : std_logic;
  signal ESCK      : std_logic;
  signal ECS       : std_logic;
  signal ESO       : std_logic;
  signal EEPROMLEN : std_logic := '0';
  signal FIBERIN   : std_logic;
  signal FIBEROUT  : std_logic;
  signal RESET     : std_logic := '1';
  signal CLK8      : std_logic := '0';




  signal bouts : std_logic_vector(79 downto 0) := (others => '0');

  component PGA
    port ( SCLK  : in  std_logic;
           RCLK  : in  std_logic;
           SIN   : in  std_logic;
           bouts : out std_logic_vector(10*8-1 downto 0));
  end component;

  signal cmdid, cmd           :     std_logic_vector(3 downto 0) := (others => '0');
  signal cmddata0, cmddata1, cmddata2, cmddata3, cmdchksum :
    std_logic_vector(7 downto 0)                                 := (others => '0');
  signal sendcmds, cmdpending :     std_logic                    := '0';
  component SendCMD
    port ( CMDID              : in  std_logic_vector(3 downto 0);
           CMD                : in  std_logic_vector(3 downto 0);
           DATA0              : in  std_logic_vector(7 downto 0);
           DATA1              : in  std_logic_vector(7 downto 0);
           DATA2              : in  std_logic_vector(7 downto 0);
           DATA3              : in  std_logic_vector(7 downto 0);
           CHKSUM             : in  std_logic_vector(7 downto 0);
           SENDCMD            : in  std_logic;
           CMDPENDING         : out std_logic;
           DOUT               : out std_logic
           );
  end component;

  signal syscnt : integer := 0;

  signal eaddr, edin, edout      :     integer   := 0;
  signal ewe                     :     std_logic := '0';
  component EEPROM is
                     port ( SCK  : in  std_logic;
                            SO   : out std_logic;
                            SI   : in  std_logic;
                            CS   : in  std_logic;
                            ADDR : in  integer;
                            DOUT : out integer;
                            DIN  : in  integer;
                            WE   : in  std_logic);
  end component;
  type intarray is array(0 to 9) of integer;
  signal gains                   :     intarray  := (others => 0);
  signal filters                 :     intarray  := (others => 0);

  signal error : std_logic := '0';

  signal outvals : intarray := (others => 0);

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

  signal decmdst : std_logic_vector(7 downto 0)   := (others => '0');
  signal decmdid : std_logic_vector(7 downto 0)   := (others => '0');
  signal newframe         : std_logic                      := '0';
  signal deser_data       : std_logic_vector(159 downto 0) := (others => '0');
  signal adcval           : intarray                       := (others => 32768);



  component ADC
    generic (filename :     string    := "adcin.dat" );
    port ( RESET      : in  std_logic;
           SCLK       : in  std_logic := '0';
           CONVST     : in  std_logic;
           CS         : in  std_logic;
           SDOUT      : out std_logic;
           CHA_VALUE  : in  integer;
           CHB_VALUE  : in  integer;
           CHA_OUT    : out integer;
           CHB_OUT    : out integer;
           FILEMODE   : in  std_logic;
           BUSY       : out std_logic;
           INPUTDONE  : out std_logic);
  end component;


  type adcmodes is (const, inc);
  signal adcmode : adcmodes := const;



begin


  uut : acqboard port map(
    CLKIN     => CLKIN,
    ADCIN     => ADCIN,
    ADCCLK    => ADCCLK,
    ADCCS     => ADCCS,
    ADCCONVST => ADCCONVST,
    PGARCK    => PGARCK,
    PGASRCK   => PGASRCK,
    PGASERA   => PGASERA,
    ESI       => ESI,
    ESCK      => ESCK,
    ECS       => ECS,
    ESO       => ESO,
    EEPROMLEN => EEPROMLEN,
    FIBERIN   => FIBERIN,
    FIBEROUT  => FIBEROUT
    );

  pgauut : PGA port map (
    SCLK  => pgasrck,
    RCLK  => pgarck,
    SIN   => pgasera,
    bouts => bouts);


  cmdctl : SendCMD port map (
    CMDID      => cmdid,
    CMD        => cmd,
    DATA0      => cmddata0,
    DATA1      => cmddata1,
    DATA2      => cmddata2,
    DATA3      => cmddata3,
    chksum     => cmdchksum,
    SENDCMD    => sendcmds,
    cmdpending => cmdpending,
    DOUT       => FIBERIN);


  rom : EEPROM port map (
    SCK  => ESCK,
    SO   => ESO,
    SI   => ESI,
    CS   => ECS,
    ADDR => eaddr,
    DIN  => edin,
    DOUT => edout,
    we   => ewe);


  des : deserialize port map (
    clk8     => clk8,
    fiberout => fiberout,
    newframe => newframe,
    cmdst    => decmdst,
    cmdid    => decmdid,
    data     => deser_data,
    kchar    => open);

  process(deser_data) is
  begin
    for i in 0 to 9 loop
      outvals(i) <= TO_INTEGER(signed(deser_data(i*16+7 downto i*16+0) &
                                      deser_data(i*16+15 downto i*16+8))
                               );
    end loop;
  end process;


  adcs     : for i in 0 to 4 generate
    adcuut : ADC port map (
      RESET     => RESET,
      SCLK      => ADCCLK,
      CONVST    => ADCCONVST,
      CS        => ADCCS,
      SDOUT     => ADCIN(i),
      CHA_VALUE => adcval(2*i),
      CHB_VALUE => adcval(2*i+1),
      CHA_OUT   => open,
      CHB_OUT   => open,
      BUSY      => open,
      FILEMODE  => '0',
      INPUTDONE => open);
  end generate;






  clkin      <= not clkin after 13.889 ns;
  clk8       <= not clk8  after 125 ns;
  reset      <= '0'       after 100 ns;
  process (clkin) is
  begin
    if rising_edge(clkin) then
      syscnt <= syscnt + 1;
    end if;
  end process;


  process(bouts) is
  begin
    for i in 0 to 9 loop
      gains(9-i)   <= TO_INTEGER(unsigned(bouts(i*8+3 downto i*8+1)));
      filters(9-i) <= TO_INTEGER(unsigned(bouts(i*8+5 downto i*8+4)));

    end loop;
  end process;


  adcsmode : process(ADCCS) is
  begin
    if rising_edge(ADCCS) then
      if adcmode = const then
        adcval        <= (others => 32768);
      elsif adcmode = inc then
        -- we increment each read cycle, each one starting
        -- with a different base
        for i in 0 to 9 loop
          if adcval(i) = 32765 then
            adcval(i) <= 32768;
          else
            adcval(i) <= adcval(i) + 1;
          end if;
        end loop;
      end if;
    end if;

  end process adcsmode;

  commands : process is
  begin
    wait until syscnt = 1000;

    -- null command for frame alignment

    cmdid    <= "0000";
    cmd      <= "0000";
    cmddata0 <= X"00";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    report "Finished null command for frame alignment";


    -- set offset value for chan 0, gain = 7
    eaddr <= 519*2;
    edin  <= 255;
    ewe   <= '1';

    wait until rising_edge(clkin);
    ewe <= '0';

    -- set gain of chan 0 to 0x7
    wait until syscnt = 3000;

    cmdid    <= "0011";
    cmd      <= "0001";
    cmddata0 <= X"00";
    cmddata1 <= X"07";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0011";

    if gains(0) = 7 then
      error <= '0';
      report "Gain of channel 0 set to 0x7";
    else
      error <= '1';
      report "ERROR in setting gain of channel 0 to 0x7";
    end if;


    -- set highpass filter for channel 7 to value 2
    cmdid    <= "0100";
    cmd      <= "0011";
    cmddata0 <= X"06";
    cmddata1 <= X"02";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0100";

    if filters(6) /= 2 then
      error <= '1';
    else
      report "set highpass filter for channel 7 to value 2";
    end if;

    -- set mode = 1 (offset disable)


    cmdid    <= "0101";
    cmd      <= "0111";
    cmddata0 <= X"01";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdst = X"02";
    wait until rising_edge(clkin);
    wait until rising_edge(clkin);
    wait until rising_edge(clkin);

    report "Set mode to 1 (offset disable); mode now 1";


    -- write offset value
    cmdid    <= "0110";
    cmd      <= "0100";
    cmddata0 <= X"04";
    cmddata1 <= X"03";
    cmddata2 <= X"12";
    cmddata3 <= X"34";

    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0110";
    wait until rising_edge(clkin);
    eaddr <= (512 + 4*8+3)*2;
    wait until rising_edge(clkin);

    report "Wrote offset value of 0x1234 for chan 4, gain 3";


    -- set mode = 0 (normal)
    cmdid    <= "0111";
    cmd      <= "0111";
    cmddata0 <= X"00";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0111";
    wait until rising_edge(clkin);
    if decmdst /= X"00" then
      error <= '1';
    end if;

    report "Returned to mode 0";

    -- set gain of channel 4 to 3

    cmdid    <= "0011";
    cmd      <= "0001";
    cmddata0 <= X"04";
    cmddata1 <= X"03";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0011";

    if gains(4) = 3 then
      error <= '0';
    else
      error <= '1';
    end if;

    report "Channel 4 gain to 3; waiting to see offset effect";

    wait until outvals(4) = 4660;

    report "Successfully read channel 4 with offset-added";

    -- now, change ADC values to increment 
    adcmode <= inc;
    report "ADC inputs changed to increment mode";

    -- set mode = 3 (raw)
    cmdid    <= "0100";
    cmd      <= "0111";
    cmddata0 <= X"03";
    cmddata1 <= X"02";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until cmdpending = '0';

    wait until decmdid(4 downto 1) = "0100";
    wait until rising_edge(clkin);
    if decmdst /= X"00" then
      error <= '1';
    end if;

    report "Sitched to mode 3, with chan 0x02 as raw input";

    wait until outvals(0 to 7) =
      (111, 112, 113, 114, 115, 116, 117, 118);

    report "Successfully read raw data";

  end process commands;


end;
