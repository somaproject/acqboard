library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity clocks is
    Port ( CLKIN : in std_logic;
           CLK : out std_logic;
           CLK8 : out std_logic;
		 RESET : in std_logic;  
           INSAMPLE : out std_logic;
           OUTSAMPLE : out std_logic;
           OUTBYTE : out std_logic;
           I2CCLK : out std_logic);
end clocks;

architecture Behavioral of clocks is
-- CLOCKS.VHD -- implementation of clocks and various clock-enables for
-- our system. Uses Xilinx Spartan-IIE DLL to give us a 2x clock, and
-- then additionally uses SRL16Es to generate the clock enables to save
-- space. 

   signal clkin_w, clk2x : std_logic := '0';
   signal clk_g, locked : std_logic := '0'; 
 
   signal div8a, div8c : std_logic := '0';
   signal div10a_o, div10a_l, div10a : std_logic := '0';
   signal div5a_o, div5a_l, div5a : std_logic := '0';
   signal div5b_o, div5b_l, div5b : std_logic := '0';
   signal div8b_o, div8b_l, div8b : std_logic := '0';
   signal div5c_o, div5c_l, div5c : std_logic := '0';
   signal div5d_o, div5d_l, div5d : std_logic := '0';
   signal div10b_o, div10b_l, div10b : std_logic := '0';
   signal div10al, div10all : std_logic := '0';
   signal outenable : std_logic := '0';
   signal loutsample, loutbyte, lclk8, linsample : std_logic := '0';

-- components
	component dll_standard is
	    port (CLKIN : in  std_logic;
	          RESET : in  std_logic;
	          CLK2X : out std_logic;
	          CLK4X : out std_logic;
	          LOCKED: out std_logic);
	end component;

	component SRL16E
	  generic (
	       INIT : bit_vector := X"0000");
	  port (D   : in STD_logic;
	        CE  : in STD_logic;
	        CLK : in STD_logic;
	        A0  : in STD_logic;
	        A1  : in STD_logic;
	        A2  : in STD_logic;
	        A3  : in STD_logic;
	        Q   : out STD_logic); 
	end component;
begin

    clkpad : IBUFG  port map (I=>CLKIN, O=>clkin_w);

    dll2x  : CLKDLL port map (CLKIN=>clkin_w,   CLKFB=>clk_g, RST=>RESET,
                          CLK0=>open,   CLK90=>open, CLK180=>open, CLK270=>open,
                          CLK2X=>clk2x, CLKDV=>open, LOCKED=>LOCKED);
    clk2xg : BUFG   port map (I=>clk2x,   O=>clk_g);

    CLK <= clk_g;

    -- SLR16s to divide the clocks

    div8a_srl: SRL16E
    	      generic map (INIT => X"0040")
		 port map (
		 	D => div8a,
			CE => '1',
			CLK => clk_g,
			A0 => '1',
			A1 => '1',
			A2 => '1',
			A3 => '0',
			Q => div8a);

    div8c_srl: SRL16E
    	      generic map (INIT => X"0008")
		 port map (
		 	D => div8c,
			CE => '1',
			CLK => clk_g,
			A0 => '1',
			A1 => '1',
			A2 => '1',
			A3 => '0',
			Q => div8c);

    div10a_srl: SRL16E
    	      generic map (INIT => X"0001")
		 port map (
		 	D => div10a_o,
			CE => div8a,
			CLK => clk_g,
			A0 => '1',
			A1 => '0',
			A2 => '0',
			A3 => '1',
			Q => div10a_o);

    div5a_srl: SRL16E
    	      generic map (INIT => X"0001")
		 port map (
		 	D => div5a_o,
			CE => div10a,
			CLK => clk_g,
			A0 => '0',
			A1 => '0',
			A2 => '1',
			A3 => '0',
			Q => div5a_o);

    div5b_srl: SRL16E
    	      generic map (INIT => X"0001")
		 port map (
		 	D => div5b_o,
			CE => div5a,
			CLK => clk_g,
			A0 => '0',
			A1 => '0',
			A2 => '1',
			A3 => '0',
			Q => div5b_o);

    div8b_srl: SRL16E
    	      generic map (INIT => X"0001")
		 port map (
		 	D => div8b_o,
			CE => div10a,
			CLK => clk_g,
			A0 => '1',
			A1 => '1',
			A2 => '1',
			A3 => '0',
			Q => div8b_o);
 
    div5c_srl: SRL16E
    	      generic map (INIT => X"0008")
		 port map (
		 	D => div5c, 
			CE => '1',
			CLK => clk_g,
			A0 => '0',
			A1 => '0',
			A2 => '1',
			A3 => '0',
			Q => div5c);

    div5d_srl: SRL16E
    	      generic map (INIT => X"0004")
		 port map (
		 	D => div5d_o,
			CE => div5c,
			CLK => clk_g,
			A0 => '0',
			A1 => '0',
			A2 => '1',
			A3 => '0',
			Q => div5d_o);

    div10b_srl: SRL16E
    	      generic map (INIT => X"0100")
		 port map (
		 	D => div10b_o,
			CE => div5d,
			CLK => clk_g,
			A0 => '1',
			A1 => '0',
			A2 => '0',
			A3 => '1',
			Q => div10b_o);


	div10a <= '1' when div10a_l = '0' and div10a_o = '1' else '0';
	div10b <= '1' when div10b_l = '0' and div10b_o = '1' else '0';
	div5a <= '1' when div5a_l = '0' and div5a_o = '1' else '0';
	div5b <= '1' when div5b_l = '0' and div5b_o = '1' else '0';
	div5d <= '1' when div5d_l = '0' and div5d_o = '1' else '0';
 	div8b <= '1' when div8b_l = '0' and div8b_o = '1' else '0';



 	process(clk_g) is
	begin
		if rising_edge(clk_g) then
		   div10a_l <= div10a_o; 
		   div10b_l <= div10b_o; 
		   div5a_l <= div5a_o; 
		   div5b_l <= div5b_o;  
		   div5d_l <= div5d_o; 
		   div8b_l <= div8b_o;
		   div10al <= div10a;
 		   div10all <= div10al;
		   if div5b = '1' and locked = '1' then
		   	outenable <= '1';
		   end if; 
		   
		   	linsample <= div10b;
		   	loutbyte <= div10all;
             	loutsample <= div5b; 
         	   	lclk8 <= div8c;  
		    
		   if outenable = '1' then 
		   	INSAMPLE <= linsample;
		   	OUTBYTE <= loutbyte;
             	OUTSAMPLE <= loutsample; 
         	   	CLK8 <= lclk8;  
		   end if;
		end if;
	end process; 

      I2CCLK <= div8b;  
    


end Behavioral;
