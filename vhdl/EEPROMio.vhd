library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity EEPROMio is
    Port ( CLK : in std_logic;
    		 RESET : in std_logic; 
           SPICLK : in std_logic;
           DOUT : out std_logic_vector(15 downto 0);
           DIN : in std_logic_vector(15 downto 0);
           ADDR : in std_logic_vector(10 downto 0);
           WR : in std_logic;
           EN : in std_logic;
           DONE : out std_logic;
           ESI : out std_logic;
           ESO : in std_logic;
		 ESCK : out std_logic;
		 ECS : out std_logic);
end EEPROMio;

architecture Behavioral of EEPROMio is
-- EEPROMIO.VHD -- Interface to SPI serial EEPROM, pretty simple stuff. 

   signal muxin: std_logic_vector(47 downto 0) := (others => '0');
   signal siout, sen, soin, lcs, lsck : std_logic := '0';
   signal cnt : natural range 0 to 47 := 0;
   signal waitcnt: natural range 0 to 512 := 0;
   signal doutreg : std_logic_vector(15 downto 0) := (others => '0');
   signal len, ldone, lldone : std_logic := '0'; 
   type states is (none, cslow1, clkh1, clkl1, inccnt1, cshigh1, 
   			   cslow2, clkh2, clkl2, inccnt2, waitinc, dones); 
   signal cs, ns : states := none;

begin

   -- input mux
   siout <=  muxin(cnt);
   muxin(7 downto 0) <= "01100000";
   muxin(14 downto 8) <= "1000000";
   muxin(15) <= WR;
   muxin(19 downto 16) <= "0000";
   muxin(30 downto 20) <= ADDR(0) & ADDR(1) & ADDR(2) & ADDR(3) & 
   					 ADDR(4) & ADDR(5) & ADDR(6) & ADDR(7) & 
					 ADDR(8) & ADDR(9) & ADDR(10);
   muxin(31) <= '0';
   muxin(47 downto 32) <= din(15 downto 0);
   
   dout <= doutreg; 
   
   clock: process(CLK, RESET, ESO, soin) is
   begin
   	if RESET = '1' then
		cs <= none;
	else
	    	if rising_edge(CLK) then

		     ECS <= lcs;
			ESCK <= lsck;
			ESI <= siout;
			soin <= ESO;

			-- so that a single clock-wide EN wil still
			-- trigger even if the SPICLK and CLK are not aligned:
			if EN = '1' then 
				len <= '1';
			elsif cs = dones then
				len <= '0';
			end if;
			
			lldone <= ldone; 
			if ldone = '0' and lldone = '1' then
				DONE <= '1';
			else
				DONE <= '0';
			end if; 

			if SPICLK = '1' then
			   cs <= ns; 

			   if cs = none then
			   	  cnt <= 0;
			   elsif cs = inccnt1 or cs = inccnt2 then
			   	if cnt = 47 then 
					cnt <= 0;
				else
			   	     cnt <= cnt + 1;
				end if; 
			   end if;

			   if cs = none then
			   	  waitcnt <= 0;
			   elsif cs = waitinc then

			   	     waitcnt <= waitcnt + 1;
			   end if;

			   if sen = '1' and cnt > 31 then 
			   	doutreg <= soin & doutreg(15 downto 1);  
			   end if; 

	
			end if; 
		end if; 

	end if;    
  end process clock;	

  fsm : process(len, cnt, cs,  waitcnt, wr) is
  begin
  	case cs is
		when none =>
			lcs <= '1';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			if len = '1' then
				ns <= cslow1;
			else
				ns <= none;
			end if; 
		when cslow1 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= clkl1; 
		when clkl1 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= clkh1; 
		when clkh1 =>
			lcs <= '0';
			lsck <= '1';
			sen <= '0';
			ldone <= '0';
			ns <= inccnt1;
		when inccnt1 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			if cnt = 7 then
				ns <= cshigh1;
			else
				ns <= clkl1;
			end if;
		when cshigh1 =>
			lcs <= '1';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= cslow2;
		when cslow2 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= clkl2;
		when clkl2 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= clkh2; 
		when clkh2 =>
			lcs <= '0';
			lsck <= '1';
			sen <= '1';
			ldone <= '0';
			ns <= inccnt2;
		when inccnt2 =>
			lcs <= '0';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			if cnt = 47 then
				ns <= waitinc;
			else
				ns <= clkl2;
			end if;
		when waitinc =>
			lcs <= '1';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			if waitcnt = 511 or wr = '1' then
				ns <= dones;
			else
				ns <= waitinc;
			end if;
		when dones =>
			lcs <= '1';
			lsck <= '0';
			sen <= '0';
			ldone <= '1';
			ns <= none;
		when others =>
			lcs <= '1';
			lsck <= '0';
			sen <= '0';
			ldone <= '0';
			ns <= none;
	end case; 
			  
  end process fsm; 			    

end Behavioral;
