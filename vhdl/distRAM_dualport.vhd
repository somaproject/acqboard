library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all; 

-- Totally from the xilinx manual, this should infer dual-port
-- dist-ram

entity distRAM_dualport is 
  generic( 
        d_width : integer := 16; 
        addr_width : integer := 3; 
        mem_depth : integer := 8 
        ); 
  port ( 
        do : out STD_LOGIC_VECTOR(d_width - 1 downto 0); 
        we, clk : in STD_LOGIC; 
        di : in STD_LOGIC_VECTOR(d_width - 1 downto 0); 
        ao, ai : in STD_LOGIC_VECTOR(addr_width - 1 downto 0)); 
end distRAM_dualport; 


architecture behavioral of distRAM_dualport is 
  type mem_type is array ( 
        mem_depth - 1 downto 0) of 
        STD_LOGIC_VECTOR (d_width - 1 downto 0); 
  signal mem : mem_type; 


begin 
  process(clk, we, ai) 
  begin 
      if (rising_edge(clk)) then 
          if (we = '1') then 
              mem(conv_integer(ai)) <= di; 
          end if; 
      end if; 
  end process; 
  process(ao) 
  begin 
    do <= mem(conv_integer(ao)); 
  end process; 
end behavioral; 