library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bitencode is
    Port ( CLK : in std_logic;
    		 RESET : in std_logic; 
           EN : in std_logic;
           BITEN : in std_logic;
		 DIN : in std_logic; 
           PRED : in std_logic_vector(1 downto 0);
           DOUT : out std_logic);
end bitencode;

architecture Behavioral of bitencode is
	type states is (none, zeroone0, zeroone1, onezero0, onezero1,
			oneone0, oneone1, zerozero0, zerozero1,
			preXzero0, preXzero1, preXzero2, preXzero3,
			preXzero4, preXzero5, preXzero6, preXzero7,
			preXone0, preXone1, preXone2, preXone3, 
			preXone4, preXone5, preXone6, preXone7, 
			preYzero0, preYzero1, preYzero2, preYzero3,
			preYzero4, preYzero5, preYzero6, preYzero7,
			preYone0, preYone1, preYone2, preYone3, 
			preYone4, preYone5, preYone6, preYone7, 
			preZzero0, preZzero1, preZzero2, preZzero3,
			preZzero4, preZzero5, preZzero6, preZzero7,
			preZone0, preZone1, preZone2, preZone3, 
			preZone4, preZone5, preZone6, preZone7);
	signal cs, ns : states := none; 
	signal ldout : std_logic := '0';


begin
	main: process(RESET, CLK) is
	begin
		if RESET = '1' then	
			cs <= zerozero0;
		else
			if rising_edge(CLK) then
			   if EN = '1' then
			   	cs <= ns;
			   end if; 

			   DOUT <= ldout; 
			end if; 
		end if;
	end process main; 


	fsm: process(cs, pred, en, biten) is
	begin
		case cs is	
			when zerozero0 => 
				ldout <= '0';
				ns <= zerozero1;
			when zerozero1 =>
				ldout <= '0';
				if PRED = "00" then
					if DIN = '0' then
						ns <= oneone0;
					else
						ns <= onezero0;
					end if; 
				elsif PRED = "01" then
					ns <= preXone0;
				elsif PRED = "10" then
					ns <= preYone0;
				else
					ns <= preZone0;
				end if; 
			when oneone0 => 
				ldout <= '1';
				ns <= oneone1;
			when oneone1 =>
				ldout <= '1';
				if PRED = "00" then
					if DIN = '0' then
						ns <= zerozero0;
					else
						ns <= zeroone0;
					end if; 
				elsif PRED = "01" then
					ns <= preXzero0;
				elsif PRED = "10" then
					ns <= preYzero0;
				else
					ns <= preZzero0;
				end if; 
			when zeroone0 => 
				ldout <= '0';
				ns <= zeroone1;
			when zeroone1 =>
				ldout <= '1';
				if PRED = "00" then
					if DIN = '0' then
						ns <= zerozero0;
					else
						ns <= zeroone0;
					end if; 
				elsif PRED = "01" then
					ns <= preXzero0;
				elsif PRED = "10" then
					ns <= preYzero0;
				else
					ns <= preZzero0;
				end if; 
			when onezero0 => 
				ldout <= '1';
				ns <= onezero1;
			when onezero1 =>
				ldout <= '0';
				if PRED = "00" then
					if DIN = '0' then
						ns <= oneone0;
					else
						ns <= onezero0;
					end if; 
				elsif PRED = "01" then
					ns <= preXone0;
				elsif PRED = "10" then
					ns <= preYone0;
				else
					ns <= preZone0;
				end if; 
			when preXzero0 => 
				ldout <= '0';
				ns <= preXzero1; 
			when preXzero1 => 
				ldout <= '0';
				ns <= preXzero2; 
			when preXzero2 => 
				ldout <= '0';
				ns <= preXzero3; 
			when preXzero3 => 
				ldout <= '1';
				ns <= preXzero4; 
			when preXzero4 => 
				ldout <= '1';
				ns <= preXzero5; 
			when preXzero5 => 
				ldout <= '1';
				ns <= preXzero6; 
			when preXzero6 => 
				ldout <= '0';
				ns <= preXzero7; 
			when preXzero7 => 
				ldout <= '1';
				if PRED = "00" then
					if DIN = '0' then
						ns <= zerozero0;
					else
						ns <= zeroone0;
					end if; 
				elsif PRED = "01" then
					ns <= preXzero0;
				elsif PRED = "10" then
					ns <= preYzero0;
				else
					ns <= preZzero0;
				end if; 
			when preYzero0 => 
				ldout <= '0';
				ns <= preYzero1; 
			when preYzero1 => 
				ldout <= '0';
				ns <= preYzero2; 
			when preYzero2 => 
				ldout <= '0';
				ns <= preYzero3; 
			when preYzero3 => 
				ldout <= '1';
				ns <= preYzero4; 
			when preYzero4 => 
				ldout <= '1';
				ns <= preYzero5; 
			when preYzero5 => 
				ldout <= '0';
				ns <= preYzero6; 
			when preYzero6 => 
				ldout <= '1';
				ns <= preYzero7; 
			when preYzero7 => 
				ldout <= '1';
				if PRED = "00" then
					if DIN = '0' then
						ns <= zerozero0;
					else
						ns <= zeroone0;
					end if; 
				elsif PRED = "01" then
					ns <= preXzero0;
				elsif PRED = "10" then
					ns <= preYzero0;
				else
					ns <= preZzero0;
				end if; 
			when preZzero0 => 
				ldout <= '0';
				ns <= preZzero1; 
			when preZzero1 => 
				ldout <= '0';
				ns <= preZzero2; 
			when preZzero2 => 
				ldout <= '0';
				ns <= preZzero3; 
			when preZzero3 => 
				ldout <= '1';
				ns <= preZzero4; 
			when preZzero4 => 
				ldout <= '0';
				ns <= preZzero5; 
			when preZzero5 => 
				ldout <= '1';
				ns <= preZzero6; 
			when preZzero6 => 
				ldout <= '1';
				ns <= preZzero7; 
			when preZzero7 => 
				ldout <= '1';
				if PRED = "00" then
					if DIN = '0' then
						ns <= zerozero0;
					else
						ns <= zeroone0;
					end if; 
				elsif PRED = "01" then
					ns <= preXzero0;
				elsif PRED = "10" then
					ns <= preYzero0;
				else
					ns <= preZzero0;
				end if; 
			when preXone0 => 
				ldout <= '1';
				ns <= preXone1; 
			when preXone1 => 
				ldout <= '1';
				ns <= preXone2; 
			when preXone2 => 
				ldout <= '1';
				ns <= preXone3; 
			when preXone3 => 
				ldout <= '0';
				ns <= preXone4; 
			when preXone4 => 
				ldout <= '0';
				ns <= preXone5; 
			when preXone5 => 
				ldout <= '0';
				ns <= preXone6; 
			when preXone6 => 
				ldout <= '1';
				ns <= preXone7; 
			when preXone7 => 
				ldout <= '0';
				if PRED = "00" then
					if DIN = '0' then
						ns <= oneone0;
					else
						ns <= onezero0;
					end if; 
				elsif PRED = "01" then
					ns <= preXone0;
				elsif PRED = "10" then
					ns <= preYone0;
				else
					ns <= preZone0;
				end if; 
			when preYone0 => 
				ldout <= '1';
				ns <= preYone1; 
			when preYone1 => 
				ldout <= '1';
				ns <= preYone2; 
			when preYone2 => 
				ldout <= '1';
				ns <= preYone3; 
			when preYone3 => 
				ldout <= '0';
				ns <= preYone4; 
			when preYone4 => 
				ldout <= '0';
				ns <= preYone5; 
			when preYone5 => 
				ldout <= '1';
				ns <= preYone6; 
			when preYone6 => 
				ldout <= '0';
				ns <= preYone7; 
			when preYone7 => 
				ldout <= '0';
				if PRED = "00" then
					if DIN = '0' then
						ns <= oneone0;
					else
						ns <= onezero0;
					end if; 
				elsif PRED = "01" then
					ns <= preXone0;
				elsif PRED = "10" then
					ns <= preYone0;
				else
					ns <= preZone0;
				end if; 
			when preZone0 => 
				ldout <= '1';
				ns <= preZone1; 
			when preZone1 => 
				ldout <= '1';
				ns <= preZone2; 
			when preZone2 => 
				ldout <= '1';
				ns <= preZone3; 
			when preZone3 => 
				ldout <= '0';
				ns <= preZone4; 
			when preZone4 => 
				ldout <= '1';
				ns <= preZone5; 
			when preZone5 => 
				ldout <= '0';
				ns <= preZone6; 
			when preZone6 => 
				ldout <= '0';
				ns <= preZone7; 
			when preZone7 => 
				ldout <= '0';
				if PRED = "00" then
					if DIN = '0' then
						ns <= oneone0;
					else
						ns <= onezero0;
					end if; 
				elsif PRED = "01" then
					ns <= preXone0;
				elsif PRED = "10" then
					ns <= preYone0;
				else
					ns <= preZone0;
				end if; 
			when others=>
				ldout <= '0';
				ns <= zerozero0; 
		end case; 
	end process fsm; 

end Behavioral;
