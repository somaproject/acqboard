library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity simple is
    Port ( CLKIN : in std_logic;
           SDIN : in std_logic;
           SCLK : out std_logic;
           ADCCS : out std_logic;
           CONVST : out std_logic;
           FIBEROUT : out std_logic);
end simple;

architecture Behavioral of simple is

	-- internal signals for the simple interface
	signal lconvst, lcs, dinl, lsclk : std_logic := '0';
	signal cnt : std_logic_vector(10 downto 0) := (others => '0');
	signal bitcnt : integer range 32 downto 0 := 0; 

	type states is (none, ser0, ser1, ser2, ser3, serwait, 
		shiftin, checkdone);
	signal cs, ns : states := none; 


	signal reset : std_logic := '0';
	signal clk : std_logic := '0';
	signal outsample, outbyte, clk8, insample : std_logic := '0'; 
	signal dreg: std_logic_vector(31 downto 0) := (others => '0');
	signal y : std_logic_vector(15 downto 0); 

	component FiberTX is
	    Port ( CLK : in std_logic;
	           CLK8 : in std_logic;
			 RESET : in std_logic; 
	           OUTSAMPLE : in std_logic;
	           FIBEROUT : out std_logic;
	           CMDDONE : in std_logic;
			 Y : in std_logic_vector(15 downto 0); 
	           CMDSTS : in std_logic_vector(3 downto 0);
	           CMDID : in std_logic_vector(3 downto 0);
			 CMDSUCCESS : in std_logic; 
			 OUTBYTE : in std_logic; 
	           CHKSUM : in std_logic_vector(7 downto 0));
	end component;

	component clocks is
	    Port ( CLKIN : in std_logic;
	           CLK : out std_logic;
	           CLK8 : out std_logic;
			 RESET : in std_logic;  
	           INSAMPLE : out std_logic;
	           OUTSAMPLE : out std_logic;
	           OUTBYTE : out std_logic := '0';
	           SPICLK : out std_logic);
	end component;


   component STARTUP_VIRTEX 
   port (GSR: in std_logic);
   end component;

	
        component TOC 
        port (O : out std_logic); 
   end component; 

begin				    
	 
	U1: TOC port map (O=>reset);
	
	
	clocks_uut : clocks port map (
		CLKIN => CLKIN,
		CLK => clk,
		CLK8 => clk8,
		RESET => reset,
		INSAMPLE => insample,
		OUTSAMPLE => outsample,
		OUTBYTE => outbyte,
		SPICLK => open); 

	fibertx_uut: fibertx port map (
		CLK => clk,
		CLK8 => clk8,
		RESET => reset,
		OUTSAMPLE => outsample,
		FIBEROUT => FIBEROUT,
		CMDDONE => '0',
		Y => y,
		CMDSTS => "0000",
		CMDID => "0000",
		CMDSUCCESS => '1',
		OUTBYTE => outbyte, 
		CHKSUM => X"AB"); 


	clock: process(clk, reset) is
	begin
		if reset = '1' then
			cs <= none;
		else
			if rising_edge(clk) then
				cs <= ns; 

				CONVST <= lconvst; 
				dinl <= SDIN;
				SCLK <= lsclk;
				ADCCS <= lcs; 

				if outsample = '1' then
					cnt <= (others => '0'); 
				else
					cnt <= cnt + 1; 
				end if; 


				if cs = none then
					bitcnt <= 0;
				else
					if cs = shiftin then
						bitcnt <= bitcnt + 1; 
					end if;
				end if; 

				if cs = shiftin then
					dreg <= dreg(30 downto 0) & dinl; 
				end if; 

				if outsample = '1' then 
					y <= dreg(31 downto 16);
				end if; 

				if cnt = "00000000001" or 
				   cnt = "00000000010" or	
				   cnt = "00000000011" then
				   	lconvst <= '0';
				else
					lconvst <= '1';
				end if; 

				
			end if; 
		end if; 
	end process clock; 

	fsm: process(cs, bitcnt, cnt) is
	begin
		case cs is
			when none =>
				if cnt = "00100000000" then
					ns <= ser0;
				else
					ns <= none; 
				end if; 
				lsclk <= '0';
				lcs <= '1';
			when ser0 =>
				ns <= ser1; 
				lsclk <= '0';
				lcs <= '0';
			when ser1 =>
				ns <= ser2; 
				lsclk <= '1';
				lcs <= '0';
			when ser2 =>
				ns <= serwait; 
				lsclk <= '1';
				lcs <= '0';
			when serwait =>
				lsclk <= '0';
				lcs <= '0';
				if cnt(4 downto 0) = "00000" then
					ns <= shiftin;
				else
					ns <= serwait;
				end if; 
			when shiftin =>
				lsclk <= '0';
				lcs <= '0';
				ns <= checkdone; 
			when checkdone =>
				lsclk <= '0';
				lcs <= '0';

				if bitcnt = 32 then
					ns <= none;
				else
					ns <= ser0; 
				end if; 
			when others => 
				lsclk <= '0';
				lcs <= '1';
				ns <= none; 
		end case; 
	end process; 

end Behavioral;
