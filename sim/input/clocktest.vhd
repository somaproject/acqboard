library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clocktest is
end clocktest;

architecture behavior of clocktest is


  component clocks
    port (
      CLKIN     : in  std_logic;
      CLK       : out std_logic;
      CLK8      : out std_logic;
      RESET     : in  std_logic;
      INSAMPLE  : out std_logic;
      OUTSAMPLE : out std_logic;
      OUTBYTE   : out std_logic := '0';
      SPICLK    : out std_logic);
  end component;

  signal CLK       : std_logic := '0';
  signal CLKIN     : std_logic := '0';
  signal CLK8      : std_logic := '0';
  signal OUTSAMPLE : std_logic := '0';
  signal OUTBYTE   : std_logic := '0';

  signal INSAMPLE : std_logic := '0';
  signal RESET    : std_logic := '1';
  signal SPICLK   : std_logic := '0';


  constant insample_period : time := 5208.333 ns;
  
begin

  uut : clocks
    port map(
      CLKIN => CLKIN,
      CLK      => CLK,
      CLK8 => CLK8,
      RESET => RESET,
      INSAMPLE => INSAMPLE,
      OUTSAMPLE => OUTSAMPLE,
      OUTBYTE => OUTBYTE,
      SPICLK => SPICLK);

  

  
  CLKIN <= not CLKIN after 13.888888 ns;

  RESET <= '0' after 60 ns;

end;
