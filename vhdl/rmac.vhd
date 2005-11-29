library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

use IEEE.STD_LOGIC_UNSIGNED.all;
use std.textio.all;

-- Uncomment the following lines to use the declarations that are
-- provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RMAC is
  port ( CLK      : in  std_logic;
         X        : in  std_logic_vector(15 downto 0);
         XA       : out std_logic_vector(7 downto 0);
         H        : in  std_logic_vector(21 downto 0);
         HA       : out std_logic_vector(7 downto 0);
         XBASE    : in  std_logic_vector(7 downto 0);
         STARTMAC : in  std_logic;
         MACDONE  : out std_logic;
         RESET    : in  std_logic;
         Y        : out std_logic_vector(15 downto 0));
end RMAC;

architecture Behavioral of RMAC is
-- RMAC.VHD : main repeated multiply-accumulator system.

-- resolution of intermediate MAC
  constant n         : positive                           := 26;
  constant L         : positive                           := 144;
  signal   lxa, lha  : std_logic_vector(7 downto 0)       := (others => '0');
  signal   p         : std_logic_vector((n-1) downto 0)   := (others => '0');
  signal   acc, accl : std_logic_vector((7+n-1) downto 0) := (others => '0');
  signal   yrnd      : std_logic_vector(22 downto 0)      := (others => '0');
  signal   yoverf    : std_logic_vector(15 downto 0)      := (others => '0');


  -- fsm signals
  type states is (none, addrrst, macwait, accen, latch_out,
                  post_ovrf, post_rnd, rmac_done);
  signal ns, cs : states                     := none;
  signal clr    : std_logic                  := '0';
  signal maccnt : integer range 255 downto 0 := 0;

  -- component declarations
  component multiplier
    generic ( n :     positive := 24);
    port ( CLK  : in  std_logic;
           A    : in  std_logic_vector(15 downto 0);
           B    : in  std_logic_vector(21 downto 0);
           P    : out std_logic_vector(n-1 downto 0));
  end component;

  component accumulator
    generic ( n :     positive := 24);
    port ( CLK  : in  std_logic;
           P    : in  std_logic_vector(n-1 downto 0);
           ACC  : out std_logic_vector((n-1)+7 downto 0);
           CLR  : in  std_logic);
  end component;

  component rounding

    generic ( n :     positive := 24);
    port ( ACCL : in  std_logic_vector((n-1)+7 downto 0);
           YRND : out std_logic_vector(22 downto 0));
  end component;

  component overflow
    port ( YOVERF : out std_logic_vector(15 downto 0);
           YRNDL  : in  std_logic_vector(22 downto 0));
  end component;

begin
  -- component instantiation:
  multiplier_inst : multiplier
    generic map (n => n)
    port map( CLK  => CLK,
              A    => x,
              B    => h,
              P    => p);

  accumulator_inst : accumulator
    generic map (n   => n)
    port map( CLK    => CLK,
              P      => p,
              ACC    => acc,
              CLR    => clr);
  rounding_inst    : rounding
    generic map (n   => n)
    port map( ACCL   => accl,
              yrnd   => yrnd);
  overflow_inst    : overflow
    port map( YOVERF => yoverf,
              YRNDL  => yrnd);

  -- general connections
  XA <= lxa;
  HA <= lha;

  -- clock 
  clock : process (CLK, RESET, cs, ns, STARTMAC)
  begin
    if RESET = '1' then
      cs   <= none;
    else
      if rising_edge(CLK) then
        cs <= ns;



        Y      <= yoverf;
        if cs = accen then
          accl <= acc;
        end if;

        -- main multiply-accumulate counter
        if cs = addrrst then
          maccnt <= 0;
        elsif cs = macwait then
          maccnt <= maccnt + 1;
        end if;

        -- address counters
        if cs = addrrst then
          lxa <= XBASE;
          lha <= (others => '0');
        elsif MACCNT < L then
          lxa <= lxa -1;                -- count backwards through samples, 
          lha <= lha + 1;               -- count forward through FIR vector 
        end if;
      end if;
    end if;



  end process clock;

  -- clear for accumulator
  clr <= '1' when maccnt = 4 else
         '0';

  fsm : process (cs, ns, STARTMAC, maccnt)
  begin
    case cs is
      when none      =>
        MACDONE <= '0';
        if STARTMAC = '1' then
          ns    <= addrrst;
        else
          ns    <= none;
        end if;
      when addrrst   =>
        MACDONE <= '0';
        ns      <= macwait;
      when macwait   =>
        MACDONE <= '0';
        if maccnt = L+5 then
          ns    <= accen;
        else
          ns    <= macwait;
        end if;
      when accen     =>
        MACDONE <= '0';
        ns      <= latch_out;
      when latch_out =>
        MACDONE <= '0';
        ns      <= rmac_done;
      when rmac_done =>
        MACDONE <= '1';
        ns      <= none;
      when others    =>
        MACDONE <= '0';
        ns      <= none;
    end case;
  end process fsm;


end Behavioral;
