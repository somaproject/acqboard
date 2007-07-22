
-- VHDL Test Bench Created from source file rmac.vhd  -- 20:45:18 04/04/2004
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
use std.textio.all;

use IEEE.numeric_std.all;


entity rmactest is
end rmactest;

architecture behavior of rmactest is

  component rmac
    port(
      CLK      : in  std_logic;
      X        : in  std_logic_vector(15 downto 0);
      H        : in  std_logic_vector(21 downto 0);
      XBASE    : in  std_logic_vector(7 downto 0);
      STARTMAC : in  std_logic;
      RESET    : in  std_logic;
      XA       : out std_logic_vector(7 downto 0);
      HA       : out std_logic_vector(7 downto 0);
      MACDONE  : out std_logic;
      Y        : out std_logic_vector(15 downto 0)
      );
  end component;

  signal CLK      : std_logic := '0';
  signal X, LX    : std_logic_vector(15 downto 0);
  signal XA       : std_logic_vector(7 downto 0);
  signal H, LH    : std_logic_vector(21 downto 0);
  signal HA       : std_logic_vector(7 downto 0);
  signal XBASE    : std_logic_vector(7 downto 0);
  signal STARTMAC : std_logic;
  signal MACDONE  : std_logic;
  signal RESET    : std_logic := '1';
  signal Y        : std_logic_vector(15 downto 0);


  signal err : std_logic := '0';


begin

  uut : rmac port map(
    CLK      => CLK,
    X        => X,
    XA       => XA,
    H        => H,
    HA       => HA,
    XBASE    => XBASE,
    STARTMAC => STARTMAC,
    MACDONE  => MACDONE,
    RESET    => RESET,
    Y        => Y
    );


  clk <= not clk after 6.9444 ns;

  reset <= '0' after 100 ns;

  -- open file
  -- read line
  -- load values into fake-rams

  process(clk)
  begin
    if rising_edge(clk) then
      X <= LX;
      H <= LH;
    end if;
  end process;

  tb                                        : process
    file xfile, xbasefile, hfile, yfile     : text;
    variable xline, xbaseline, hline, yline : line;
    type bufarray is array (0 to 255) of integer;
    variable xbuf, hbuf                     : bufarray;
    variable yref                           : integer;
    variable temp                           : integer;
    variable lineread, posread : integer := 0;

  begin

    wait until falling_edge(reset);
    -- open the files:
    file_open(xfile, "x.dat", read_mode);
    file_open(xbasefile, "xbase.dat", read_mode);
    file_open(hfile, "h.dat", read_mode);
    file_open(yfile, "y.dat", read_mode);

    while not (endfile(xfile) or endfile(yfile) or endfile(hfile)) loop
      lineread := lineread + 1;
      readline(xfile, xline);
      readline(xbasefile, xbaseline);
      readline(hfile, hline);
      readline(yfile, yline);

      -- load the x-values
      for i in 0 to 255 loop
        read(xline, temp);
        xbuf(i) := temp;
      end loop;

      -- load the h-values
      for i in 0 to 255 loop
        read(hline, temp);
        hbuf(i) := temp;
      end loop;

      read(xbaseline, temp);
      xbase <= std_logic_vector(to_unsigned(temp, 8));

      read(yline, yref);


      -- now, the actual MAC-ing

      wait until rising_edge(clk);
      startmac <= '1';

      while MACDONE = '0' loop
        wait until rising_edge(clk);
        startmac <= '0';
        lx       <= std_logic_vector(to_signed(xbuf(TO_INTEGER(unsigned(xa))), 16));
        lh       <= std_logic_vector(to_signed(hbuf(TO_INTEGER(unsigned(ha))), 22));


      end loop;

      -- mac should be done; compare with Y
      if Y = std_logic_vector(to_signed(yref, 16)) then
        err <= '0';
      else
        err <= '1';
      end if;

      assert Y = std_logic_vector(to_signed(yref, 16))
        report "Output of RMAC differs from expected value"
        severity error; 

    end loop; 
    assert false
      report "End of simulation"
      severity Failure; 
  end process tb; 

END;
