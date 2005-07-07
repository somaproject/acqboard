library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE ieee.numeric_std.ALL; 
 use std.textio.all;


--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity deserialize is
    generic ( filename : string := "deserialize.output.dat"); 
    Port ( CLK8 : in std_logic;
           FIBEROUT : in std_logic;
			  newframe : out std_logic; 
			  kchar : out std_logic_vector(7 downto 0);
			  cmdst : out std_logic_vector(7 downto 0);
			  data : out std_logic_vector(159 downto 0);
			  cmdid : out std_logic_vector(7 downto 0) 
			  );
end deserialize;

architecture Behavioral of deserialize is
-- deserialize.vhd -- simple deserializer for output data.
-- Samples falling_edge(CLK8), pushes data into 250-bit buffer, looking
-- for starting k character. 
-- 
-- also has output values and "new frame" 


   signal inbuff, inbuffl: std_logic_vector(249 downto 0) := (others => '0');
   signal outbuff : std_logic_vector(25*8-1 downto 0) := (others => '0');

   signal din : std_logic_vector(9 downto 0) := (others => '0');
   signal dout : std_logic_vector(7 downto 0) := (others => '0'); 
   signal code_err, kout, disp_err, translate : std_logic; 
   signal intclk : std_logic := '0';
	 
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
   process (CLK8) is
   begin
      if falling_edge(CLK8) then
	 	inbuff <= FIBEROUT & inbuff(249 downto 1);

          if inbuff(9 downto 0) = "0101111100" or inbuff(9 downto 0) = "1010000011" then
 	   	-- comma character; lock!
 		-- now do 8b/10b decoding of this stream, then write to text file. 

		   translate <= '1';
		   inbuffl <= inbuff; 
		else
			translate <= '0';
		end if; 


	 end if;
   end process; 

    decode : decode8b10b port map (
   			CLK => intclk,
			DIN => din,
			DOUT => dout,
			ce => '1',
			kout => kout,
			code_err => code_err,
			disp_err => disp_err);



   -- translation
   translation: process is
    	  variable bytepos: natural := 0;
	  file outputfile : text open write_mode is filename;
	  variable L : line;

	  
	  
	    
   begin
       if rising_edge(translate) then
			 for i in 0 to 24 loop
				din <= inbuffl(((i+1)*10 - 1) downto i*10);
				wait for 1 ns; 
				intclk <= '1';
				wait for 1 ns;
				intclk <= '0';
				wait for 1 ns;
				outbuff(((i+1)*8 - 1) downto i*8) <= dout; 
			 end loop; 

			 -- output data
			 -- minor formatting, but basically
			 -- kchar cmdsts 10*double-words of bits * 
			 
			  
			 write(L, TO_Bitvector(outbuff(7 downto 0))); 
			 write(L, ' ');
			 write(L, TO_Bitvector(outbuff(15 downto 8)));
			 for i in 0 to 9 loop
				write(L, ' ');
				write(L, to_integer(signed(outbuff((i+2)*16-9 downto (i+1)*16) & 
					   outbuff((i+2)*16-1 downto (i+1)*16+8)))); 
			 end loop; 

			 write(L, ' ');
			 write(L, TO_Bitvector(outbuff(190 downto 182))); 
			 write(L, ' ');
			 write(L, TO_Bitvector(outbuff(199 downto 191))); 

			 writeline(outputfile, L); 

			 -- now, for the output
			 kchar <= outbuff(7 downto 0); 
			 cmdst <= outbuff(15 downto 8); 
			 cmdid <= outbuff(183 downto 176); 
			 data <= outbuff(175 downto 16); 
			 newframe <= '1' after 30 ns, '0' after 80 ns; 

	  end if; 
	  wait on translate;     
   
   end process translation;  


end Behavioral;
