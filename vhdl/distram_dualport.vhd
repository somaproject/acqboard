library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- Totally from the xilinx manual, this should infer dual-port
-- dist-ram

entity distram_dualport is
  generic(
    d_width    :     integer := 16;
    addr_width :     integer := 3;
    mem_depth  :     integer := 8
    );
  port (
    do         : out std_logic_vector(d_width - 1 downto 0);
    we, clk    : in  std_logic;
    di         : in  std_logic_vector(d_width - 1 downto 0);
    ao, ai     : in  std_logic_vector(addr_width - 1 downto 0));
end distram_dualport;


architecture behavioral of distram_dualport is
  type mem_type is array (
    mem_depth - 1 downto 0) of
    std_logic_vector (d_width - 1 downto 0);
  signal mem : mem_type := (others => X"0000");


begin
  process(clk, we, ai, di)
  begin
    if (rising_edge(clk)) then
      if (we = '1') then
        mem(conv_integer(ai)) <= di;
      end if;
    end if;
  end process;

  process(ao)
  begin
    do                        <= mem(conv_integer(ao));
  end process;
end behavioral;
