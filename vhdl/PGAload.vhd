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
           GAIN : in std_logic_vector(4 downto 0);
           GSET : in std_logic;
           ISET : in std_logic;
           ISEL : in std_logic_vector(3 downto 0));
end PGAload;

architecture Behavioral of PGAload is
-- PGALOAD.VHD -- This maintains gain settings for the PGAs and input
-- selection for the two continuous-data channels. Every change causes
-- it to serialize out to the shift registers. It also has the gain-setting
-- to PGA look-up table. 

   signal isetl, gwe : std_logic := '0';
   signal gainl : std_logic_vector(4 downto 0) := (others => '0');
   signal chanl, isell : std_logic_vector(3 downto 0) := (others => '0');

   signal pgagain1, pgagain2, pgagain3, pgagain4, pgagain5,
   		pgagain6, pgagain7, pgagain8, pgagain9, pgagain10, pgagain,
		gainlookup, gainlookupl
			: std_logic_vector(5 downto 0) := (others => '0');
   signal inputsel, input : std_logic_vector(1 downto 0) := (others => '0');
   signal msbout, shiften, latch, lsclk : std_logic := '0';
   signal shiftreg, shiftregin : 
   		std_logic_vector(7 downto 0) := (others => '0');

   type states is (none, rst_chan_cnt, rst_shft_cnt, clkl1, clkh1, 
   	    clkh2, clkl2, shift, next_chan, latchh1, latchh2); 

   signal cs, ns  : states := none;
   signal chancnt, shiftcnt : integer range 10 downto 0 := 0;
 




begin

   clock: process(CLK, cs, ns, ISEL, ISET, GAIN, GSET, CHAN, input, pgagain,
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
			gainl <= GAIN;
			gwe <= GSET;
			chanl <= CHAN;
			gainlookupl <= gainlookup; 
			-- gain registers for each channel
			case chanl is
				when "0000" => pgagain1 <= gainlookupl; 
				when "0001" => pgagain2 <= gainlookupl; 
				when "0010" => pgagain3 <= gainlookupl; 
				when "0011" => pgagain4 <= gainlookupl; 
				when "0100" => pgagain5 <= gainlookupl; 
				when "0101" => pgagain6 <= gainlookupl; 
				when "0110" => pgagain7 <= gainlookupl; 
				when "0111" => pgagain8 <= gainlookupl; 
				when "1000" => pgagain9 <= gainlookupl; 
				when "1001" => pgagain10 <= gainlookupl; 
				when others => Null;
			end case; 

 
			
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
   shiftregin <= (input(1) & pgagain & input(0));
   -- PGA channel selection
   pgagain <= pgagain1 when chancnt = 0 else
   		    pgagain2 when chancnt = 1 else
   		    pgagain3 when chancnt = 2 else
   		    pgagain4 when chancnt = 3 else
   		    pgagain5 when chancnt = 4 else
   		    pgagain6 when chancnt = 5 else
   		    pgagain7 when chancnt = 6 else
   		    pgagain8 when chancnt = 7 else
   		    pgagain9 when chancnt = 8 else
   		    pgagain10;

   -- input selection for PGA		    
   input <= isell(1 downto 0) when inputsel = "00" else
   		  isell(3 downto 2) when inputsel = "01" else
		  "00" when inputsel = "10" else
		  "00" when inputsel = "11" ; 
   inputsel <= "00" when chancnt = 5 else
   			"01" when chancnt = 6 else
			"10"; 
   
   -- gain settings LUT
   gainlut: process(gainl) is
   begin
   	case gainl is
		when "00000" => gainlookup <= "111111";
		when "00001" => gainlookup <= "111110";
		when "00010" => gainlookup <= "111101";
		when "00011" => gainlookup <= "111100";
		when "00100" => gainlookup <= "111011";
		when "00101" => gainlookup <= "111010";
		when "00110" => gainlookup <= "111001";
		when "00111" => gainlookup <= "111000";
		when "01000" => gainlookup <= "000011";
		when "01001" => gainlookup <= "010001";
		when "01010" => gainlookup <= "000001";
		when "01011" => gainlookup <= "010111";
		when "01100" => gainlookup <= "001001";
		when "01101" => gainlookup <= "010001";
		when "01110" => gainlookup <= "000000";
		when "01111" => gainlookup <= "000101";
		when "10000" => gainlookup <= "000001";
		when "10001" => gainlookup <= "000101";
		when "10010" => gainlookup <= "000111";
		when "10011" => gainlookup <= "010000";
		when "10100" => gainlookup <= "000001";
		when "10101" => gainlookup <= "001001";
		when "10110" => gainlookup <= "001101";
		when "10111" => gainlookup <= "000001";
		when "11000" => gainlookup <= "000001";
		when "11001" => gainlookup <= "111001";
		when "11010" => gainlookup <= "100101";
		when "11011" => gainlookup <= "001100";
		when "11100" => gainlookup <= "011001";
		when "11101" => gainlookup <= "111111";
		when "11110" => gainlookup <= "001001";
		when "11111" => gainlookup <= "011001";
		when others => null;
	end case;   	
   end process gainlut; 


   fsm : process (cs, ns, gwe, isetl, shiftcnt, chancnt) is
   begin
   	case cs is 
		when none => 
			lsclk <= '0';
			latch <= '0';
			shiften <= '0';
  			if gwe = '1' or isetl = '1' then
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
