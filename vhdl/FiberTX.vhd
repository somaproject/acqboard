library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity FiberTX is
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
end FiberTX;

architecture Behavioral of FiberTX is
-- FIBERTX.VHD -- System which forms packets and serializes the 8b/10b
-- encoded result. Needs careful synchronization with RMAC output Y

   signal cmdstsinl, cmdstsl :
   		std_logic_vector(3 downto 0) := (others => '0');
   signal cmdinl, cmdl : std_logic_vector(7 downto 0):= (others => '0');
   signal chksuminl, chksuml :
   		std_logic_vector(7 downto 0):= (others => '0');
		
   signal din, dinl : std_logic_vector(7 downto 0):= (others => '0');
   
   signal ldout, dout, shiftreg : 
   		std_logic_vector(9 downto 0):= (others => '0');
   
   signal kin, sout : std_logic := '0';
   
   signal insel : std_logic_vector(2 downto 0) := (others => '0');

   -- fsm signals
   type states is (kcomma, status, chan0h, chan0l, chan1h, chan1l,
   			    chan2h, chan2l, chan3h, chan3l, chan4h, chan4l, 
			    chan5h, chan5l, chan6h, chan6l, chan7h, chan7l,
			    chan8h, chan8l, chan9h, chan9l, cmdidsnd, checksum,
			    nop); 
   signal cs, ns : states := kcomma;
   
   --8b/10b encoder
	component encode8b10b IS
		port (
		din: IN std_logic_VECTOR(7 downto 0);
		kin: IN std_logic;
		clk: IN std_logic;
		dout: OUT std_logic_VECTOR(9 downto 0);
		ce: IN std_logic);
	END component;      	
begin
   encode: encode8b10b port map (
   		din => dinl,
		dout => ldout,
		clk => CLK,
		kin => kin,
		ce => '1'); 

   sout <= shiftreg(0); 


   clock: process(CLK, CMDSTS, CMDID, CHKSUM, din, RESET, ldout, OUTBYTE, CLK8, 
   			   OUTSAMPLE, CMDDONE, y, cmdstsinl, cmdinl, cs, ns,
			   chksuminl, insel, sout, CMDSUCCESS) is 
   begin
	  if RESET = '1' then
	  	cs <= kcomma;
	  else
	     if rising_edge(CLK) then
		    if CMDDONE = '1' then
		    		cmdstsinl <= CMDSTS;
				cmdinl <= "000" & CMDID & CMDSUCCESS;
				chksuminl <= CHKSUM;
		    end if; 
		    
		    if OUTSAMPLE = '1' then
		    		cmdstsl <= cmdstsinl;
				cmdl <= cmdinl;
				chksuml <= chksuminl;
			end if;
			
		    -- special FSM code 
		    if OUTSAMPLE = '1' then
		    		cs <= kcomma;
		    else
		    	   if OUTBYTE = '1' then
			   	 cs <= ns; 
			   end if; 
		    end if; 


		    if OUTBYTE = '1' then
		    	   if insel = "000" then
			   	kin <= '1';
 			   else
			   	kin <= '0';
			   end if;
			end if; 

		   if OUTBYTE = '1' then
		   	  dinl <= din;
		   end if; 
	
		   dout <= ldout;

		   -- loadable shift register

		   if OUTBYTE = '1' then
		   	  shiftreg <= dout;
		   else
		   	  if clk8 = '1' then
			  	shiftreg <= '0' & shiftreg(9 downto 1);
			  end if;
		   end if;

		   if CLK8 = '1' then
		   	FIBEROUT <= sout; 
		   end if; 	




		end if;
	  end if; 


   end process clock; 

   -- din mux;
   din <= "11111100" when insel = "000" else
   		("0000" & cmdstsl) when insel = "001" else
		y(15 downto 8) when insel = "010" else
		y(7 downto 0) when insel = "011" else
		cmdl when insel = "100" else
		chksuml(7 downto 0) when insel = "101" else
		"00000000" when insel = "110" else
		"11111100"; 


   fsm: process(CS) is
   begin
   	case cs is
		when kcomma => 
			insel <= "000";
			ns <= status;
		when status => 
			insel <= "001";
			ns <= chan0h;
		when chan0h => 
			insel <= "010";
			ns <= chan0l;
		when chan0l => 
			insel <= "011";
			ns <= chan1h;
		when chan1h => 
			insel <= "010";
			ns <= chan1l;
		when chan1l => 
			insel <= "011";
			ns <= chan2h;		
		when chan2h => 
			insel <= "010";
			ns <= chan2l;
		when chan2l => 
			insel <= "011";
			ns <= chan3h;
		when chan3h => 
			insel <= "010";
			ns <= chan3l;
		when chan3l => 
			insel <= "011";
			ns <= chan4h;
		when chan4h => 
			insel <= "010";
			ns <= chan4l;
		when chan4l => 
			insel <= "011";
			ns <= chan5h;
		when chan5h => 
			insel <= "010";
			ns <= chan5l;
		when chan5l => 
			insel <= "011";
			ns <= chan6h;
		when chan6h => 
			insel <= "010";
			ns <= chan6l;
		when chan6l => 
			insel <= "011";
			ns <= chan7h;
		when chan7h => 
			insel <= "010";
			ns <= chan7l;
		when chan7l => 
			insel <= "011";
			ns <= chan8h;
		when chan8h => 
			insel <= "010";
			ns <= chan8l;
		when chan8l => 
			insel <= "011";
			ns <= chan9h;
		when chan9h => 
			insel <= "010";
			ns <= chan9l;
		when chan9l => 
			insel <= "011";
			ns <= cmdidsnd;
		when cmdidsnd => 
			insel <= "100";
			ns <= checksum;
		when checksum => 
			insel <= "101";
			ns <= nop;
		when nop => 
			insel <= "110";
			ns <= kcomma;
		when others => 
			insel <= "111";
			ns <= kcomma;
	end case; 
   end process fsm; 

end Behavioral;
