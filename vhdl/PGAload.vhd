library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PGAload is
    Port ( CLK : in std_logic;
    		 RESET : in std_logic; 
           SCLK : out std_logic;
           RCLK : out std_logic;
           SOUT : out std_logic;
           CHAN : in std_logic_vector(3 downto 0);
           GAIN : in std_logic_vector(2 downto 0);
		 FILTER : in std_logic_vector(1 downto 0); 
           GSET : in std_logic;
           ISET : in std_logic;
		 FSET : in std_logic;
		 PGARESET : in std_logic;  
           ISEL : in std_logic_vector(1 downto 0));
end PGAload;

architecture Behavioral of PGAload is
-- PGALOAD.VHD -- This maintains gain settings for the PGAs and input
-- selection for the two continuous-data channels. Every change causes
-- it to serialize out to the shift registers.  The use of LUTs as 
-- 16x1bit RAMs with async reads makes the design really compact. 

   signal zero, lsout, lsclk, latch, chansel : std_logic := '0';
   signal bitout : std_logic := '0';
   signal i, f : std_logic_vector(1 downto 0) := (others => '0');
   signal g : std_logic_vector(2 downto 0) := (others => '0');
   signal lbit : std_logic_vector(6 downto 0) := (others => '0');
   signal osel : std_logic_vector(6 downto 0) := (others => '0');
   signal addr : std_logic_vector(3 downto 0) := (others => '0');
   signal fwe, iwe, gwe : std_logic := '0';

   type states is (none, write_wait, outl, clkl1, clkh1, clkh2, clkl2,
   			    incsel, latchl, latchh1, latchh2) ;
			    
   signal cs, ns : states := none;
       
	component distRAM is
	    Port ( CLK : in std_logic;
	           WE : in std_logic;
	           A : in std_logic_vector(3 downto 0);
	           DI : in std_logic;
	           DO : out std_logic);
	end component;

begin

   -- wire up distributed RAM:
   gain_RAM_0: distRAM port map (
   		CLK => CLK,
		WE => gwe,
		A => addr,
		DI => g(0),
		DO => LBIT(0));

   gain_RAM_1: distRAM port map (
   		CLK => CLK,
		WE => gwe,
		A => addr,
		DI => g(1),
		DO => LBIT(1));

   gain_RAM_2: distRAM port map (
   		CLK => CLK,
		WE => gwe,
		A => addr,
		DI => g(2),
		DO => LBIT(2));

   filter_RAM_0: distRAM port map (
   		CLK => CLK,
		WE => fwe,
		A => addr,
		DI => f(0),
		DO => LBIT(3));

   filter_RAM_1: distRAM port map (
   		CLK => CLK,
		WE => fwe,
		A => addr,
		DI => f(1),
		DO => LBIT(4));

   input_RAM_0: distRAM port map (
   		CLK => CLK,
		WE => iwe,
		A => addr,
		DI => i(0),
		DO => LBIT(5));

   input_RAM_1: distRAM port map (
   		CLK => CLK,
		WE => iwe,	 
		A => addr,
		DI => i(1),
		DO => LBIT(6));




   clock: process(CLK, RESET) is 
   begin
   	if RESET = '1' then 
	   cs <= none; 
	else
	   if rising_edge(CLK) then
		cs <= ns;

		-- zero for pga reset
		if PGARESET = '1' then
		   zero <= '1';
		elsif cs = latchh2 then
		   zero <= '0';
		end if;

		--outsel counter
		if  cs = none then
		   osel <= (others => '0');
		elsif cs = incsel then
		   osel <= osel + 1;
		end if;

		--output latching
		SOUT <= lsout;
		SCLK <= lsclk;
		RCLK <= latch; 

	   end if; 
	end if; 

   end process clock; 



   -- FSM for output
   fsm: process(cs, gset, iset, pgareset, osel) is
   begin
   	case cs is
		when none =>
			lsclk <= '0';
			latch <= '0';
			chansel <= '0'; 
			if gset = '1' or iset = '1' or fset = '1' or pgareset = '1' then
			   ns <= write_wait;
			else
			   ns <= none;
 			end if;
		when write_wait => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '0';
			ns <= outl;
		when outl => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '1';
			ns <= clkl1;
		when clkl1 => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '1';
			ns <= clkh1;
		when clkh1 => 
			lsclk <= '1';
			latch <= '0';
			chansel <= '1';
			ns <= clkh2;
		when clkh2 => 
			lsclk <= '1';
			latch <= '0';
			chansel <= '1';
			ns <= clkl2;
		when clkl2 => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '1';
			ns <= incsel;
		when incsel => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '1';
			if osel = "1001111" then
				ns <= latchl;
			else 
				ns <= clkl1;
			end if;
		when latchl => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '1';
			ns <= latchh1;
		when latchh1 => 
			lsclk <= '0';
			latch <= '1';
			chansel <= '1';
			ns <= latchh2;
		when latchh2 => 
			lsclk <= '0';
			latch <= '1';
			chansel <= '1';
			ns <= none;
		when others => 
			lsclk <= '0';
			latch <= '0';
			chansel <= '0';
			ns <= none;
	end case;
   end process; 

   --- combinational stuff
   g <= "000" when zero = '1' else GAIN;
   i <= "00" when zero = '1' else ISEL;
   f <= "00" when zero = '1' else FILTER;

   gwe <= GSET or zero;
   fwe <= FSET or zero;
   iwe <= ISET or zero;

   lsout <= bitout when zero ='0' else '0';
   bitout <= lbit(0) when osel(2 downto 0) = "000" else
   		   lbit(1) when osel(2 downto 0) = "001" else
		   lbit(2) when osel(2 downto 0) = "010" else
		   lbit(3) when osel(2 downto 0) = "011" else
		   lbit(4) when osel(2 downto 0) = "100" else
		   lbit(5) when osel(2 downto 0) = "101" else
		   lbit(6) when osel(2 downto 0) = "110" else
		   '0';
  
  addr <= osel(6 downto 3) when chansel = '1' else CHAN;

  

end Behavioral; 