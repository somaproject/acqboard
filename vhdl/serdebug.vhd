library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serdebug is
    Port ( CLK : in std_logic;
    		 RESET : in std_logic; 
           DIN : in std_logic_vector(15 downto 0);
           DINEN : in std_logic;
           SOUTCS : out std_logic;
           SOUTCLK : out std_logic;
           SOUTDATA : out std_logic);
end serdebug;

architecture Behavioral of serdebug is
-- VERY SIMPLE MODULE TO OUTPUT SERIAL DEBUGGING DATA
	signal dinl : std_logic_vector(15 downto 0) := (others => '0');

	signal bitcnt : integer range 0 to 15 := 0; 

	type states is (none, csstart, low0, high0, high1, low1, csend); 
	signal cs, ns : states := none; 

	signal lsoutcs, lsoutclk : std_logic := '0'; 
begin
	

	
	main : process(CLK, RESET) is
	begin
		if RESET = '1' then
			cs <= none;
		else
			if rising_edge(CLK) then
				cs <= ns; 

				if dinen = '1' then
					dinl <= DIN;
				end if; 


				if cs = low1 then
					dinl <= dinl(14 downto 0) & '0'; 	
					if bitcnt = 15 then
						bitcnt <= 0;
					else
						bitcnt <= bitcnt + 1; 
					end if; 
				end if; 

			    	SOUTDATA <= dinl(15); 
				SOUTCS <= lsoutcs;
				SOUTCLK <= lsoutclk; 

			end if; 
		end if; 


	end process main; 

	fsm : process(cs, bitcnt, dinen) is
	begin
		case cs is 
			when none =>
				lsoutcs <= '0';
				lsoutclk <= '0';
				if dinen = '1' then
					ns <= csstart;
				else
					ns <= none; 
				end if; 
			when csstart =>
				lsoutcs <= '1';
				lsoutclk <= '0';
				ns <= low0;
			when low0 =>
				lsoutcs <= '1';
				lsoutclk <= '0';
				ns <= high0 ;
			when high0 =>
				lsoutcs <= '1';
				lsoutclk <= '1';
				ns <= high1;
			when high1 =>
				lsoutcs <= '1';
				lsoutclk <= '1';
				ns <= low1;
			when low1 =>
				lsoutcs <= '1';
				lsoutclk <= '0';
				if bitcnt = 15 then
					ns <= csend;
				else
					ns <= low0; 
				end if;
			when csend =>
				lsoutcs <= '0';
				lsoutclk <= '0';
				ns <= none;
			when others =>
				lsoutcs <= '0';
				lsoutclk <= '0';
				ns <= none;
		end case; 
	end process fsm; 
end Behavioral;
