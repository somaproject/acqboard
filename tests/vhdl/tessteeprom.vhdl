library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tessteeprom is
    Port ( CLK : in std_logic;
           ECS : out std_logic;
           ESO : in std_logic;
           ESI : out std_logic;
           ESCK : out std_logic;
           LED0 : out std_logic;
           LED1 : out std_logic;
			  RESET : in std_logic;
			 DELAYTICKOUT : out std_logic);
end tessteeprom;

architecture Behavioral of tessteeprom is

	signal spiclk, ewr, een, edone : std_logic := '0';
	signal edin, edout: std_logic_vector(15 downto 0) := (others => '0'); 

	signal eaddr : std_logic_vector(10 downto 0) := (others => '0'); 

	signal spiclkcnt : integer range 0 to 80 := 0; 
	signal delaycnt: integer range 0 to 32000000 :=31999995; 
	signal delaytick : std_logic := '0';

	type states is (none, write, write_wait, read, read_wait, verify);
	signal cs, ns : states := none; 
	signal readsuccess : std_logic := '0'; 

	signal datacount : std_logic_vector(15 downto 0) := (others => '0'); 


	component EEPROMio is
	    Port ( CLK : in std_logic;
	    		 RESET : in std_logic; 
	           SPICLK : in std_logic;
	           DOUT : out std_logic_vector(15 downto 0);
	           DIN : in std_logic_vector(15 downto 0);
	           ADDR : in std_logic_vector(10 downto 0);
	           WR : in std_logic;
	           EN : in std_logic;
	           DONE : out std_logic;
	           ESI : out std_logic;
	           ESO : in std_logic;
			 ESCK : out std_logic;
			 ECS : out std_logic);
	end component;


begin
--  code will:
--	  every delaycnt:
--   write a value to the eeprom at address foo
--   try and read back that value
--   if they are equal, LED1 lights, otherwise LED0
 
	eeprom: EEPROMio port map(
			CLK => CLK,
			RESET => RESET, 
		  	SPICLK => spiclk,
			DOUT => edout,
			DIN => edin, 
			ADDR => eaddr,
			wr => ewr,
			EN => een,
			DONE => edone,
			ESI => ESI,
			ESO => ESO,
			ESCK => ESCK, 
			ECS => ECS);

	 DELAYTICKOUT <= delaytick; 
	 clock: process(RESET, CLK) is
	 begin
	 	if RESET = '1' then
			spiclkcnt <= 0;
			delaycnt <= 3199995; 
			cs <= none; 
		else
			if rising_edge(CLK) then
				
				cs <= ns; 


				if spiclkcnt = 79 then
					spiclk <= '1';
					spiclkcnt <= 0;
				else
					spiclk <= '0';
					spiclkcnt <= spiclkcnt + 1; 
				end if; 

				if delaycnt = 3200000 then
					delaytick <= '1';
					delaycnt <= 0;
				else
					delaytick <= '0';
					delaycnt <= delaycnt + 1; 
				end if; 

				if cs = verify then 
					if readsuccess = '1' then
						LED1 <= '1';
						LED0 <= '1';
					else
						LED1 <= '0';
						LED0 <= '0';
					end if;
					
					datacount <= datacount + 1;  
				end if; 


			end if; 
		end if;
	end process clock;



	fsm : process(cs, spiclk, delaycnt, delaytick, edone) is
	begin
		case cs is
			when none =>
				eaddr <= "00000000000"; 
				edin <= X"1234";
				ewr <= '1'; 
				een <= '0'; 
				readsuccess <= '0'; 
				if delaytick = '1' then
					ns <= write;
				else
					ns <= none;
				end if; 

			when write =>
				eaddr <= datacount(10 downto 0); 
				edin <= X"72" & datacount(7 downto 0);
				ewr <= '0'; 
				een <= '1';  
				readsuccess <= '0'; 
				ns <= write_wait; 
			when write_wait =>
				eaddr <= datacount(10 downto 0); 
				edin <= X"72" & datacount(7 downto 0);
				ewr <= '0'; 
				een <= '0';  
				readsuccess <= '0'; 
				if edone = '1' then
					ns <= read;
				else
					ns <= write_wait;
				end if; 
			when read =>
				eaddr <= datacount(10 downto 0); 
				edin <= X"1234";
				ewr <= '1'; 
				een <= '1';  
				readsuccess <= '0'; 
				ns <= read_wait; 
			when read_wait =>
				eaddr <= datacount(10 downto 0); 
				edin <= X"1234";
				ewr <= '1'; 
				een <= '0';  
				readsuccess <= '0'; 
				if edone = '1' then
					ns <= verify;
				else
					ns <= read_wait;
				end if; 
 			when verify =>
				eaddr <=datacount(10 downto 0); 
				edin <= X"1234";
				ewr <= '1'; 
				een <= '0';  
				
				if edout =  X"72" & datacount(7 downto 0) then
					readsuccess <= '1'; 
				else
					readsuccess <= '0'; 
				end if; 
				ns <= none; 
			when others =>
				eaddr <= "00000000000"; 
				edin <= X"1234";
				ewr <= '1'; 
				een <= '0';  
				readsuccess <= '0';
				ns <= none; 
		end case; 
	end process fsm;





				

end Behavioral;
