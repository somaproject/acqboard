library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SendCMD is
  port ( CMDID      : in  std_logic_vector(3 downto 0);
         CMD        : in  std_logic_vector(3 downto 0);
         DATA0      : in  std_logic_vector(7 downto 0);
         DATA1      : in  std_logic_vector(7 downto 0);
         DATA2      : in  std_logic_vector(7 downto 0);
         DATA3      : in  std_logic_vector(7 downto 0);
         CHKSUM     : in  std_logic_vector(7 downto 0);
         SENDCMD    : in  std_logic;
         CMDPENDING : out std_logic := '0';
         DOUT       : out std_logic
         );
end SendCMD;

architecture Behavioral of SendCMD is
-- TEST_SENDCMD.VHD : sends commands present at inputs over an 8B/10B
-- encoded datastream at 8 MHz, and sends idle(all 0s) otherwise. 
-- CMD is sent on rising_edge(SENDCMD) and transmission is completed
-- on falling_edge(CMDPENDING)

  signal clk : std_logic := '0';

  component encode8b10b is
                          port (
                            din  : in  std_logic_vector(7 downto 0);
                            kin  : in  std_logic;
                            clk  : in  std_logic;
                            dout : out std_logic_vector(9 downto 0);
                            ce   : in  std_logic);
  end component;

  signal cmdbytepos    : natural                       := 0;
  signal cmdbits       : std_logic_vector(55 downto 0) := (others => '0');
  signal data          : std_logic_vector(7 downto 0)  := (others => '0');
  signal kchar, encode : std_logic                     := '0';
  signal encdata       : std_logic_vector(9 downto 0)  := (others => '0');
  signal pos           : integer                       := 0;

begin
  clk <= not clk after 62.5 ns;

  encoder : encode8b10b port map (
    din  => data,
    kin  => kchar,
    clk  => clk,
    dout => encdata,
    ce   => encode);





  reading : process(clk, SENDCMD)
  begin
    if rising_edge(SENDCMD) then
      cmdbytepos <= 0;
      cmdbits    <= chksum & data3 & data2 & data1 & data0 &
                    cmdid & cmd & "10111100";
      CMDPENDING <= '1';

    elsif rising_edge(clk) then


      if pos = 9 then
        pos <= 0;
      else
        pos <= pos + 1;
      end if;

      if pos = 8 then
        if cmdbytepos < 7 then


          data       <= cmdbits((cmdbytepos+1)*8-1 downto (cmdbytepos*8));
          if cmdbytepos = 0 then
            kchar    <= '1';
          else
            kchar    <= '0';
          end if;
          cmdbytepos <= cmdbytepos + 1;

        else
          data       <= "00000000";
          kchar      <= '0';
          CMDPENDING <= '0';
        end if;

      end if;



    end if;
    if pos = 9 then
      encode <= '1';
    else
      encode <= '0';
    end if;
  end process reading;

  DOUT <= encdata(pos);


end Behavioral;
