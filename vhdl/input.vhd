library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

entity input is
  port ( CLK      : in  std_logic;
         INSAMPLE : in  std_logic;
         RESET    : in  std_logic;
         CNV      : out std_logic;
         SCK      : out std_logic;
         SDIA     : in  std_logic;
         SDIB     : in  std_logic;
         DOUT     : out std_logic_vector(15 downto 0);
         COUT     : out std_logic_vector(3 downto 0);
         WEOUT    : out std_logic;
         OSC      : in  std_logic_vector(3 downto 0);
         OSRST    : in  std_logic;
         OSEN     : in  std_logic;
         OSWE     : in  std_logic;
         OSD      : in  std_logic_vector(15 downto 0)
         );

end input;

architecture Behavioral of input is
-- INPUT.VHD : input from serial converters, also performs offset math.


  -- input and output registers
  signal lsck         : std_logic := '0';
  signal sdial, sdibl : std_logic := '0';


  signal sampA1 : std_logic_vector(15 downto 0) := X"8000";
  signal sampA2 : std_logic_vector(15 downto 0) := X"8000";
  signal sampA3 : std_logic_vector(15 downto 0) := X"8000";
  signal sampA4 : std_logic_vector(15 downto 0) := X"8000";
  signal sampAC : std_logic_vector(15 downto 0) := X"8000";
  signal sampB1 : std_logic_vector(15 downto 0) := X"8000";
  signal sampB2 : std_logic_vector(15 downto 0) := X"8000";
  signal sampB3 : std_logic_vector(15 downto 0) := X"8000";
  signal sampB4 : std_logic_vector(15 downto 0) := X"8000";
  signal sampBC : std_logic_vector(15 downto 0) := X"8000";



  signal smux        : std_logic_vector(15 downto 0) := (others => '0');
  signal s, os, osdo : std_logic_vector(15 downto 0) := (others => '0');

  signal sum   : std_logic_vector(16 downto 0) := (others => '0');
  signal biten : std_logic                     := '0';

  -- counters
  signal chancnt                 : std_logic_vector(3 downto 0) := (others => '0');
  signal concnt                  : integer range 0 to 127       := 0;
  signal bitcnt                  : integer range 0 to 127       := 0;
  signal concnten, bitcnten, oen : std_logic                    := '0';

  signal bitendelay : std_logic_vector(9 downto 0) := (others => '0');


  -- extra latches
  signal chancntl, chancntll : std_logic_vector(3 downto 0)
                                         := (others => '0');
  signal oenl, oenll         : std_logic := '0';

  type states is (none, newout, waitconv, startrd, sclkh, sclkl);
  signal cs, ns : states := none;



  component distram_dualport
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
  end component;


begin


  OSram : distram_dualport generic map
    ( d_width    => 16,
      addr_width => 4,
      mem_depth  => 16)
    port map (
      do         => osdo,
      di         => OSD,
      we         => OSWE,
      clk        => CLK,
      ao         => chancnt,
      ai         => OSC);


  smux <= sampA1 when chancnt = "0000" else
          sampA2 when chancnt = "0001" else
          sampA3 when chancnt = "0010" else
          sampA4 when chancnt = "0011" else
          sampAC when chancnt = "0100" else
          sampB1 when chancnt = "0101" else
          sampB2 when chancnt = "0110" else
          sampB3 when chancnt = "0111" else
          sampB4 when chancnt = "1000" else
          sampBC;

  biten <= bitendelay(2);

  main : process(CLK, RESET)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;

        SCK   <= lsck;
        CNV   <= not INSAMPLE;
        sdial <= SDIA;
        sdibl <= SDIB;


        -- input
        if biten = '1' then
          sampAC <= sampAC(14 downto 0) & sampA4(15);
          sampA4 <= sampA4(14 downto 0) & sampA3(15);
          sampA3 <= sampA3(14 downto 0) & sampA2(15);
          sampA2 <= sampA2(14 downto 0) & sampA1(15);
          sampA1 <= sampA1(14 downto 0) & sdial;

          sampB4 <= sampB4(14 downto 0) & sampB3(15);
          sampB3 <= sampB3(14 downto 0) & sampB2(15);
          sampB2 <= sampB2(14 downto 0) & sampB1(15);
          sampB1 <= sampB1(14 downto 0) & sampBC(15);
          sampBC <= sampBC(14 downto 0) & sdibl;

        end if;


        -- counters
        if INSAMPLE = '1' then
          concnt   <= 0;
        else
          if concnten = '1' then
            concnt <= concnt + 1;
          end if;
        end if;

        if INSAMPLE = '1' then
          bitcnt     <= 0;
        else
          if bitcnten = '1' then
            if bitcnt = 79 then
              bitcnt <= 0;
            else

              bitcnt <= bitcnt + 1;
            end if;
          end if;
        end if;

        if INSAMPLE = '1' then
          chancnt   <= "0000";
        else
          if oen = '1' then
            chancnt <= chancnt + 1;
          end if;
        end if;

        s    <= smux;
        if OSEN = '1' then
          os <= osdo;
        else
          os <= X"0000";
        end if;

        sum <= SXT(s - X"8000", 17) + SXT(os, 17);

        -- overflow code
        if sum(16 downto 15) = "00" then
          DOUT <= sum(15 downto 0);
        elsif sum(16 downto 15) = "11" then
          DOUT <= sum(15 downto 0);
        elsif sum(16 downto 15) = "01" then
          DOUT <= X"7FFF";
        else
          DOUT <= X"8000";
        end if;

        -- latency
        chancntl  <= chancnt;
        chancntll <= chancntl;
        COUT      <= chancntll;

        oenl  <= oen;
        oenll <= oenl;
        WEOUT <= oenll;

        -- bit enable delay
        bitendelay <= bitendelay(8 downto 0) & lsck;

      end if;
    end if;
  end process main;



  fsm : process(cs, INSAMPLE, concnt, bitcnt)
  begin
    case cs is
      when none     =>
        lsck     <= '0';
        concnten <= '0';
        bitcnten <= '0';
        oen      <= '0';
        if INSAMPLE = '1' then
          ns     <= newout;
        else
          ns     <= none;
        end if;
      when newout   =>
        lsck     <= '0';
        concnten <= '1';
        bitcnten <= '0';
        oen      <= '1';
        if concnt = 9 then
          ns     <= waitconv;
        else
          ns     <= newout;
        end if;
      when waitconv =>
        lsck     <= '0';
        concnten <= '1';
        bitcnten <= '0';
        oen      <= '0';
        --if concnt = 118 then
        if concnt = 120 then
          ns     <= startrd;
        else
          ns     <= waitconv;
        end if;
      when startrd  =>
        lsck     <= '0';
        concnten <= '0';
        bitcnten <= '0';
        oen      <= '0';
        ns       <= sclkh;
      when sclkh    =>
        lsck     <= '1';
        concnten <= '0';
        bitcnten <= '0';
        oen      <= '0';
        ns       <= sclkl;
      when sclkl   =>
        lsck     <= '0';
        concnten <= '0';
        bitcnten <= '1';
        oen      <= '0';
        if bitcnt = 79 then
          ns     <= none;
        else
          ns     <= sclkh;
        end if;
      when others   =>
        lsck     <= '0';
        concnten <= '0';
        bitcnten <= '0';
        oen      <= '0';
        ns       <= none;

    end case;
  end process fsm;
end Behavioral;

