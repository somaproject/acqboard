
-- VHDL Test Bench Created from source file fibertx.vhd -- 14:14:43 01/26/2005
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all; 
use  ieee.numeric_std.all; 
use std.TextIO.ALL; 


ENTITY fibertxtest IS
END fibertxtest;

ARCHITECTURE behavior OF fibertxtest IS 

	COMPONENT fibertx
	PORT(
		CLK : IN std_logic;
		CLK8 : IN std_logic;
		RESET : IN std_logic;
		OUTSAMPLE : IN std_logic;
		CMDDONE : IN std_logic;
		Y : IN std_logic_vector(15 downto 0);
		YEN : IN std_logic;
		CMDSTS : IN std_logic_vector(3 downto 0);
		CMDID : IN std_logic_vector(3 downto 0);
		CMDSUCCESS : IN std_logic;
		OUTBYTE : IN std_logic;
		CHKSUM : IN std_logic_vector(7 downto 0);          
		FIBEROUT : OUT std_logic
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic := '0';
	SIGNAL CLK8 :  std_logic := '0';
	SIGNAL RESET :  std_logic := '1';
	SIGNAL OUTSAMPLE :  std_logic := '0';
	SIGNAL FIBEROUT :  std_logic := '0';
	SIGNAL CMDDONE :  std_logic := '0';
	SIGNAL Y :  std_logic_vector(15 downto 0) := (others => '0');
	SIGNAL YEN :  std_logic := '0';
	SIGNAL CMDSTS :  std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL CMDID :  std_logic_vector(3 downto 0) := (others => '0');
	SIGNAL CMDSUCCESS :  std_logic := '0';
	SIGNAL OUTBYTE :  std_logic := '0';
	SIGNAL CHKSUM :  std_logic_vector(7 downto 0) := (others => '0');



	component deserialize is
	    generic ( filename : string := "deserialize.output.dat"); 
	    Port ( CLK8 : in std_logic;
	           FIBEROUT : in std_logic;
				  newframe : out std_logic; 
				  kchar : out std_logic_vector(7 downto 0);
				  cmdst : out std_logic_vector(7 downto 0);
				  data : out std_logic_vector(159 downto 0);
				  cmdid : out std_logic_vector(7 downto 0) 
				  );
	end component;

	signal newframe : std_logic := '0';
	signal kcharout: std_logic_vector(7 downto 0)
		:= (others => '0');
     signal cmdstsout, cmdidout : std_logic_vector(7 downto 0)
		:= (others => '0');  
	signal data : std_logic_vector(159 downto 0) 
		:= (others => '0'); 


BEGIN

	uut: fibertx PORT MAP(
		CLK => CLK,
		CLK8 => CLK8,
		RESET => RESET,
		OUTSAMPLE => OUTSAMPLE,
		FIBEROUT => FIBEROUT,
		CMDDONE => CMDDONE,
		Y => Y,
		YEN => YEN,
		CMDSTS => CMDSTS,
		CMDID => CMDID,
		CMDSUCCESS => CMDSUCCESS,
		OUTBYTE => OUTBYTE,
		CHKSUM => CHKSUM
	);

	deser: deserialize port map
		(CLK8 => clk8,
		FIBEROUT => FIBEROUT,
		newframe => newframe,
		kchar => kcharout, 
		cmdst => cmdstsout,
		cmdid => cmdidout,
		data => data);

	CLK <= not CLK after 7.8125 ns; 
	RESET <= '0' after 30 ns; 

	process(CLK) is
		variable ycnt : integer := -7; 


	begin
		if rising_edge(CLK) then
			ycnt := ycnt + 1; 
			
			if ycnt mod 8 = 0 then
				clk8 <= '1';
			else
				clk8 <= '0';
			end if; 

			if ycnt mod 2000 = 0 then
				OUTSAMPLE <= '1';
			else
				OUTSAMPLE <= '0';
			end if; 

			if ycnt mod 80 = 0 then
				OUTBYTE <= '1';
			else
				OUTBYTE <= '0';
			end if; 
			

		end if; 
	end process; 


	-- process
	writer: process is
		variable yval : integer := 0; 
		variable cmdstsval : integer := 0; 
		variable cmdidval : integer := 0; 
		variable chksumval : integer := 0; 

	begin
		for i in 0 to 99 loop
			wait until rising_edge(CLK) and OUTSAMPLE = '1'; 
			-- write new suite of data; 
			YEN <= '0';
			wait until rising_edge(CLK); 

			for j in 1 to 10 loop 

				Y <= std_logic_vector(to_unsigned(yval, 16)); 
				YEN <= '1';
				yval := yval + 1;  
				wait until rising_edge(CLK);
			end loop;
			YEN <= '0'; 
			wait until rising_edge(CLK); 
			 
 
	
			CMDSTS <= std_logic_vector(to_unsigned(cmdstsval, 4));
			CMDID <= std_logic_vector(to_unsigned(cmdidval, 4)); 
			CHKSUM <= std_logic_vector(to_unsigned(chksumval, 8)); 
			wait until rising_edge(CLK); 
			CMDDONE <= '1'; 
			wait until rising_edge(CLK);
			CMDDONE <= '0';
			wait until rising_edge(CLK); 

									
			-- at the end, increment:
			cmdstsval := (cmdstsval + 1) mod 16; 
			cmdidval := (cmdidval + 1) mod 16; 
			chksumval := (chksumval + 1) mod 256; 

						 
		end loop; 
	end process writer; 

	verify: process is
		variable yval : integer := 0; 
		variable cmdstsval : integer := 0; 
		variable cmdidval : integer := 0; 
		variable chksumval : integer := 0; 
		variable yvalvect : std_logic_vector(15 downto 0)
			:= (others => '0');
		variable cmdidvect : std_logic_vector(6 downto 0)
			:= (others => '0'); 
		variable cmdstsvect : std_logic_vector(7 downto 0)
			:= (others => '0'); 
				 
	begin
		-- to verify we wait until we get cmdsts
		wait until falling_edge(NEWFRAME);

		for i in 0 to 99 loop
			wait until falling_edge(NEWFRAME); 
			for j in 0 to 9 loop 
				yvalvect := std_logic_vector(to_unsigned(yval, 16)); 
				assert (data(j*16 +7  downto j*16) & 
					   data(j*16 + 15 downto j*16 + 8) )
					 = yvalvect
					report "Error decoding Data"
					severity error; 

				yval := yval + 1;  
			end loop;
			 
 
			cmdstsvect := std_logic_vector(to_unsigned(cmdstsval, 8));
			cmdidvect := std_logic_vector(to_unsigned(cmdidval, 7));

			assert cmdstsout = cmdstsvect
				report "Error decoding CMDSTS"
				severity error; 

			assert CMDIDout(7 downto 1) = cmdidvect 				
				report "Error decoding CMDID"
				severity error; 

			cmdstsval := (cmdstsval + 1) mod 16; 
			cmdidval := (cmdidval + 1) mod 16; 
		end loop; 

		assert false
			report "End of simulation"
			severity failure; 



	end process; 

END;
