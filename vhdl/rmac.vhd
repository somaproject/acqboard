library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

-- RMAC ---------------------------------------------------
-- Pipelined repeaded mutliply-accumuluator unit : vhdl
-- convolution!!! System uses coregen pipelined multiplier
-- and has ~10-cycle latency, so remember to flush. This
-- is accomplished in acq. board design by zero-padding
-- the end of h[n] and multiplying for an extra 10 samples
-- in the rmac fsm. 



entity RMAC is
    Port ( CLK2X : in std_logic;
           CLR : in std_logic;
           XD : in std_logic_vector(13 downto 0);
           HD : in std_logic_vector(21 downto 0);
           MACRND : out std_logic_vector(15 downto 0));
end RMAC;

architecture Behavioral of RMAC is
	signal mina : std_logic_vector(13 downto 0) := "00000000000000";
	signal minb : std_logic_vector(21 downto 0) := "0000000000000000000000"; 
	signal p, pl : std_logic_vector(35 downto 0) := "000000000000000000000000000000000000"; 
	signal sum, macout: std_logic_vector(37 downto 0) := "00000000000000000000000000000000000000"; 

	component multiplier IS
		port (
		clk: IN std_logic;
		a: IN std_logic_VECTOR(13 downto 0);
		b: IN std_logic_VECTOR(21 downto 0);
		q: OUT std_logic_VECTOR(35 downto 0));
	END component;


begin


  	mult: multiplier port map (
			clk => CLK2X,
			a => mina,
			b => minb,
			q => p); 


	rmac_core: process (CLK2X, XD, HD, mina, minb, p, pl, sum, macout) is
	begin
		if rising_edge(CLK2X) then
			if CLR = '1' then
				-- reset all latches to zero
				mina <= (others => '0');
				minb <= (others => '0');
				pl <= (others => '0');
				macout <= (others => '0');
			else
				-- pipeline pipeline pipeline
				mina <= XD;
				minb <= HD;
				pl <= p; 
				macout <= sum;
			end if; 
		end if; 

		sum <= macout + (pl(35) & pl(35) & pl);


		-- this is the code for rounding, wheee!
		if macout(37 downto 34) = "1111" or macout(37 downto 34) = "0000"	then
			macrnd <= macout(34 downto 19);
		else
			if macout(37) = '1' then
				macrnd <= "1000000000000000";
			else
				macrnd <= "0111111111111111";
			end if;
		end if; 
			
	end process rmac_core; 


end Behavioral;
