library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Control is
    Port ( CLK : in std_logic;
           RESET : in std_logic;
           DATA : in std_logic_vector(31 downto 0);
           CMD : in std_logic_vector(3 downto 0);
           NEWCMD : in std_logic;
           CMDSTS : out std_logic_vector(3 downto 0);
           CMDDONE : out std_logic;
           PGACHAN : out std_logic_vector(3 downto 0);
           PGAGAIN : out std_logic_vector(2 downto 0);
           PGAISEL : out std_logic_vector(1 downto 0);
           PGAFIL : out std_logic_vector(1 downto 0);
           GSET : out std_logic;
           ISET : out std_logic;
           FSET : out std_logic;
           PGARESET : out std_logic;
           EADDR : out std_logic_vector(9 downto 0);
           EEN : out std_logic;
           EDONE : in std_logic;
           ERW : out std_logic;
           EDATA : out std_logic_vector(15 downto 0);
           EESEL : out std_logic;
           BUFSEL : out std_logic;
		 CMDSUCCESS : out std_logic; 
           OSEN : out std_logic;
           OSWE : out std_logic;
           LOAD : out std_logic;
		 PENDING : out std_logic;
           LDONE : in std_logic);
end Control;

architecture Behavioral of Control is
-- CONTROL.VHD -- main system control and incoming command decoder
-- This is essentially a giant FSM. 

   signal edatasel, loading : std_logic := '0';
   signal eaddrsel : integer range 0 to 3 := 0; 
   signal mode : std_logic_vector(1 downto 0) := (others => '0');
    
   -- and all that FSM stuff
   type states is ( modecng, cmdwait, ldmode, reset_pga, load_wait, 
   				modechk, badcmd, set_gain, wait_gain_ee, wos_gain,
				write_os, wait_os_ee, write_buf, wait_buf_ee, 
				write_fl, wait_fl_ee, write_fh, wait_fh_ee, 
				set_input, set_hp, done, load_done);
   signal cs, ns : states := modecng;

begin
   -- input command data decoding
   PGACHAN <= DATA(3 downto 0);
   PGAGAIN <= DATA(10 downto 8);
   PGAISEL <= DATA(9 downto 8) ;
   PGAFIL <= DATA(9 downto 8);

   -- eeprom-related muxes
   EDATA <= (DATA(23 downto 16) & DATA(31 downto 24)) when edatasel = '0'
   		   else "0000000000"  & DATA(13 downto 8); 
   EADDR <= ("100" & DATA(3 downto 0) & DATA(10 downto 8)) when eaddrsel = 0 else
   		  ("010" & DATA(6 downto 0)) when eaddrsel = 1 else
		  ("00" & DATA(6 downto 0) & '0') when eaddrsel = 2 else
		  ("00" & DATA(6 downto 0) & '1') when eaddrsel = 3; 

   OSEN <= '0' when mode = "01" else '1';
   BUFSEL <= '1' when loading = '1' else
   		   '1' when loading = '0' and mode = "10" else
		   '0';
   -- command status bits
   CMDSTS(3) <= '0'; -- reserved for future use
   CMDSTS(2 downto 1) <= mode;
   CMDSTS(0) <= loading; 

   EESEL <= loading; 
	
   clock: process(CLK, RESET) is
   begin
   	if RESET = '1' then
		cs <= modecng;
	else
	  if rising_edge(CLK) then
	  	cs <= ns;

		if cs = ldmode then 
			mode <= DATA(1 downto 0);
		end if;

	  end if; 
	end if; 	
   end process clock;


   fsm: process(cs, NEWCMD, CMD, EDONE, DATA) is
   begin
	case cs is 
		when cmdwait => 
		  pending <= '0';
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  if newcmd = '1' then
			case cmd is
				when "0111" =>
					ns <= modechk;
				when "0001" =>
					ns <= set_gain;
				when "0010" =>
					ns <= set_input;
				when "0011" =>
					ns <= set_hp;
				when "0100" => 
					if mode = "01" then
						ns <= write_os;
					else
						ns <= badcmd;
					end if;
				when "0101" =>
					if mode = "10" then
						ns <= write_fl;
					else
						ns <= badcmd;
					end if;
				when "0110" =>
					if mode = "10" then
						ns <= write_buf;
					else
						ns <= badcmd;
					end if;
				when others =>
					ns <= badcmd;
			end case; 
		  else
		  	ns <=  cmdwait;
		  end if; 
		when set_gain => 
		  pending <= '1'; 
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '1';
		  gset <= '1';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= wait_gain_ee;
		when wait_gain_ee => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  if edone = '1' then
		  	ns <= wos_gain;
		  else
		  	ns <= wait_gain_ee;
		  end if;
		when wos_gain => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '1';	
		  ns <= done; 
		when done => 
		  pending <= '1';  	    
		  loading <= '0';
		  cmddone <= '1';
		  cmdsuccess <= '1';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';	
		  ns <= cmdwait;
		when set_input => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '1';
		  fset <= '0';
		  oswe <= '0';
		  ns <= done;
		when set_hp => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '1';
		  oswe <= '0';
		  ns <= done; 
		when write_os => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';	    
		  ns <= wait_os_ee; 
		when wait_os_ee => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';	    
		  if edone = '1' then 
		  	ns <= done;
		  else
		  	ns <= wait_os_ee;
		  end if; 
		when write_buf => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 1;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';	    
		  ns <= wait_buf_ee; 
		when wait_buf_ee => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 1;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';	    
		  if edone = '1' then 
		  	ns <= done;
		  else
		  	ns <= wait_buf_ee;
		  end if; 
		when write_fl => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 2;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= wait_fl_ee; 
		when wait_fl_ee => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 2;
		  edatasel <= '0'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  if edone = '1' then 
		  	ns <= write_fh;
		  else
		  	ns <= wait_fl_ee;
		  end if; 		   
		when write_fh => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 3;
		  edatasel <= '1'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= wait_fh_ee; 
		when wait_fh_ee => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 3;
		  edatasel <= '1'; 
		  erw <= '0';
		  een <= '1';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  if edone = '1' then 
		  	ns <= done;
		  else
		  	ns <= wait_fh_ee;
		  end if; 		  
		when modechk => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  if DATA(1 downto 0) = "11" then -- invalid mode
		  	ns <= badcmd;
		  else
		  	ns <= modecng;
		  end if; 
		when modecng => 
		  pending <= '1';  
		  loading <= '1';
		  cmddone <= '1';
		  cmdsuccess <= '1';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= ldmode; 
		when ldmode => 
		  pending <= '1';  
		  loading <= '1';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '1';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= reset_pga;
		when reset_pga => 
		  pending <= '1'; 
		  loading <= '1';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '1';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0'; 
		  oswe <= '0';
		  ns <= load_wait;
		when load_wait => 
		  pending <= '1';  
		  loading <= '1';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0'; 
		  oswe <= '0';
		  if ldone = '1' then
		  	ns <= load_done;
		  else 
		  	ns <= load_wait;
		  end if; 
		when load_done => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '1';
		  cmdsuccess <= '1';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0'; 
		  oswe <= '0';
		  ns <= cmdwait;
		when others => 
		  pending <= '1';  
		  loading <= '0';
		  cmddone <= '0';
		  cmdsuccess <= '0';
		  load <= '0';
		  pgareset <= '0';
		  eaddrsel <= 0;
		  edatasel <= '0'; 
		  erw <= '1';
		  een <= '0';
		  gset <= '0';
		  iset <= '0';
		  fset <= '0';
		  oswe <= '0';
		  ns <= cmdwait; 	
	end case;    
   end process fsm; 
    
end Behavioral;
