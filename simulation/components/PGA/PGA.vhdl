library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;




entity PGA is
  port ( SCLK  : in  std_logic;
         RCLK  : in  std_logic;
         SIN   : in  std_logic;
         BOUTS : out std_logic_vector(6*8-1 downto 0) );
end PGA;

architecture Behavioral of PGA is
-- simple systme to map the serial input stream to actual values for the
-- PGAs, filters, and input selection

  signal rbits, fbits : std_logic_vector(6*8-1 downto 0) := (others => '0');

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
  bouts     <= fbits;



end Behavioral;
