library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity INPUT is
    Port ( CLK4X : in std_logic;
           INSAMPCLK : in std_logic;
           SAMPCNT : out std_logic_vector(6 downto 0);
           ADDRB7 : out std_logic;
			  RESET : in std_logic; 
			  CONVST: out std_logic; 
           WEB : out std_logic_vector(4 downto 0);
           BUFBUS : in std_logic_vector(13 downto 0);
           DATAIN : out std_logic_vector(13 downto 0);
           OEB : out std_logic_vector(9 downto 0));
end INPUT;

architecture Behavioral of INPUT is
	type states is (NONE, CONVST_1, CONVST_2, CONVST_3, CONVST_4, CONVWAIT,
						 ZEROCNT, OE_L1, OE_L2, STORE, REPEAT);
	signal cs, ns: states := NONE; 

	signal convstl : std_logic := '1'; 
	signal outcnt : integer range 10 downto 0 := 0;
	signal waitcnt : integer range 250 downto 0 := 0;  
	signal oe : std_logic := '0';
	signal we : std_logic := '0';

begin
	clocks: process(CLK4X, INSAMPCLK, RESET, BUFBUS, cs) is
	begin
		if RESET = '1' then
			cs <= NONE;
		else
			if rising_edge(CLK4X) then
				cs <= ns;

				CONVST <= convstl; 

				if cs = CONVST_4 then
					waitcnt <= 0;
				elsif cs = CONVWAIT then
					waitcnt <= waitcnt +1;
				end if; 

				if cs = ZEROCNT then
					outcnt <= 0;
				elsif cs = REPEAT then
					outcnt <= outcnt + 1;
				end if; 
					
			end if; 
		end if; 

	end process clocks; 

	fsm: process(cs, INSAMPCLK, waitcnt) is
	begin
		case cs is
			when NONE =>
				convstl <= '1'; 
				oe <= '0';
				we <= '0';
				if INSAMPCLK = '1' then
					ns <= CONVST_1;
				else
					ns <= none;
				end if;
			when CONVST_1 =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				ns <= CONVST_2; 
 			when CONVST_2 =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				ns <= CONVST_3; 
			when CONVST_3 =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				ns <= CONVST_4; 
			when CONVST_4 =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				ns <= CONVWAIT; 
			when CONVWAIT =>
				convstl <= '1'; 
				oe <= '0';
				we <= '0';
				if waitcnt < 180 then 
					ns <= CONVWAIT;
				else
					ns <= ZEROCNT;
				end if;
			when ZEROCNT =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				ns <= OE_L1;
			when OE_L1 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= OE_L2;
			when OE_L2 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= STORE;
			when STORE =>
				convstl <= '0'; 
				oe <= '1';
				we <= '1';
				ns <= REPEAT;
			when REPEAT =>
				convstl <= '0'; 
				oe <= '0';
				we <= '0';
				if outcnt < 9 then
					ns <= OE_L1;
				else
					ns <= NONE; 
				end if;
			when others =>
				convstl <= '0';
				oe <= '0';
				we <= '0';
		end case; 
	end process fsm;
end Behavioral;
