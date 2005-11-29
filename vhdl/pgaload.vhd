library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity PGAload is
  port ( CLK      : in  std_logic;
         RESET    : in  std_logic;
         SCLK     : out std_logic;
         RCLK     : out std_logic;
         SOUT     : out std_logic;
         CHAN     : in  std_logic_vector(3 downto 0);
         GAIN     : in  std_logic_vector(2 downto 0);
         FILTER   : in  std_logic;
         GSET     : in  std_logic;
         ISET     : in  std_logic;
         FSET     : in  std_logic;
         PGARESET : in  std_logic;
         ISEL     : in  std_logic_vector(1 downto 0));
end PGAload;

architecture Behavioral of PGAload is
-- PGALOAD.VHD: This maintains gain settings for the PGAs and input
-- selection for the two continuous-data channels. Every change causes
-- it to serialize out to the shift registers.  The use of LUTs as 
-- 16x1bit RAMs with async reads makes the design really compact. 

  signal fwe, iwe, gwe : std_logic                    := '0';
  signal g             : std_logic_vector(2 downto 0) := (others => '0');
  signal f             : std_logic                    := '0';
  signal i             : std_logic_vector(1 downto 0) := (others => '0');

  signal d    : std_logic_vector(5 downto 0) := (others => '0');
  signal dout : std_logic                    := '0';

  signal lsout, lsclk, latch : std_logic := '0';

  signal chanL, chanmux : std_logic_vector(3 downto 0)
 := (others => '0');

  signal zero : std_logic := '0';

  signal oaddr : std_logic_vector(5 downto 0) := (others => '0');
  signal osel  : std_logic_vector(6 downto 0) := (others => '0');

  signal chansel : std_logic := '0';



  type states is (none, writew, outl, clkl1, clkh1, clkh2, clkl2,
                  incsel, latchl, latchh1, latchh2);
  signal cs, ns : states := none;

  component distRAM 
                      port ( CLK : in  std_logic;
                             WE  : in  std_logic;
                             A   : in  std_logic_vector(3 downto 0);
                             DI  : in  std_logic;
                             DO  : out std_logic);
  end component;

begin

  -- wire up distributed RAM:

  ramg0 : distRAM port map (
    CLK => clk,
    WE  => gwe,
    A   => chanmux,
    DI  => g(0),
    DO  => d(0));

  ramg1 : distRAM port map (
    CLK => clk,
    WE  => gwe,
    A   => chanmux,
    DI  => g(1),
    DO  => d(1));

  ramg2 : distRAM port map (
    CLK => clk,
    WE  => gwe,
    A   => chanmux,
    DI  => g(2),
    DO  => d(2));

  ramf : distRAM port map (
    CLK => clk,
    WE  => fwe,
    A   => chanmux,
    DI  => f,
    DO  => d(3));

  rami0 : distRAM port map (
    CLK => clk,
    WE  => iwe,
    A   => chanmux,
    DI  => i(0),
    DO  => d(4));

  rami1 : distRAM port map (
    CLK => clk,
    WE  => iwe,
    A   => chanmux,
    DI  => i(1),
    DO  => d(5));


  g(0) <= GAIN(0) and not zero;
  g(1) <= GAIN(1) and not zero;
  g(2) <= GAIN(2) and not zero;

  gwe <= zero or GSET;

  f   <= FILTER and not zero;
  fwe <= FSET or zero;

  i(0) <= ISEL(0) and not zero;
  i(1) <= ISEL(1) and not zero;

  iwe <= ISET or zero;

  chanmux <= CHAN when chansel = '0' else osel(6 downto 3);

  dout <= d(0) when osel(2 downto 0) = "000" else
          d(1) when osel(2 downto 0) = "001" else
          d(2) when osel(2 downto 0) = "010" else
          d(3) when osel(2 downto 0) = "011" else
          d(4) when osel(2 downto 0) = "100" else
          d(5);

  lsout <= dout and (not zero);


  OSEL <= "0001011" when oaddr = "000000" else
          "0001000" when oaddr = "000001" else
          "0001001" when oaddr = "000010" else
          "0001010" when oaddr = "000011" else
          "0000010" when oaddr = "000100" else
          "0000001" when oaddr = "000101" else
          "0000000" when oaddr = "000110" else
          "0000011" when oaddr = "000111" else
          "0011011" when oaddr = "001000" else
          "0011000" when oaddr = "001001" else
          "0011001" when oaddr = "001010" else
          "0011010" when oaddr = "001011" else
          "0010010" when oaddr = "001100" else
          "0010001" when oaddr = "001101" else
          "0010000" when oaddr = "001110" else
          "0010011" when oaddr = "001111" else
          "0000000" when oaddr = "010000" else
          "0000000" when oaddr = "010001" else
          "0000101" when oaddr = "010010" else
          "0000100" when oaddr = "010011" else
          "0100010" when oaddr = "010100" else
          "0100001" when oaddr = "010101" else
          "0100000" when oaddr = "010110" else
          "0100011" when oaddr = "010111" else
          "0000000" when oaddr = "011000" else
          "0000000" when oaddr = "011001" else
          "0001101" when oaddr = "011010" else
          "0001100" when oaddr = "011011" else
          "0101010" when oaddr = "011100" else
          "0101001" when oaddr = "011101" else
          "0101000" when oaddr = "011110" else
          "0101011" when oaddr = "011111" else
          "0111011" when oaddr = "100000" else
          "0111000" when oaddr = "100001" else
          "0111001" when oaddr = "100010" else
          "0111010" when oaddr = "100011" else
          "0110010" when oaddr = "100100" else
          "0110001" when oaddr = "100101" else
          "0110000" when oaddr = "100110" else
          "0110011" when oaddr = "100111" else
          "1001011" when oaddr = "101000" else
          "1001000" when oaddr = "101001" else
          "1001001" when oaddr = "101010" else
          "1001010" when oaddr = "101011" else
          "1000010" when oaddr = "101100" else
          "1000001" when oaddr = "101101" else
          "1000000" when oaddr = "101110" else
          "1000011" when oaddr = "101111" else
          "0000000";

  clock : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        -- zero for pga reset
        if PGARESET = '1' then
          zero <= '1';
        elsif cs = latchh2 then
          zero <= '0';
        end if;

        if cs = none then
          oaddr   <= (others => '0');
        else
          if cs = incsel then
            oaddr <= oaddr + 1;
          end if;
        end if;



        --output latching
        SOUT <= lsout;
        SCLK <= lsclk;
        RCLK <= latch;

      end if;
    end if;

  end process clock;



  -- FSM for output
  fsm : process(cs, gset, iset, pgareset, fset, oaddr)
  begin
    case cs is
      when none   =>
        lsclk   <= '0';
        latch   <= '0';
        chansel <= '0';
        if gset = '1' or iset = '1' or fset = '1' or pgareset = '1' then
          ns    <= writew;
        else
          ns    <= none;
        end if;
      when writew =>
        lsclk   <= '0';
        latch   <= '0';
        chansel <= '0';
        ns      <= outl;
      when outl   =>
        lsclk   <= '0';
        latch   <= '0';
        chansel <= '1';
        ns      <= clkl1;
      when clkl1  =>
        lsclk   <= '0';
        latch   <= '0';
        chansel <= '1';
        ns      <= clkh1;
      when clkh1  =>
        lsclk   <= '1';
        latch   <= '0';
        chansel <= '1';
        ns      <= clkh2;
      when clkh2  => 
        lsclk <= '1';
        latch <= '0';
        chansel <= '1';
        ns <= clkl2;
      when clkl2 => 
        lsclk <= '0';
        latch <= '0';
        chansel <= '1';
        ns <= incsel;
      when incsel => 
        lsclk <= '0';
        latch <= '0';
        chansel <= '1';
        if oaddr = "101111" then
          ns <= latchl;
        else 
          ns <= clkl1;
        end if;
      when latchl => 
        lsclk <= '0';
        latch <= '0';
        chansel <= '1';
        ns <= latchh1;
      when latchh1 => 
        lsclk <= '0';
        latch <= '1';
        chansel <= '1';
        ns <= latchh2;
      when latchh2 => 
        lsclk <= '0';
        latch <= '1';
        chansel <= '1';
        ns <= none;
      when others => 
        lsclk <= '0';
        latch <= '0';
        chansel <= '0';
        ns <= none;
    end case;
  end process; 

end Behavioral; 
