library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RMAC is
    Port ( CLK2X : in std_logic;
           X : in std_logic_vector(15 downto 0);
           XA : out std_logic_vector(6 downto 0);
           H : in std_logic_vector(21 downto 0);
           HA : out std_logic_vector(6 downto 0);
           XBASE : in std_logic_vector(6 downto 0);
           STARTMAC : in std_logic;
		 RESET : in std_logic; 
           Y : out std_logic_vector(15 downto 0));
end RMAC;

architecture Behavioral of RMAC is
-- RMAC.VHD -- main repeated multiply-accumulator system. 
   -- resolution of intermediate MAC
   constant n : positive := 36; 
   
   signal xl: std_logic_vector(15 downto 0) := (others => '0');
   signal hl: std_logic_vector(21 downto 0) := (others => '0');
   signal lxa, lha: std_logic_vector(6 downto 0) := (others => '0');
   signal p: std_logic_vector((n-1) downto 0) := (others => '0');
   signal acc, accl : std_logic_vector((7+n-1) downto 0) := (others=> '0');
   signal yrnd, yrndl : std_logic_vector(22 downto 0) := (others => '0');
   signal yovrf: std_logic_vector(15 downto 0) := (others => '0');

   -- fsm signals
   type states is (none, addrrst, macwait, accen, latch_out, 
   				post_ovrf, post_rnd);
   signal ns, cs : states := none;
   signal clr : std_logic := '0';
   signal maccnt : integer range 255 downto 0 := 0;
 
   -- component declarations
   component multiplier is	   
    Generic ( n: positive := 24); 
    Port ( CLK2X : in std_logic;
           A : in std_logic_vector(15 downto 0);
           B : in std_logic_vector(21 downto 0);
           P : out std_logic_vector(n-1 downto 0));
   end component; 

   component accumulator is
    Generic ( n: positive := 24); 
    Port ( CLK2X : in std_logic;
		 P : in std_logic_vector(n-1 downto 0);
           ACC : out std_logic_vector((n-1)+7 downto 0);
           CLR : in std_logic);
   end component;

   component rounding is
    Generic ( n: positive := 24); 
       Port ( ACCL : in std_logic_vector((n-1)+7 downto 0);
	         YRND : out std_logic_vector(22 downto 0));
   end component;

   component overflow is
    Port ( YOVERF : out std_logic_vector(15 downto 0);
           YRNDL : in std_logic_vector(22 downto 0));
   end component;
     
begin
  -- component instantiation:
  multiplier_inst: multiplier
  	generic map (n => n)
  	port map( CLK2X => CLK2X,
			A => xl,
			B => hl,
			P => p);
	
  accumulator_inst: accumulator
  	generic map (n => n)
	port map( CLK2X => CLK2X,
			P => p,
			ACC => acc,
			CLR => clr);
  rounding_inst : rounding
  	generic map (n => n)
	port map( ACCL => accl,
			yrnd => yrnd);
  overflow_inst : overflow 
  	port map( YOVERF => yovrf,
			YRNDL => yrndl);

  -- general connections
  XA <= lxa;
  HA <= lha; 
			
  -- clock 
  clock: process (CLK2X, RESET, cs, ns, STARTMAC) is
  begin
  	if RESET = '1' then
		cs <= none;
	else
		if rising_edge(CLK2X) then
		    cs <= ns; 

		    -- latch inputs
		    xl <= X;
		    hl <= H;

		    -- latch intermediate values
		    yrndl <= yrnd;
		    Y <= yovrf;
		    if cs = accen then
		    	  accl <= acc;
		    end if; 

		    -- main multiply-accumulate counter
		    if cs = addrrst then
		    	  maccnt <= 0;
		    else 
		    	  maccnt <= maccnt + 1;
              end if; 

		    -- address counters
		    if cs = addrrst then
		    	  lxa <= XBASE;
			  lha <= (others => '0');
	         else
			  lxa <= lxa -1; -- count backwards through samples, 
			  lha <= lha + 1;-- count forward through FIR vector 
		    end if; 
		end if;
	end if; 
  
  	
  
  end process clock; 	
  
  -- clear for accumulator
  clr <= '1' when maccnt = 8 else
  		'0'; 							

  fsm: process (cs, ns, STARTMAC, maccnt) is
  begin
  	case cs is
		when none => 
		  if STARTMAC = '1' then
		  	ns <= addrrst;
		  else
		  	ns <= none;
		  end if;
		when addrrst => 
		  ns <= macwait;
		when macwait => 
		  if maccnt  = 139 then
		  	ns <= accen;
		  else
		  	ns <= macwait;
		  end if;
		when accen => 
		  ns <= post_rnd;		  
		when post_rnd => 
		  ns <= post_ovrf;		  
		when post_ovrf => 
		  ns <= latch_out;		  
		when latch_out => 
		  ns <= none;		  
		when others => 
		  ns <= none;		  
	end case; 	  		
  end process fsm; 
   

end Behavioral;
