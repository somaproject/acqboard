library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity INPUT is
    Port ( CLK2X : in std_logic;
           INSAMPCLK : in std_logic;
           SAMPCNT : out std_logic_vector(6 downto 0);
           ADDRB7 : out std_logic;
			  RESET : in std_logic; 
			  CONVST: out std_logic; 
           WEB : out std_logic_vector(4 downto 0);
           OEB : out std_logic_vector(9 downto 0));
end INPUT;

architecture Behavioral of INPUT is
	type states is (NONE, CONVST_1, CONVST_2, CONVST_3, CONVST_4, CONVWAIT,
						 ZEROCNT, OE_L1, OE_L2, STORE, REPEAT);
	signal cs, ns: states := NONE; 

	signal convstl : std_logic := '1'; 
	signal outcnt : integer range 10 downto 0 := 0;
	signal waitcnt : integer range 1025 downto 0 := 0;  
	signal chcnt : integer range 4 downto 0 := 0; 
	signal sampcntind: std_logic_vector(6 downto 0) := "0000000";
	signal tsel : std_logic := '0'; 
	signal oe : std_logic := '1';
	signal we : std_logic := '0';

begin

	SAMPCNT <= sampcntind; 

	clocks: process(CLK2X, INSAMPCLK, RESET,  cs) is
	begin
		if RESET = '1' then
			cs <= NONE;						
			sampcntind <= "0000000"; 
		else
			if rising_edge(CLK2X) then
				cs <= ns;

				CONVST <= convstl; 

				if cs = CONVST_4 then
					waitcnt <= 0;
				else
					waitcnt <= waitcnt +1;
				end if; 

				if cs = ZEROCNT then
					outcnt <= 0;
				elsif cs = REPEAT then
					outcnt <= outcnt + 1;
				end if; 

				if cs = ZEROCNT then 
					chcnt <= 0;
				elsif cs = REPEAT then
					if chcnt = 4 then
						chcnt <= 0;
					else
						chcnt <= chcnt + 1;
					end if;
				end if; 

				if cs = ZEROCNT then 
					tsel <= '0';
				else
					if outcnt = 5 then
						tsel <= '1';
					end if;
				end if;

				if INSAMPCLK = '1' then
					sampcntind <= sampcntind + 1;
				end if; 
					
			end if; 
		end if; 

	end process clocks;

	memset: process (CLK2X,	outcnt, oe, chcnt, we, tsel) is
	begin
		if rising_edge(CLK2X) then
			if outcnt < 10 then
				case outcnt is
					when 9 =>
						OEB <= oe & "111111111";
					when 8 =>
						OEB <= "1" & oe & "11111111";
					when 7 =>
						OEB <= "11" & oe & "1111111";
					when 6 =>
						OEB <= "111" & oe & "111111";
					when 5 =>
						OEB <= "1111" & oe & "11111";
					when 4 =>
						OEB <= "11111" & oe & "1111";
					when 3 =>
						OEB <= "111111" & oe & "111";
					when 2 =>
						OEB <= "1111111" & oe & "11";
					when 1 =>
						OEB <= "11111111" & oe & "1";
					when 0 =>
						OEB <= "111111111" & oe;
					when others =>
						OEB <= "1111111111";
				end case	;
					 
			end if; 
		end if;

		ADDRB7 <= tsel ; 

		if chcnt = 0 then 
			WEB(0) <= WE;
		else
			WEB(0) <= '0';
		end if; 
		if chcnt = 1 then 
			WEB(1) <= WE;
		else
			WEB(1) <= '0';
		end if; 
		if chcnt = 2 then 
			WEB(2) <= WE;
		else
			WEB(2) <= '0';
		end if; 
		if chcnt = 3 then 
			WEB(3) <= WE;
		else
			WEB(3) <= '0';
		end if; 
		if chcnt = 4 then 
			WEB(4) <= WE;
		else
			WEB(4) <= '0';
		end if; 


	end process memset;

	fsm: process(cs, INSAMPCLK, waitcnt, outcnt) is
	begin
		case cs is
			when NONE =>
				convstl <= '1'; 
				oe <= '1';
				we <= '0';
				if INSAMPCLK = '1' then
					ns <= CONVST_1;
				else
					ns <= none;
				end if;
			when CONVST_1 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= CONVST_2; 
 			when CONVST_2 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= CONVST_3; 
			when CONVST_3 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= CONVST_4; 
			when CONVST_4 =>
				convstl <= '0'; 
				oe <= '1';
				we <= '0';
				ns <= CONVWAIT; 
			when CONVWAIT =>
				convstl <= '1'; 
				oe <= '1';
				we <= '0';
				if waitcnt = 180 then 
					ns <= ZEROCNT;
				else
					ns <= CONVWAIT;
				end if;
			when ZEROCNT =>
				convstl <= '1'; 
				oe <= '1';
				we <= '0';
				ns <= OE_L1;
			when OE_L1 =>
				convstl <= '1'; 
				oe <= '0';
				we <= '0';
				ns <= OE_L2;
			when OE_L2 =>
				convstl <= '1'; 
				oe <= '0';
				we <= '0';
				ns <= STORE;
			when STORE =>
				convstl <= '1'; 
				oe <= '0';
				we <= '1';
				ns <= REPEAT;
			when REPEAT =>
				convstl <= '1'; 
				oe <= '1';
				we <= '0';
				if outcnt < 9 then
					ns <= OE_L1;
				else
					ns <= NONE; 
				end if;
			when others =>
				convstl <= '1';
				oe <= '1';
				we <= '0';
		end case; 
	end process fsm;
end Behavioral;
