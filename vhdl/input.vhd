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
			  OUTTEST: out std_logic; 
			  OUTTEST2: out std_logic_vector(3 downto 0); 
           WEB : out std_logic_vector(4 downto 0);
           OEB : out std_logic_vector(9 downto 0));
end INPUT;

architecture Behavioral of INPUT is
	type states is (NONE, CONVST_1, CONVST_2, CONVST_3, CONVST_4, CONVWAIT,
						 ZEROCNT, OE_L1, OE_L2, STORE,  REPEAT);
	signal cs, ns: states := NONE; 

	signal convstl : std_logic := '1'; 
	signal outcnt : std_logic_vector(3 downto 0) := "0000"; 
	signal waitcnt : integer range 1025 downto 0 := 0;  
	signal chcnt : integer range 4 downto 0 := 0; 
	signal sampcntind: std_logic_vector(6 downto 0) := "0000000";
	signal tsel : std_logic := '0'; 
	signal oe : std_logic := '1';
	signal we : std_logic := '0';

begin

	SAMPCNT <= sampcntind; 


	OUTTEST2 <= outcnt; 
	clocks: process(CLK2X, INSAMPCLK, RESET, sampcntind, cs) is
	begin
		if RESET = '1' then
			cs <= NONE;						
			
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
					outcnt <= "0000";
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
					if outcnt = "0101" then
						tsel <= '1';
					end if;
				end if;

				if INSAMPCLK = '1' then
					sampcntind <= sampcntind + 1;
				end if; 
					
			end if; 
		end if; 

	end process clocks;

	memset: process (CLK2X,	outcnt, oe, chcnt, we, tsel, sampcntind) is
	begin
		if rising_edge(CLK2X) then
			OUTTEST <= oe; 
			if outcnt = "0000" then 
				OEB(0) <= oe;
			else
				OEB(0) <= '1';
			end if;
			if outcnt = "0001" then 
				OEB(1) <= oe;
			else
				OEB(1) <= '1';
			end if;
			if outcnt = "0010" then 
				OEB(2) <= oe;
			else
				OEB(2) <= '1';
			end if;
			if outcnt = "0011" then 
				OEB(3) <= oe;
			else
				OEB(3) <= '1';
			end if;
			if outcnt = "0100" then 
				OEB(4) <= oe;
			else
				OEB(4) <= '1';
			end if;
			if outcnt = "0101" then 
				OEB(5) <= oe;
			else
				OEB(5) <= '1';
			end if;
			if outcnt = "0110" then 
				OEB(6) <= oe;
			else
				OEB(6) <= '1';
			end if;
			if outcnt = "0111" then 
				OEB(7) <= oe;
			else
				OEB(7) <= '1';
			end if;
			if outcnt = "1000" then 
				OEB(8) <= oe;
			else
				OEB(8) <= '1';
			end if;
			if outcnt = "1001" then 
				OEB(9) <= oe;
			else
				OEB(9) <= '1';
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
