library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity looptest is
    Port ( CLK : in std_logic;
	 		  KOUT : out std_logic;
			  --encodeddataout: out std_logic_vector(9 downto 0);
			  timerout: out std_logic;
			  RESET: in std_logic; 
           DOUT : out std_logic);
end looptest;

architecture Behavioral of looptest is
-- this just outputs a series of data bytes over an 8b/10b interface at 8MHz. 
-- the data stream itself counting from 0 to 239

signal data, datacnt : std_logic_vector(7 downto 0) := "00000000";
signal kin : std_logic := '0'; 

signal timer: std_logic := '0';
signal shift_timer: std_logic := '0';
	component encoder IS
		port (
		din: IN std_logic_VECTOR(7 downto 0);
		kin: IN std_logic;
		clk: IN std_logic;
		dout: OUT std_logic_VECTOR(9 downto 0);
		ce: IN std_logic);
	END component;				

signal data_timer: std_logic_vector(4 downto 0) := "00000";
signal encodeddata, encodeddata1, encodeddata2, outreg : std_logic_vector(9 downto 0);  

signal testvect: std_logic_vector(99 downto 0) := "0011111000100111010001110101001011010100110001101111000001110110001011100010101101001010111100010100";
                                                   
	
begin

	encode: encoder port map (
		din => data,
		kin => kin,
		clk => clk,
		dout => encodeddata,
		ce => '1');

	
	KOUT <= KIN;
	--encodeddataout <= encodeddata;
	timerout <= timer; 
	timing: process(CLK, timer) is
		variable timecount: integer range 41 downto 0 := 0;
		 
		variable shiftcount : std_logic_vector(1 downto 0) := "00";
	begin
		if RESET = '1' then
			testvect <= "0011111000100111010001110101001011010100110001101111000001110110001011100010101101001010111100010100";
		else
		if rising_edge(CLK) then
			if timecount = 39 then
				timecount := 0;
				timer <= '1'; 
			else
				timecount := timecount + 1;
				timer <= '0'; 
			end if;

			shiftcount := shiftcount + 1; 

			if timer = '1' then
				if data_timer = "11000" then
					data_timer <= "00000";
				else
					data_timer <= data_timer + 1;
				end if;
			end if; 

			
				if timer = '1' then
					outreg <= encodeddata;
				else
					if shiftcount = "01" then
						outreg(8 downto 0) <= outreg(9 downto 1);
					end if;
				end if;
	
		if shiftcount = "00" then
			testvect(99 downto 1) <= testvect(98 downto 0);
			testvect(0) <= testvect(99); 
		end if; 	

			dout <= testvect(0);		
		end if; 
	
		 end if; 

	end process timing; 			
	output: process(CLK, data_timer, datacnt) is 
	begin
		if rising_edge(CLK) then
			if datacnt= "11101111" then
				datacnt <= "00000000";
			else
				if timer = '1' and  not (data_timer = "00000")  then
					datacnt <= datacnt + 1;
				end if;
			end if;

			if data_timer = "00000" then
				data <= "11111100";
				kin <= '1';
			else
				data <= datacnt;
				kin <= '0';

			end if; 
		end if; 
	end process output; 


end Behavioral;
