library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity raw is
    Port ( CLK : in std_logic;
           DIN : in std_logic_vector(15 downto 0);
           CIN : in std_logic_vector(3 downto 0);
           WEIN : in std_logic;
           CHAN : in std_logic_vector(3 downto 0);
           OUTBYTE : in std_logic;
		     OUTSAMPLE  : IN std_logic; 
		     INSAMPLE : in std_logic; 
           Y : out std_logic_vector(15 downto 0));
end raw;

architecture Behavioral of raw is
-- RAW.VHD : Module allows us to read out the raw acquired 
-- samples of any of the 10 ADC inputs, and uses double-buffering
-- of async RAMs to minimize count. Timing of the Y output should
-- wokr with the TXInput requirements. 

	signal wechan, awe, bwe, bsel : std_logic := '0';
	signal ssel, ai : std_logic_vector(2 downto 0) := (others => '0');
	signal doa, dob : std_logic_vector(15 downto 0) := (others => '0');
	signal oaddr : integer range 0 to 31 := 0;



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

	bufa: distRAM_dualport generic map (
		d_width => 16,
		addr_width => 3,
		mem_depth => 8) 
		port map (
		do => doa,
		we => awe,
		clk=> clk,
		di => DIN,
		ai => ai,
		ao => ssel); 


	bufb: distRAM_dualport generic map (
		d_width => 16,
		addr_width => 3,
		mem_depth => 8) 
		port map (
		do => dob,
		we => bwe,
		clk=> clk,
		di => DIN,
		ai => ai,
		ao => ssel); 

	wechan <= '1' when WEIN = '1' and CIN = CHAN else '0';
	bwe <= (not bsel) and wechan;
	awe <= bsel and wechan; 
	Y <= doa when bsel = '0' else dob; 

	ssel <= "000" when oaddr = 0 or oaddr = 1 or 
						oaddr = 2 or oaddr = 3 else
			  "001" when oaddr = 4 or oaddr = 5 else
			  "010" when oaddr = 6 or oaddr = 7 else
			  "011" when oaddr = 8 or oaddr = 9 else
			  "100" when oaddr = 10 or oaddr = 11 else
			  "101" when oaddr = 12 or oaddr = 13 else
			  "110" when oaddr = 14 or oaddr = 15 else
			  "111";


	main: process(CLK, OUTSAMPLE) is
	begin
		if rising_edge(CLK) then
			if OUTSAMPLE = '1' then
				ai <= (others => '0');
			else
				if wechan = '1' then
					ai <= ai + 1;
				end if; 
			end if; 

			if OUTSAMPLE = '1' then
				oaddr <= 0;
			else 
				if outbyte = '1' then
					oaddr <= oaddr + 1;
				end if;
			end if; 

			if OUTSAMPLE = '1' then 
				bsel <= not bsel; 
			end if; 
		end if; 
	end process main; 
			
end Behavioral;
