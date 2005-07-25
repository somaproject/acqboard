library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity overflow is
  port ( YOVERF : out std_logic_vector(15 downto 0);
         YRNDL  : in  std_logic_vector(22 downto 0));
end overflow;

architecture Behavioral of overflow is
-- OVERFLOW.VHD : overflow detection to prevent wrap-around
  signal rndmux : std_logic_vector(1 downto 0) := "00";

begin
  process (YRNDL, rndmux)
  begin
    if YRNDL(22 downto 15) = "00000000" or
      YRNDL(22 downto 15) = "11111111" then
      YOVERF   <= YRNDL(15 downto 0);
    else
      if YRNDL(22) = '0' then
        YOVERF <= "0111111111111111";
      else
        YOVERF <= "1000000000000000";
      end if;
    end if;
  end process;

end Behavioral;
