library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RMACcontrol is
    Port ( CLK : in std_logic;
           INSAMPLE : in std_logic;
           OUTSAMPLE : in std_logic;
           RESET : in std_logic;
           STARTMAC : out std_logic;
           MACDONE : in std_logic;
           SAMPLE : out std_logic_vector(6 downto 0);
           SAMPBASE : out std_logic_vector(6 downto 0);
           RMACCHAN : out std_logic_vector(3 downto 0));
end RMACcontrol;

architecture Behavioral of RMACcontrol is
-- RMACCONTROL.VHD -- RMAC controller
	signal lsample : std_logic_vector(6 downto 0) := (others => '0');
	signal chan : std_logic_vector(3 downto 0) := (others => '0');

	type states is (none, addrrst, macwait, nextchan);
	signal cs, ns : states := none;


begin
	clock: process(CLK, INSAMPLE, OUTSAMPLE, RESET, MACDONE, lsample,
				chan, cs, ns) is
	begin
	   if RESET = '1' then 
	   	cs <= none;
		lsample <= "0000000";
		SAMPBASE <= "1111111";
	   else
	   	 if rising_edge(CLK) then
		 	cs <= ns;
			
			if OUTSAMPLE = '1' then 
				chan <= "0000";
			elsif cs = nextchan then
				chan <= chan + 1;
			end if;
	
			if OUTSAMPLE = '1' then
				SAMPBASE <= lsample;
			end if; 



			if INSAMPLE = '1' then
				lsample <= lsample + 1;
			end if; 

		end if;
	  end if;
	end process clock;

	SAMPLE <= lsample; 
	RMACCHAN <= chan;

	fsm: process(cs, ns, OUTSAMPLE, macdone) is
	begin
		case cs is 
			when none => 
				startmac <= '0';
				if OUTSAMPLE = '1' then
					ns <= addrrst;
				else
					ns <= none;
				end if;
			when addrrst => 
				startmac <= '1';
				ns <= macwait;
			when macwait => 
				startmac <= '0';
				if MACDONE = '1' then
					ns <= nextchan;
				else
					ns <= macwait;
				end if;
			when nextchan => 
				startmac <= '0';
				if chan = "1001" then
					ns <= addrrst;
				else
					ns <= none;
				end if;
			when others =>
				startmac <= '0';
				ns <= none;
		end case; 

	end process fsm; 

end Behavioral;
