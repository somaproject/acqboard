library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity raw is
  port ( CLK  : in  std_logic;
         DIN  : in  std_logic_vector(15 downto 0);
         CIN  : in  std_logic_vector(3 downto 0);
         WEIN : in  std_logic;
         CHAN : in  std_logic_vector(3 downto 0);
         Y    : out std_logic_vector(15 downto 0);
         YEN  : out std_logic);

end raw;

architecture Behavioral of raw is
-- RAW.VHD : Module allows us to read out the raw acquired
-- samples of any of the 10 ADC inputs


begin
  main : process(CLK)
  begin
    if rising_edge(CLK) then
      if CIN = CHAN and WEIN = '1' then
        Y   <= DIN;
        YEN <= '1';
      else
        YEN <= '0';
      end if;
    end if;
  end process;

end Behavioral;
