library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity rmacfsm is
    Port ( CLK2X : in std_logic;
           RESET : in std_logic;
           OUTSAMPCLK : in std_logic;
           OUTBYTE : in std_logic;
           CLR : out std_logic;
           DOTS : out std_logic_vector(4 downto 0);
			  MACMSB : out std_logic; 
           ADDRA7 : out std_logic);
end rmacfsm;

architecture Behavioral of rmacfsm is
	 type STATES is (NONE, RAM_ZERO, CLR_HIGH, RMAC_LOOP, NEXT_RAM, WAIT_OUTB);
	 signal cs, ns : states := none;

	 signal rmac_cnt : integer range 200 downto 0 :=0;
	 signal chancnt : integer range  10 downto 0 := 0; 
begin

	clocks: process(CLK2X, cs, ns, RESET) is
	begin
		if RESET = '1' then
			cs <= NONE;
		else
			if rising_edge(CLK2X) then
				cs <= ns; 
				if cs = RAM_ZERO then
					chancnt <= 0;
				elsif cs = NEXT_RAM then
					chancnt <= chancnt + 1;
				end if;
				
				if cs = CLR_HIGH then 
					rmac_cnt <= 0;
				elsif cs = RMAC_LOOP then
					rmac_cnt <= rmac_cnt + 1; 
				end if; 
		
			end if;
		end if; 
	end process clocks;

	DOTS <= "00001" when chancnt = 0 or chancnt = 5 else
			  "00010" when chancnt = 1 or chancnt = 6 else
			  "00100" when chancnt = 2 or chancnt = 7 else
			  "01000" when chancnt = 3 or chancnt = 8 else
			  "10000" when chancnt = 4 or chancnt = 9 or chancnt = 10 else
			  	"00000";
	ADDRA7 <= '0' when chancnt = 0 or chancnt = 1 or
			chancnt = 2 or chancnt = 3 or chancnt = 4 else '1'; 

	fsm : process(cs, OUTSAMPCLK, OUTBYTE, rmac_cnt, chancnt) is
	begin
		case cs is 
			when NONE =>
				CLR <= '0';
				if OUTSAMPCLK = '1' then
					ns <= RAM_ZERO;
				else
					ns <= NONE;
				end if;
 			when RAM_ZERO =>
				CLR <= '0';
				ns <= CLR_HIGH;
 			when CLR_HIGH =>
				CLR <= '1';
				ns <= RMAC_LOOP;
 			when RMAC_LOOP =>
				CLR <= '0';
				if RMAC_CNT = 135 then
					ns <= NEXT_RAM;
				else
					ns <= RMAC_LOOP;
				end if;
 			when NEXT_RAM =>
				CLR <= '0';
				ns <= WAIT_OUTB;
 			when WAIT_OUTB =>
				CLR <= '0';
				if OUTSAMPCLK = '1' then 
					ns <= RAM_ZERO;
				else
					if chancnt = 10 then
						ns <= WAIT_OUTB;
					else
						if OUTBYTE = '1' then
							ns <= CLR_HIGH;
						elsif OUTBYTE = '0' then
							ns <= WAIT_OUTB;
						end if;
					end if; 
				end if;
			when others =>
				CLR <= '0';
				ns <= none;
		end case; 
	end process fsm;  
end Behavioral;
