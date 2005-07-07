 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity input is
    Port ( CLK : in std_logic;				   
           INSAMPLE : in std_logic;
		 RESET : in std_logic; 
           CONVST : out std_logic;
           ADCCS : out std_logic;
           SCLK : out std_logic;
           SDIN : in std_logic_vector(4 downto 0);
           DOUT : out std_logic_vector(15 downto 0);
           COUT : out std_logic_vector(3 downto 0);
           WEOUT : out std_logic;
		 OSC : in std_logic_vector(3 downto 0);
		 OSRST : in std_logic; 
		 OSEN : in std_logic;
		 OSWE : in std_logic; 
		 OSD : in std_logic_vector(15 downto 0)
		 );

end input;

architecture Behavioral of input is
-- INPUT.VHD : input from serial converter, also performs offset math. 


	-- input and output registers
	signal ladccs, lsclk : std_logic := '0';
	signal sdinl : std_logic_vector(4 downto 0) := (others => '0');
	
	 
	signal sampleA1, sampleA2, sampleA3, sampleA4, sampleA0,
		sampleB1, sampleB2, sampleB3, sampleB4, sampleB0 :
		std_logic_vector(15 downto 0) := (others => '0'); 

	signal smux: std_logic_vector(15 downto 0) := (others => '0');
	signal s, os, osdo : std_logic_vector(15 downto 0) := (others => '0');

	signal sum: std_logic_vector(16 downto 0) := (others => '0');
	signal biten : std_logic := '0';

	-- counters
	signal chancnt : std_logic_vector(3 downto 0) := (others => '0');
	signal concnt : integer range 0 to 127 := 0;
	signal bitcnt : integer range 0 to 31 := 0; 
	signal concnten, bitcnten, oen : std_logic := '0'; 

	signal bitendelay : std_logic_vector(9 downto 0) := (others => '0');


	-- extra latches
	signal chancntl, chancntll : std_logic_vector(3 downto 0)
		:= (others => '0');
	signal oenl, oenll : std_logic := '0';

     type states is (none, newout, waitconv, startrd, sclkh, sclkl0,
				sclkl1, sclkl2); 
	signal cs, ns : states := none; 


			
	component distRAM_dualport is 
  	generic( 
        d_width : integer := 16; 
        addr_width : integer := 3; 
        mem_depth : integer := 8 
        ); 
 	 port ( 
        do : out STD_LOGIC_VECTOR(d_width - 1 downto 0); 
        we, clk : in STD_LOGIC; 
        di : in STD_LOGIC_VECTOR(d_width - 1 downto 0); 
        ao, ai : in STD_LOGIC_VECTOR(addr_width - 1 downto 0)); 
	end component; 


begin


	OSram : distRAM_dualport generic map
		( d_width => 16,
		  addr_width => 4,
		  mem_depth => 16)
		port map (	
		do => osdo,
		di => OSD, 
		we => OSWE,
		clk => CLK,
		ao => chancnt,
		ai => OSC); 


	smux <= sampleA0 when chancnt = "0000" else
		sampleB0 when chancnt = "0001" else
		sampleA1 when chancnt = "0010" else
		sampleB1 when chancnt = "0011" else
		sampleA2 when chancnt = "0100" else
		sampleB2 when chancnt = "0101" else
		sampleA3 when chancnt = "0110" else
		sampleB3 when chancnt = "0111" else
		sampleA4 when chancnt = "1000" else
		sampleB4;

	biten <= bitendelay(4); 
	
	main: process(CLK, RESET) is
	begin
		if RESET = '1' then
			cs <= none;
		else	   	
			if rising_edge(CLK) then
				cs <= ns;
				
				ADCCS <= ladccs;
				SCLK <= lsclk;
				CONVST <= not INSAMPLE; 
				sdinl <= SDIN; 
				
				-- input
				if biten = '1' then
					sampleB0 <= 
						sampleB0(14 downto 0) & sampleA0(15); 
					sampleA0 <= 
						sampleA0(14 downto 0) & sdinl(0); 

					sampleB1 <= 
						sampleB1(14 downto 0) & sampleA1(15); 
					sampleA1 <= 
						sampleA1(14 downto 0) & sdinl(1); 

					sampleB2 <= 
						sampleB2(14 downto 0) & sampleA2(15); 
					sampleA2 <= 
						sampleA2 (14 downto 0) & sdinl(2);
						 
					sampleB3 <= 
						sampleB3(14 downto 0) & sampleA3(15); 
					sampleA3 <= 
						sampleA3(14 downto 0) & sdinl(3);
						 
					sampleB4 <= 
						sampleB4(14 downto 0) & sampleA4(15); 
					sampleA4 <= 
						sampleA4(14 downto 0) & sdinl(4); 

				end if; 


				-- counters
				if INSAMPLE = '1' then
					concnt <= 0;
				else
					if concnten = '1' then
						concnt <= concnt + 1; 
					end if;
				end if; 

				if INSAMPLE = '1' then
					bitcnt <= 0;
				else
					if bitcnten = '1' then
						if bitcnt = 31 then
							bitcnt <= 0; 
						else

							bitcnt <= bitcnt + 1; 
						end if; 
					end if;
				end if; 

				if INSAMPLE = '1' then
					chancnt <= "0000";
				else
					if oen = '1' then
						chancnt <= chancnt + 1; 
					end if;
				end if; 

				s <= smux; 
				if OSEN = '1' then
					os <= osdo;
				else
					os <= X"0000";
				end if; 

				sum <= SXT(s - X"8000", 17) + SXT(os, 17); 

				-- overflow code
				if sum(16 downto 15) = "00" then
					DOUT <= sum(15 downto 0);
				elsif sum(16 downto 15) = "11" then
					DOUT <= sum(15 downto 0); 
				elsif sum(16 downto 15) = "01" then
					DOUT <= X"7FFF"; 
				else	
					DOUT <= X"8000";
				end if; 

				-- latency
				chancntl <= chancnt; 
				chancntll <= chancntl; 
				COUT <= chancntll;

				oenl <= oen;
				oenll <= oenl;
				WEOUT <= oenll; 

				-- bit enable delay
				bitendelay <= bitendelay(8 downto 0) & lsclk;
					
			end if; 	
		end if; 	   
	end process main; 
 	
	
	
	fsm: process(cs, INSAMPLE, concnt, bitcnt) is
	begin
		case cs is
			when none =>
				ladccs <= '1';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				if INSAMPLE = '1' then
					ns <= newout;
				else
					ns <= none;
				end if; 
			when newout =>
				ladccs <= '1';
				lsclk <= '0';
				concnten <= '1';
				bitcnten <= '0';
				oen <= '1';
				if concnt = 9 then
					ns <= waitconv;
				else
					ns <= newout;
				end if; 
			when waitconv =>
				ladccs <= '1';
				lsclk <= '0';
				concnten <= '1';
				bitcnten <= '0';
				oen <= '0';
				if concnt = 90 then
					ns <= startrd;
				else
					ns <= waitconv;
				end if; 
			when startrd =>
				ladccs <= '0';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				ns <= sclkh; 
			when sclkh =>
				ladccs <= '0';
				lsclk <= '1';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				ns <= sclkl0; 
			when sclkl0 =>
				ladccs <= '0';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				ns <= sclkl2; 
			when sclkl1 =>
				ladccs <= '0';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				ns <= sclkl2; 
			when sclkl2 =>
				ladccs <= '0';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '1';
				oen <= '0';
				if bitcnt = 31 then
					ns <= none;
				else
					ns <= sclkh; 
				end if; 
			when others =>
				ladccs <= '0';
				lsclk <= '0';
				concnten <= '0';
				bitcnten <= '0';
				oen <= '0';
				ns <= none; 

		end case; 
	end process fsm; 																																								
end Behavioral;
																														    						