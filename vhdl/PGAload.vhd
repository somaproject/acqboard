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
           ISEL : in std_logic_vector(3 downto 0));
end PGAload;

architecture Behavioral of PGAload is
-- PGALOAD.VHD -- This maintains gain settings for the PGAs and input
-- selection for the two continuous-data channels. Every change causes
-- it to serialize out to the shift registers. It also has the gain-setting
-- to PGA look-up table. 

   signal isetl, gwe, fwe : std_logic := '0';
   signal gainl : std_logic_vector(4 downto 0) := (others => '0');
   signal chanl, isell : std_logic_vector(3 downto 0) := (others => '0');

   signal cin, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c
			: std_logic_vector(4 downto 0) := (others => '0');
   signal inputsel, input : std_logic_vector(1 downto 0) := (others => '0');
   signal msbout, shiften, latch, lsclk : std_logic := '0';
   signal shiftreg, shiftregin : 
   		std_logic_vector(7 downto 0) := (others => '0');

   type states is (none, rst_chan_cnt, rst_shft_cnt, clkl1, clkh1, 
   	    clkh2, clkl2, shift, next_chan, latchh1, latchh2); 

   signal cs, ns  : states := none;
   signal chancnt, shiftcnt : integer range 10 downto 0 := 0;
 




begin

   clock: process(CLK, cs, ns, ISEL, ISET, GAIN, GSET, CHAN, FSET, input,
      		  shiftreg, msbout, lsclk, latch, RESET) is
   begin
   	if RESET = '1' then
		cs <= none; 
	else
		if rising_edge(CLK) then
			cs <= ns; 

			-- input latches
			if ISET = '1' then
			 	isell <= ISEL;
			end if; 
			isetl <= ISET;
			cin <= (filter & gain) ; 
			gwe <= GSET;
			fwe <= FSET;
			chanl <= CHAN;

			-- gain registers for each channel
			if gwe = '1' then 
			  case chanl is
				when "0000" => c1(2 downto 0) <= cin(2 downto 0); 
				when "0001" => c2(2 downto 0) <= cin(2 downto 0); 
				when "0010" => c3(2 downto 0) <= cin(2 downto 0); 
				when "0011" => c4(2 downto 0) <= cin(2 downto 0); 
				when "0100" => c5(2 downto 0) <= cin(2 downto 0); 
				when "0101" => c6(2 downto 0) <= cin(2 downto 0); 
				when "0110" => c7(2 downto 0) <= cin(2 downto 0); 
				when "0111" => c8(2 downto 0) <= cin(2 downto 0); 
				when "1000" => c9(2 downto 0) <= cin(2 downto 0); 
				when "1001" => c10(2 downto 0) <= cin(2 downto 0); 
				when others => Null;
				end case; 
			end if; 

			if fwe = '1' then 
			  case chanl is
				when "0000" => c1(4 downto 3) <= cin(4 downto 3); 
				when "0001" => c2(4 downto 3) <= cin(4 downto 3); 
				when "0010" => c3(4 downto 3) <= cin(4 downto 3); 
				when "0011" => c4(4 downto 3) <= cin(4 downto 3); 
				when "0100" => c5(4 downto 3) <= cin(4 downto 3); 
				when "0101" => c6(4 downto 3) <= cin(4 downto 3); 
				when "0110" => c7(4 downto 3) <= cin(4 downto 3); 
				when "0111" => c8(4 downto 3) <= cin(4 downto 3); 
				when "1000" => c9(4 downto 3) <= cin(4 downto 3); 
				when "1001" => c10(4 downto 3) <= cin(4 downto 3); 
				when others => Null;
				end case; 
			end if; 


 
			
			if cs = rst_shft_cnt then
				shiftreg <= shiftregin;
			else
				if shiften = '1' then
					shiftreg <= shiftreg(6 downto 0) & '0';
				end if;
			end if; 

			-- fsm-related counters
			if cs = rst_chan_cnt then
				chancnt <= 0;
			elsif cs = next_chan then
				chancnt <= chancnt + 1;
			end if; 
			if cs = rst_shft_cnt then
				shiftcnt <= 0;
			elsif cs = shift then
				shiftcnt <= shiftcnt + 1;
			end if; 

			-- output latches
			SOUT <= msbout;
			SCLK <= lsclk;
			RCLK <= latch; 

		end if;
	end if; 
   end process clock; 

   msbout <= shiftreg(7); 
   shiftregin <= (input(1) & '0' & c & input(0));
   -- PGA channel selection
   c <= c1 when chancnt = 0 else
   		    c2 when chancnt = 1 else
   		    c3 when chancnt = 2 else
   		    c4 when chancnt = 3 else
   		    c5 when chancnt = 4 else
   		    c6 when chancnt = 5 else
   		    c7 when chancnt = 6 else
   		    c8 when chancnt = 7 else
   		    c9 when chancnt = 8 else
   		    c10;

   -- input selection for PGA		    
   input <= isell(1 downto 0) when inputsel = "00" else
   		  isell(3 downto 2) when inputsel = "01" else
		  "00" when inputsel = "10" else
		  "00" when inputsel = "11" ; 
   inputsel <= "00" when chancnt = 5 else
   			"01" when chancnt = 6 else
			"10"; 
   


   fsm : process (cs, ns, gwe, fwe, isetl, shiftcnt, chancnt) is
   begin
   	case cs is 
		when none => 
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
  			if gwe = '1' or isetl = '1' or fwe = '1' then
				ns <= rst_chan_cnt;
			else	
				ns <= none;
			end if;
		when rst_chan_cnt =>
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
			ns <= rst_shft_cnt;
		when rst_shft_cnt =>
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
			ns <= clkl1;
		when clkl1 =>
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
			ns <= clkh1;
		when clkh1 =>
			lsclk <= '1';
			latch <= '0';
			shiften <= '0';
			ns <= clkh2;
		when clkh2 =>
			lsclk <= '1';
			latch <= '0';
			shiften <= '0';
			ns <= clkl2;
		when clkl2 =>
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
			ns <= shift;
		when shift => 
			lsclk <= '0';
			latch <= '0';
			shiften <= '1';
  			if shiftcnt = 7 then
				ns <= next_chan;
			else	
				ns <= clkl1;
			end if;	
		when next_chan => 
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
  			if chancnt = 9	then 
				ns <= latchh1;
			else	
				ns <= rst_shft_cnt;
			end if;	
		when latchh1 =>
			lsclk <= '0';
			latch <= '1';
			shiften <= '0';
			ns <= latchh2;
		when latchh2 =>
			lsclk <= '0';
			latch <= '1';
			shiften <= '0';
			ns <= none;
		when others =>
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
			ns <= none;							
	   end case; 
   end process fsm; 

end Behavioral;
