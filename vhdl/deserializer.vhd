library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

-- This is just test code to deserialize the data stream. The output is a series
-- of decoded bytes, with K-characters indicated. Code and disparity errors are also
-- indicated. 


-- the input generics are explained on decoder.ai. They are n and m. 
-- 

-- For this system to work, we need CLK to be 60 MHz and the datastream to be
-- running at 8 MHz, for example. At these values, n=3 and m=4.   

entity deserializer is
	 generic (n : integer := 3;  -- size of counter
	 			 m : integer := 5);  -- number of ticks to sample on counter 
    Port ( CLK : in std_logic; -- input clock
           DIN : in std_logic;
           --CLKOTHER : in std_logic;
			  DOUTREG_OUT: out std_logic_vector(9 downto 0); 
			  DATALOCK : out std_logic;
			  KOUT: out std_logic; 
			  DATAOUT: out std_logic_vector(7 downto 0); 
			  DINMIRROR: out std_logic;
			  CODE_ERR: out std_logic; 	

			  DISP_ERR : out std_logic;
			  BITMIRROR : out std_logic 
			  );
end deserializer;

architecture Behavioral of deserializer is
	signal inbit0, inbit1, inbit2, inbit3, curbit, lastbit: std_logic; 
	signal counter: std_logic_vector((n-1) downto 0) := conv_std_logic_vector(0, n); 
	signal datareg, doutreg: std_logic_vector(9 downto 0) := "0000000000";
	signal dout, dout_en, doutrdy, doutrdy1, doutrdy2 : std_logic; 
	signal data : std_logic_vector(7 downto 0);

	component decode8b10b IS
		port (
		clk: IN std_logic;
		din: IN std_logic_VECTOR(9 downto 0);
		dout: OUT std_logic_VECTOR(7 downto 0);
		kout: OUT std_logic;
		ce: IN std_logic;
		code_err: OUT std_logic;
		disp_err: OUT std_logic);
	END component;

begin

	doutreg_out <= doutreg; 
	dataout <= data;
	decoder: decode8b10b port map(
		CLK => CLK, 
		DIN => doutreg, 
		DOUT => data,
		KOUT => kout,
		CE => doutrdy,
		CODE_ERR => code_err,
		DISP_ERR => disp_err);

   DINMIRROR <= curbit; 
	BITMIRROR <= DOUT;


	FINDBITSTREAM : process (CLK, DIN, doutrdy, doutrdy1) is
	begin
		if rising_edge(CLK)  then
			inbit0 <= DIN;
			inbit1 <= inbit0;	 -- multiple levels of latches to get rid of meatastbility problems
			inbit2 <= inbit1;
			inbit3 <= inbit2;
			curbit <= inbit3;
			lastbit <= curbit; 
			if curbit = lastbit then
				if counter = conv_std_logic_vector(n-1, n) then
					counter <= (others => '0');
				else
					counter <= counter + 1;
				end if; 
			else
				counter <= (others => '0');
			end if;
			
			if counter = conv_std_logic_vector(m, n) then 
				dout <= curbit;
			end if; 

			if counter = conv_std_logic_vector(m, n)  then
				dout_en <= '1';
			else
				dout_en <= '0';
			end if; 

			-- simple delay
			if doutrdy = '1' then
				doutrdy1 <= '1';
			else
				doutrdy1 <= '0';
			end if; 
			if doutrdy1 = '1' then
				doutrdy2 <= '1';
			else
				doutrdy2 <= '0';
			end if; 
			if doutrdy2 = '1' then
				DATALOCK <= '1';
			else
				DATALOCK <= '0';
			end if; 

		end if;


	end process FINDBITSTREAM;

	TOPARALLEL: process(CLK, dout_en, dout) is
		variable lockcnt: std_logic_vector(3 downto 0) :="0000";
	begin

		if rising_edge(CLK) then
			if dout_en = '1' then
				 datareg <= dout &  datareg(9 downto 1) ; 	-- SHIFT IN LSB FIRST!
			end if;

			if dout_en = '1' then
				if datareg = "1010000011" or datareg = "0101111100" then  --- wow, 28.7 sucks, use 28.5
					lockcnt := "0000";

				else

					if lockcnt = "1001" then
						lockcnt := "0000";
					else
						lockcnt := lockcnt + 1;
					end if;
				end if;
			end if; 
			
			if dout_en = '1' then
				if lockcnt = "0000" then
					doutreg <= datareg;
				end if;	  			 
			end if; 


			if lockcnt = "0011" and dout_en = '1' then
				DOUTRDY <= '1';
			else
				DOUTRDY <= '0';
			end if; 

							
		end if; 
	
	end process TOPARALLEL;


end Behavioral;
