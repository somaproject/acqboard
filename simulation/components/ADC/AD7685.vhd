library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;


library UNISIM;
use UNISIM.VComponents.all;

entity AD7685 is
  generic (filename :     string    := "adcin.dat" );
  port ( RESET      : in  std_logic;
         SCK       : in  std_logic := '0';
         CNV     : in  std_logic;
         SDO      : out std_logic;
         SDI: in std_logic; 
         CH_VALUE  : in  integer;
         CH_OUT    : out integer   := 32768;
         FILEMODE   : in  std_logic;
         BUSY       : out std_logic;
         INPUTDONE  : out std_logic);
end AD7685;

architecture Behavioral of AD7685 is
-- a behavioral simulation of the AD7685, reads in input values from
-- filename, or from channel values, depending on filemode.
-- the filename has a column of unsigned INTS < 2**16-1
-- RESET is necessary for setup; INPUTDONE goes high when the end of
-- the input file is reached.
--

  constant sck_to_sdo : time := 14 ns;
  constant cnv_delay  : time := 2.2 us;

  signal     channel_bits : std_logic_vector(15 downto 0);
  signal     bitpos                       : integer   := 0;
  signal     filedone                     : std_logic := '0';

begin

-- reset closes the file, opens the file, etc. 


  INPUTDONE  <= filedone;


  SDO <= channel_bits(15) after sck_to_sdo;
  
  process(CNV, SCK, RESET, FILEMODE, CH_VALUE)
    file inputfile                        : text;
    variable L                            : line;

    variable channel : integer;
  begin
    if falling_edge(RESET) then
      
      filedone      <= '0';
      if filemode = '1' then
        file_open(inputfile, filename, read_mode);
      end if;
      
      channel_bits <= (others => '0');
      
      CH_OUT       <= 32768;
      
    elsif rising_edge(RESET) then
      file_close(inputfile);

    elsif rising_edge(CNV) then
      

      if filemode = '1' then
        if not endfile(inputfile) then
          
          readline(inputfile, L);
          read(L, channel);
          channel_bits <= conv_std_logic_vector(channel, 16);
          CH_OUT       <= channel;

        else
          filedone <= '1';
          channel := 32768;
          channel_bits <= conv_std_logic_vector(channel, 16);
          CH_OUT       <= channel;
        end if;
      else
        channel_bits <= conv_std_logic_vector(CH_VALUE, 16);
      end if;

    else
      if falling_edge(SCK) then
        channel_bits <= channel_bits(14 downto 0) & SDI;
      end if; 
    end if; 
  end process; 


end Behavioral;
