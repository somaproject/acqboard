-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;


package Silly is
  type chanarray is array (9 downto 0) of integer;
end Silly;


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.Silly.all;



entity PGA is
  port ( SCLK    : in  std_logic;
         RCLK    : in  std_logic;
         SIN     : in  std_logic;
         GAINS   : out chanarray;
         FILTERS : out chanarray;
         INSELA  : out integer;
         INSELB  : out integer
         );
end PGA;

architecture Behavioral of PGA is
-- simple systme to map the serial input stream to actual values for the
-- PGAs, filters, and input selection

  signal rbits, fbits : std_logic_vector(6*8-1 downto 0) := (others => '0');

  type gainarray is array (9 downto 0) of std_logic_vector(2 downto 0);

  signal gain_bits : gainarray := (others => "000");

  signal filter_bits : std_logic_vector(9 downto 0) := (others => '0');

  signal insela_bits, inselb_bits : std_logic_vector(1 downto 0) := (others => '0');


begin


  process (SCLK)
  begin
    if rising_edge(SCLK) then
      rbits <= rbits(6*8-2 downto 0) & SIN;

    end if;
  end process;


  process (RCLK)
  begin
    if rising_edge(RCLK) then
      fbits <= rbits;
    end if;
  end process;


  process(gain_bits, filter_bits, inselA_bits, inselB_bits)
  begin
    for i in 0 to 9 loop
      gains(i)      <= TO_INTEGER(unsigned(gain_bits(i)));
      if filter_bits(i) = '1' then
        filters (i) <= 1;
      else
        filters (i) <= 0;
      end if;

    end loop;
    INSELA <= TO_INTEGER(unsigned(inselA_bits));
    INSELB <= TO_INTEGER(unsigned(inselB_bits));

  end process;

  -- hook up the gains
  filter_bits(1) <= fbits(47);
  gain_bits(1)   <= fbits(44) & fbits(45) & fbits(46);
  gain_bits(0)   <= fbits(43 downto 41);
  filter_bits(0) <= fbits(40);

  filter_bits(3) <= fbits(39);
  gain_bits(3)   <= fbits(36) & fbits(37) & fbits(38);
  gain_bits(2)   <= fbits(35 downto 33);
  filter_bits(2) <= fbits(32);

  inselA_bits(1) <= fbits(29);
  inselA_bits(0) <= fbits(28);

  gain_bits(4)   <= fbits(27 downto 25);
  filter_bits(4) <= fbits(24);

  inselB_bits(1) <= fbits(21);
  inselB_bits(0) <= fbits(20);

  gain_bits(5)   <= fbits(19 downto 17);
  filter_bits(5) <= fbits(16);

  filter_bits(7) <= fbits(15);
  gain_bits(7)   <= fbits(12) & fbits(13) & fbits(14);
  gain_bits(6)   <= fbits(11 downto 9);
  filter_bits(6) <= fbits(8);

  filter_bits(9) <= fbits(7);
  gain_bits(9)   <= fbits(4) & fbits(5) & fbits(6);
  gain_bits(8)   <= fbits(3 downto 1);
  filter_bits(8) <= fbits(0);



end Behavioral;
