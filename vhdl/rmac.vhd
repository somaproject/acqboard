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
           HD : in std_logic_vector(17 downto 0);
           MACRND : out std_logic_vector(15 downto 0));
end RMAC;

architecture Behavioral of RMAC is
	signal mina : std_logic_vector(13 downto 0);
	signal minb : std_logic_vector(17 downto 0); 
	signal p, pl : std_logic_vector(31 downto 0); 
	signal sum, macout: std_logic_vector(33 downto 0); 

	component multiplier IS
		port (
		clk: IN std_logic;
		a: IN std_logic_VECTOR(13 downto 0);
		b: IN std_logic_VECTOR(17 downto 0);
		q: OUT std_logic_VECTOR(31 downto 0);
		sclr: IN std_logic);
	END component;


begin


  	mult: multiplier port map (
			clk => CLK2X,
			a => mina,
			b => minb,
			q => p,
			sclr => CLR); 


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

		sum <= macout + (pl(31) & pl(31) & pl);

		macrnd <= macout(30 downto 15);

	end process rmac_core; 


end Behavioral;
