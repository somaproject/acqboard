library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input is
    Port ( CLK : in std_logic;				   
           INSAMPLE : in std_logic;
		 RESET : in std_logic; 
           CONVST : out std_logic;
           ADCCS : out std_logic;
           SCLK : out std_logic;
           SIN : in std_logic_vector(4 downto 0);
           DATA : out std_logic_vector(15 downto 0);
           CHAN : out std_logic_vector(3 downto 0);
           WE : out std_logic);

end input;

architecture Behavioral of input is
-- INPUT.VHD : input from serial converter. 

	type states is (none, conv_start, conv_wait, conv_done, sclkh, sclkl1, sclkl2, 
				 sclk_nop1, sclk_nop2, chan_rst, chan_inc);
	signal cs, ns : states := none; 

	signal shiften : std_logic := '0';
	signal pout1, pout2, pout3, pout4, pout5 : 
			std_logic_vector(31 downto 0) := (others => '0');
	signal chanin : std_logic_vector(3 downto 0)  := (others => '0');
	signal wein, weinl, weinll, weinlll: std_logic := '0';
	signal muxout : std_logic_vector(15 downto 0) := (others => '0');
	signal lconvst, ladccs, lsclk : std_logic := '0'; 
	-- counters for FSMs
	signal convwait : integer range 255 downto 0 := 0;
	signal sclkcnt : integer range 63 downto 0 := 0; 


begin
	WE <= wein;
	CHAN <= chanin; 

	clock: process (CLK, RESET, SIN, shiften, INSAMPLE, cs, ns, 
				 muxout,lsclk, ladccs, convwait, pout1, pout2,
				 pout3, pout4, pout5) is
	begin
		if RESET = '1' then
			cs <= none;
		else
			if rising_edge(CLK) then
			   cs <= ns; 

			   if shiften = '1' then 
			   	pout1 <= (pout1(30 downto 0) & SIN(0));
			   	pout2 <= (pout2(30 downto 0) & SIN(1));
			   	pout3 <= (pout3(30 downto 0) & SIN(2));
			   	pout4 <= (pout4(30 downto 0) & SIN(3));
			   	pout5 <= (pout5(30 downto 0) & SIN(4));
			   end if; 


			   -- counters
			   if cs = conv_start then
			   	convwait <= 0;
			   elsif cs = conv_wait then 
			     convwait <= convwait + 1;
  			   end if; 

			   if cs = sclkl2 then 
			     sclkcnt <= sclkcnt + 1; 
			   elsif cs = conv_done then 
			   	sclkcnt <= 0;
			   end if; 
			   
			   if cs = chan_rst then
			   	chanin <= "0000";
			   else
			   	chanin <= chanin + 1;
			   end if; 

			   -- output latches
			   SCLK <= lsclk;
			   ADCCS <= ladccs;
			   CONVST <= lconvst; 


			end if; 
		end if; 
	end process clock; 

    fsm: process(CS, INSAMPLE, convwait, sclkcnt, chanin) is
    begin
    	   case cs is
	   	when none =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '0';
			if INSAMPLE = '1' then
				ns <= conv_start;
			else
				ns <= none;
			end if;
	   	when conv_start =>
			lconvst <= '0';
			lsclk <= '0';
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '0';
			ns <= conv_wait;
	   	when conv_wait =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '0';
			if convwait = 139 then
				ns <= conv_done;
			else
				ns <= conv_wait;
			end if;
	   	when conv_done =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '0';
			shiften <= '0'; 
			wein <= '0';
			ns <= sclkh;
	   	when sclkh =>
			lconvst <= '1';
			lsclk <= '1';
			ladccs <= '0';
			shiften <= '1'; 
			wein <= '0';
			ns <= sclkl1;
	   	when sclkl1 =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '0';
			shiften <= '1'; 
			wein <= '0';
			ns <= sclkl2;
	   	when sclkl2 =>
			lconvst <= '1';
			lsclk <= '0'; 
			ladccs <= '0';
			shiften <= '1'; 
			wein <= '0';
			if sclkcnt = 33 then
				ns <= sclk_nop1;
			else
				ns <= sclkh;
			end if;
		when sclk_nop1 =>
			lconvst <= '1';
			lsclk <= '0'; 
			ladccs <= '0';
			shiften <= '1'; 
			wein <= '0';
			ns <= sclk_nop2;			
		when sclk_nop2 =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '0';
			shiften <= '0'; 
			wein <= '0';
			ns <= chan_rst;			
		when chan_rst =>
			lconvst <= '1';
			lsclk <= '0';
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '0';
			ns <= chan_inc;
	   	when chan_inc =>
			lconvst <= '1';
			lsclk <= '0'; 
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '1';
			if chanin = "1001" then
				ns <= none;
			else
				ns <= chan_inc;
			end if;
		when others =>
			lconvst <= '1';
			lsclk <= '0'; 
			ladccs <= '1';
			shiften <= '0'; 
			wein <= '0';
			ns <= none;	
	end case; 




    end process fsm; 


	-- shift reg output mux
	muxout <= pout1(15 downto 0)  when chanin = "0000" else
		     pout1(31 downto 16) when chanin = "0001" else
			pout2(15 downto 0)  when chanin = "0010" else
			pout2(31 downto 16) when chanin = "0011" else
			pout3(15 downto 0)  when chanin = "0100" else
			pout3(31 downto 16) when chanin = "0101" else
			pout4(15 downto 0)  when chanin = "0110" else
			pout4(31 downto 16)  when chanin = "0111" else 
			pout5(15 downto 0)  when chanin = "1000" else
			pout5(31 downto 16) when chanin = "1001" else
			"0000000000000000";

    DATA <= muxout; 
																																											
end Behavioral;
																														    						