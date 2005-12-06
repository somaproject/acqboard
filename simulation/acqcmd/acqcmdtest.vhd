
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
use WORK.Silly.all;

entity acqcmdtest is
end acqcmdtest;

architecture behavior of acqcmdtest is

  component acqboard
    port(
      CLKIN     : in  std_logic;
      ADCSDIA   : in  std_logic;
      ADCSDIB   : in  std_logic;
      ADCSCK    : out std_logic;
      ADCCNV    : out std_logic;
      ESO       : in  std_logic;
      EEPROMLEN : in  std_logic;
      FIBERIN   : in  std_logic;
      PGARCK    : out std_logic;
      PGASRCK   : out std_logic;
      PGASERA   : out std_logic;
      ESI       : out std_logic;
      ESCK      : out std_logic;
      ECS       : out std_logic;
      FIBEROUT  : out std_logic
      );
  end component;

  signal CLKIN      : std_logic := '0';
  signal SDIA, SDIB : std_logic;
  signal CNV        : std_logic;
  signal PGARCK     : std_logic;
  signal PGASRCK    : std_logic;
  signal PGASERA    : std_logic;
  signal ESI        : std_logic;
  signal ESCK       : std_logic;
  signal ECS        : std_logic;
  signal ESO        : std_logic;
  signal EEPROMLEN  : std_logic := '0';
  signal FIBERIN    : std_logic;
  signal FIBEROUT   : std_logic;
  signal RESET      : std_logic := '1';
  signal CLK8       : std_logic := '0';

  signal SDI, SDO           : std_logic_vector(9 downto 0) := (others => '0');
  signal SDIA_pre, SDIB_pre : std_logic                    := '0';
  signal SCK, SCK_pre       : std_logic                    := '0';

  signal insela, inselb : integer := 0;



  component PGA
    port ( SCLK    : in  std_logic;
           RCLK    : in  std_logic;
           SIN     : in  std_logic;
           GAINS   : out chanarray;
           FILTERS : out chanarray;
           INSELA  : out integer;
           INSELB  : out integer
           );
  end component;


  signal cmdid, cmd : std_logic_vector(3 downto 0) := (others => '0');
  signal cmddata0, cmddata1, cmddata2, cmddata3, cmdchksum :
    std_logic_vector(7 downto 0)                   := (others => '0');

  signal sendcmds, cmdpending :     std_logic := '0';
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

  signal eaddr, edin, edout : integer   := 0;
  signal ewe                : std_logic := '0';

  component EEPROM
    port ( SCK  : in  std_logic;
           SO   : out std_logic;
           SI   : in  std_logic;
           CS   : in  std_logic;
           ADDR : in  integer;
           DOUT : out integer;
           DIN  : in  integer;
           WE   : in  std_logic);
  end component;

  signal gains   : chanarray := (others => 0);
  signal filters : chanarray := (others => 0);

  signal errorsig : std_logic := '0';

  signal outvals : chanarray := (others => 0);
  signal ov : integer := 0;
  
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

  signal decmdst    : std_logic_vector(7 downto 0)   := (others => '0');
  signal decmdid    : std_logic_vector(7 downto 0)   := (others => '0');
  signal newframe   : std_logic                      := '0';
  signal deser_data : std_logic_vector(159 downto 0) := (others => '0');
  signal adcval     : chanarray                      := (others => 32768);



  component AD7685
    generic (filename :     string    := "adcin.dat" );
    port ( RESET      : in  std_logic;
           SCK        : in  std_logic := '0';
           CNV        : in  std_logic;
           SDI        : in  std_logic;
           SDO        : out std_logic;
           CH_VALUE   : in  integer;
           CH_OUT     : out integer;
           FILEMODE   : in  std_logic;
           BUSY       : out std_logic;
           INPUTDONE  : out std_logic);
  end component;


  type adcmodes is (const, inc);
  signal adcmode : adcmodes := const;



begin

  uut : acqboard port map(
    CLKIN     => CLKIN,
    ADCSDIA   => SDIA,
    ADCSDIB   => SDIB,
    ADCSCK    => SCK_pre,
    ADCCNV    => CNV,
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
    SCLK    => pgasrck,
    RCLK    => pgarck,
    SIN     => pgasera,
    gains   => gains,
    filters => filters,
    INSELA  => insela,
    INSELB  => inselb);


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

  process(deser_data)
  begin
    for i in 0 to 9 loop
      outvals(i) <= TO_INTEGER(signed(deser_data(i*16+7 downto i*16+0) &
                                      deser_data(i*16+15 downto i*16+8))
                               );
    end loop;
  end process;


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

  SDIA <= SDIA_pre after 6 ns;
  SDIB <= SDIB_pre after 6 ns;

  SCK <= SCK_pre after 5 ns;

  adcs   : for i in 0 to 9 generate
    ADCi : AD7685 
      port map (
        RESET     => RESET,
        SCK       => SCK,
        CNV       => CNV,
        SDO       => sdo(i),
        SDI       => sdi(i),
        CH_VALUE  => adcval(i),
        CH_OUT    => open,
        FILEMODE  => '0',
        BUSY      => open,
        inputdone => open);
  end generate;



  clkin      <= not clkin after 13.889 ns;
  clk8       <= not clk8  after 62.5 ns;
  reset      <= '0'       after 100 ns;
  process (clkin)
  begin
    if rising_edge(clkin) then
      syscnt <= syscnt + 1;
    end if;
  end process;


  adcsmode : process(CNV)
  begin
    if falling_edge(CNV) then
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

  process
                       
  begin
    
    wait until syscnt > 100; 

    if eepromlen = '1' then
      wait until decmdst(0) = '0';
      
    end if;
    -- null command for frame alignment
    wait until rising_edge(CLKIN) and cmdpending = '0';  
    cmdid    <= "0000";
    cmd      <= "0000";
    cmddata0 <= X"00";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';

    wait for 100 us; 


    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';

    wait for 100 us; 

    
    wait until rising_edge(clkin) and cmdpending =  '0';

    report "Finished null command for frame alignment";


    -- set offset value for chan 0, gain = 7
    eaddr <= 519*2;
    edin  <= 255;
    ewe   <= '1';

    wait until rising_edge(clkin);
    ewe <= '0';

    -- set gain of chan 0 to 0x7
    

    cmdid    <= "0011";
    cmd      <= "0001";
    cmddata0 <= X"00";
    cmddata1 <= X"07";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and cmdpending = '0';

    wait until rising_edge(clkin)  and decmdid(4 downto 1) = "0011";

    if gains(0) = 7 then
      errorsig <= '0';
      report "Gain of channel 0 set to 0x7";
    else
      errorsig <= '1';
      assert false report "Error in setting gain of channel 0 to 0x7" severity ERROR;
    end if;


    -- set highpass filter for channel 7 to value 1
    cmdid    <= "0100";
    cmd      <= "0011";
    cmddata0 <= X"06";
    cmddata1 <= X"01";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and  cmdpending = '0';

    wait until rising_edge(clkin)  and decmdid(4 downto 1) = "0100";

    if filters(6) /= 1 then
      errorsig <= '1';
      report "Error in setting highpass filter for channel 7 to value 1"
      severity error;
    else
      report "set highpass filter for channel 7 to value 1";
    end if;

    -- set mode = 1 (offset disable)


    cmdid    <= "0101";
    cmd      <= "0111";
    cmddata0 <= X"01";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and  cmdpending = '0';

    wait until decmdst = X"02" and rising_edge(clkin);
    wait until rising_edge(clkin);
    wait until rising_edge(clkin);
    wait until rising_edge(clkin);

    report "Set mode to 1 (offset disable); mode now 1";

    report "Attempting to write offset value...";
    
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
    wait until rising_edge(clkin)  and  cmdpending = '0';

    wait until rising_edge(clkin)  and decmdid(4 downto 1) = "0110";
    wait until rising_edge(clkin);
    eaddr <= (512 + 4*8+3)*2;
    wait until rising_edge(clkin);

    report "Wrote offset value of 0x1234 for chan 4, gain 3";

    
    report "Changing to mode 2";
    -- set mode = 2 (filter write)
    cmdid    <= "0111";
    cmd      <= "0111";
    cmddata0 <= X"02";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and cmdpending = '0';

    wait until rising_edge(clkin)  and  decmdid(4 downto 1) = "0111";

    if decmdst /= X"04" then
      errorsig <= '1';
      report "error checking decmdst in mode 2" severity error;
    end if;

    report "moved to mode 2";
    report "attempting to write filter coeff";
    
    -- write filter value
    cmdid    <= "0000";
    cmd      <= "0101";
    cmddata0 <= X"00";
    cmddata1 <= X"1F";
    cmddata2 <= X"FF";
    cmddata3 <= X"FF";

    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and  cmdpending = '0';

    wait until rising_edge(clkin)  and decmdid(4 downto 1) = "0000";
    wait until rising_edge(clkin);
    wait until rising_edge(clkin);

    report "Wrote filter coefficient h[0]  to be 0x1FFFFF";

    report "changing to mode 0";
    
    -- set mode = 0 (normal)
    cmdid    <= "0001";
    cmd      <= "0111";
    cmddata0 <= X"10";
    cmddata1 <= X"00";
    sendcmds <= '1';
    wait until rising_edge(clkin);
    sendcmds <= '0';
    wait until rising_edge(clkin)  and cmdpending = '0';

    wait until rising_edge(clkin)  and  decmdid(4 downto 1) = "0001";
                                                         -- done with loading
    if decmdst /= X"00" then
      errorsig <= '1';
      report "error checking decmdst in mode 0" severity error;
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
    wait until rising_edge(clkin) and cmdpending = '0';

    wait until rising_edge(clkin) and decmdid(4 downto 1) = "0011";

    if gains(4) = 3 then
      errorsig <= '0';
    else
      errorsig <= '1';
      report "Error seytting channel 4 gain." severity ERROR;
    end if;

    report "Channel 4 gain to 3; waiting to see offset effect";

    wait until rising_edge(clkin) and outvals(4) = 4660;

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
    wait until rising_edge(clkin) and cmdpending = '0';

    wait until rising_edge(clkin) and decmdid(4 downto 1) = "0100";
    wait until rising_edge(clkin);
    if decmdst /= X"06" then
      errorsig <= '1';
    end if;

    report "Switched to mode 3, with chan 0x02 as raw input";

    wait until outvals(5) = 800 or outvals(4) = 800 or outvals(3) = 800
    or outvals(2) = 800 or outvals(1) = 800 or outvals(0) = 800;

    ov <= outvals(0);
    wait until outvals(5) = (ov+5) and
      outvals(4) = ov+4 and
      outvals(3) = ov+3 and
      outvals(2) = ov+2 and
      outvals(1) = ov+1 and
      outvals(0) = ov and rising_edge(CLKIN);

    report "Successfully read raw data";

    assert false
      report "End of simulation"
      severity failure;

    
  end process;


end;
