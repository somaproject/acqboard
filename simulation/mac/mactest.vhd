library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.TextIO.all;


entity mactest is
end mactest;

architecture behavior of mactest is

  component accumulator
    generic (n :     positive := 24);
    port(
      CLK      : in  std_logic;
      P        : in  std_logic_vector(n-1 downto 0);
      CLR      : in  std_logic;
      ACC      : out std_logic_vector((n-1)+7 downto 0)
      );
  end component;


  component multiplier
    generic ( n :     positive := 24);
    port ( CLK  : in  std_logic;
           A    : in  std_logic_vector(15 downto 0);
           B    : in  std_logic_vector(21 downto 0);
           P    : out std_logic_vector(n-1 downto 0));
  end component;



  component rounding
    generic ( n :     positive := 36);
    port ( ACCL : in  std_logic_vector((n-1)+7 downto 0);
           YRND : out std_logic_vector(22 downto 0));
  end component;


  component overflow
    port ( YOVERF : out std_logic_vector(15 downto 0);
           YRNDL  : in  std_logic_vector(22 downto 0));
  end component;


  signal A             : std_logic_vector(15 downto 0) := (others => '0');
  signal B             : std_logic_vector(21 downto 0) := (others => '0');
  signal POUT          : std_logic_vector(25 downto 0) := (others => '0');
  signal expected_POUT : std_logic_vector(25 downto 0) := (others => '0');

  signal multclk, accclk  : std_logic                     := '0';
  signal P                : std_logic_vector(25 downto 0) := (others => '0');
  signal ACC              : std_logic_vector(32 downto 0);
  signal CLR, CLRL, CLRLL : std_logic;

  signal done, acc_done                    : std_logic := '0';
  signal mult_done, overf_done, round_done : std_logic := '0';

  signal rndin        : std_logic_vector(32 downto 0) := (others => '0');
  signal rndout       : std_logic_vector(22 downto 0) := (others => '0');
  signal rndout_expct : std_logic_vector(22 downto 0) := (others => '0');

  signal ofin  : std_logic_vector(22 downto 0) := (others => '0');
  signal ofout : std_logic_vector(15 downto 0) := (others => '0');

begin

  acc_uut : accumulator generic map(
    n     => 26)
    port map(
      CLK => accclk,
      P   => P,
      ACC => ACC,
      CLR => CLR
      );

  mult_uut : multiplier generic map(
    n     => 26)
    port map (
      CLK => multclk,
      A   => A,
      B   => B,
      P   => POUT);

  round_uut : rounding generic map (
    n      => 26)
    port map (
      ACCL => rndin,
      YRND => rndout);

  overflow_uut : overflow port map (
    YOVERF => ofout,
    YRNDL  => ofin);

  multclk <= not multclk after 4 ns;


  mult_test                   : process
    file mfile                : text;
    variable mline            : line;
    variable anum, bnum, ynum : integer := 0;
    variable ain              : std_logic_vector(31 downto 0);
    variable bin              : std_logic_vector(31 downto 0);
    variable yout             : std_logic_vector(31 downto 0);

  begin
    file_open(mfile, "multiply.dat", read_mode);
    while (not endfile(mfile)) loop
      readline(mfile, mline);
      hread(mline, ain);
      hread(mline, bin);
      hread(mline, yout);

      A             <= ain(15 downto 0);
      b             <= bin(21 downto 0);
      wait until rising_edge(multclk);
      wait until rising_edge(multclk);
      wait until rising_edge(multclk);
      wait until rising_edge(multclk);
      wait until rising_edge(multclk);
      expected_POUT <= yout(25 downto 0);
      assert yout(25 downto 0) = POUT
        report "Invalid multiply"
        severity error;


    end loop;
    mult_done <= '1';
    wait;

  end process;

  accclk <= not accclk after 4 ns;

  acc_test         : process
    file afile     : text;
    variable aline : line;
    variable vin   : std_logic_vector(47 downto 0);

  begin
    file_open(afile, "accumulate.dat", read_mode);
    while (not endfile(afile)) loop


      readline(afile, aline);
      clr <= '1';
      wait until rising_edge(accclk);
      clr <= '0';
      while aline'length > 0 loop

        hread(aline, vin);

        if aline'length = 0 then
          -- end of line, the most recent read was 
          -- the final product  
          wait until rising_edge(accclk);
          wait until rising_edge(accclk);
          assert ACC = vin(32 downto 0)
            report "Invalid accumulate"
            severity error;
        else
          -- normal     
          P <= vin(25 downto 0);
          wait until rising_edge(accclk);
        end if;

      end loop;

    end loop;
    acc_done <= '1';
    wait;
  end process;

  round_test       : process
    file rfile     : text;
    variable rline : line;
    variable vin   : std_logic_vector(47 downto 0);

  begin
    file_open(rfile, "convrnd.dat", read_mode);
    while (not endfile(rfile)) loop


      readline(rfile, rline);
      hread(rline, vin);
      rndin        <= vin(32 downto 0);
      hread(rline, vin);
      rndout_expct <= vin(22 downto 0);
      wait until rising_edge(accclk);

      assert rndout = vin(22 downto 0)
        report "Convergent rounding error"
        severity error;
    end loop;
    round_done <= '1';
    wait;

  end process;

  overf_test       : process
    file ofile     : text;
    variable oline : line;
    variable vin   : std_logic_vector(47 downto 0);

  begin
    file_open(ofile, "overflow.dat", read_mode);
    while (not endfile(ofile)) loop


      readline(ofile, oline);
      hread(oline, vin);
      ofin     <= vin(22 downto 0);
      hread(oline, vin);
      wait until rising_edge(accclk);
      assert ofout = vin(15 downto 0)
        report "overflow error"
        severity error;
    end loop;
    overf_done <= '1';
    wait;

  end process;

  allproc : process
  begin
    wait until acc_done = '1' and
      mult_done = '1' and
      overf_done = '1' and
      round_done = '1';
    assert false
      report "End of simulation"
      severity failure;
  end process;

end;
