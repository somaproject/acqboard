library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
    Port ( CLK : in std_logic;
	 		  RESET: in std_logic; 
           DATA : in std_logic_vector(7 downto 0);
           KOUT : in std_logic;
           DATALOCK : in std_logic;
           RCK : out std_logic;
           SRCK : out std_logic;
           SOUT : out std_logic);
end control;

-- CONTROL.VHD ------------------------------------------------------------
--   This is the two FSMs and associated counters and latches used to 
-- shift out the control signals to the PGAs. 

architecture Behavioral of control is
	type input_states is (none, count_rst, byte_wait, byte_shift, dec, latch_h, latch_l);
	type shift_states is (none, latch, count_rst, clk_h, clk_l, shift, dec, done); 
	signal input_cs, input_ns : input_states := none; 
	signal shift_cs, shift_ns : shift_states := none; 
	signal input_counter : integer range 10 downto 0 := 0;
	signal shift_counter : integer range 10 downto 0 := 0;
	signal shift_done : std_logic := '0';
	signal shift_en, clkoutl, reg_latchl : std_logic := '0'; 
	signal shiftbyte: std_logic_vector(7 downto 0); 
	 
	 

begin
	input_clock: process(CLK, DATA, KOUT, DATALOCK, input_counter, shift_done, input_cs, RESET) is
	begin
		if RESET = '1' then
			input_cs <= none;
			input_counter <= 0;
		else
			if rising_edge(CLK) then

				input_cs <= input_ns; 				

				if input_cs = count_rst then
					input_counter <= 6;
				elsif input_cs = dec then
					input_counter <= input_counter - 1;
				end if;
				RCK <= reg_latchl; 

			end if;
		end if; 
	end process input_clock; 

	input_fsm: process(input_cs, input_counter, DATALOCK, KOUT, DATA, shift_done) is
	begin
		case input_cs is 
			when none => 
				shift_en <= '0';
				reg_latchl  <= '0';
				if DATALOCK = '1' and KOUT = '1' and DATA = "10111100" then 
					input_ns <= count_rst;
				else
					input_ns <= none;
				end if; 
			when count_rst => 
				shift_en <= '0';
				reg_latchl  <= '0';
				input_ns <= byte_wait;
			when byte_wait => 
				shift_en <= '0';
				reg_latchl  <= '0';
				if DATALOCK = '1' then
					input_ns <= byte_shift;
				else
					input_ns <= byte_wait;
				end if; 
			when byte_shift => 
				shift_en <= '1';
				reg_latchl  <= '0';
				if shift_done = '0' then
					input_ns <= byte_shift;
				else
					input_ns <= dec; 
				end if;  
			when dec => 
				shift_en <= '0';
				reg_latchl  <= '0';
				if input_counter = 1 then
					input_ns <= latch_h;
				else
					input_ns <= byte_shift; 
				end if;  									 
			when latch_h => 
				shift_en <= '0';
				reg_latchl  <= '1';
				input_ns <= latch_l;
			when latch_l => 
				shift_en <= '0';
				reg_latchl  <= '0';
				input_ns <= none;
			when others =>
				shift_en <= '0';
				reg_latchl <= '0';
				input_ns <= none;
		end case; 
		
	end process input_fsm ;


	shift_clock: process(CLK, shift_en, shift_counter, shift_cs, DATA, RESET) is
	begin
		if RESET = '1' then
			shift_cs <= none;
			shift_counter <= 0;
		else
			if rising_edge(CLK) then

				shift_cs <= shift_ns; 				

				if shift_cs = count_rst then
					shift_counter <= 7;
				elsif shift_cs = shift then
					shift_counter <= shift_counter - 1;
				end if;
				 
				
				if shift_cs = latch then
					shiftbyte <= DATA;
				elsif shift_cs = shift then
					shiftbyte <= ('0' & shiftbyte(7 downto 1)); 
				end if; 

				
				SRCK  <= clkoutl; 
			end if;
			
		end if;  		


	end process shift_clock; 	
	SOUT <= shiftbyte(0);
	shift_fsm: process(shift_cs, shift_counter, shift_en, DATALOCK) is
	begin
		case shift_cs is 
			when none => 
				clkoutl <= '0';
				shift_done <= '0'; 
				if shift_en = '1' and DATALOCK = '1' then
					shift_ns <= latch;
				else
					shift_ns <= none;
				end if;
			when latch =>
				clkoutl <= '0';
				shift_done <= '0'; 
				shift_ns <= count_rst;
			when count_rst =>
				clkoutl <= '0';
				shift_done <= '0'; 
				shift_ns <= clk_h;
			when clk_h =>
				clkoutl <= '1';
				shift_done <= '0'; 
				shift_ns <= clk_l;
			when clk_l =>
				clkoutl <= '0';
				shift_done <= '0'; 
				shift_ns <= dec;
			when dec =>
				clkoutl <= '0';
				shift_done <= '0'; 
				if shift_counter = 0 then 
					shift_ns <= done;
				else
					shift_ns <= shift;
				end if;
			when shift =>
				clkoutl <= '0';
				shift_done <= '0'; 
				shift_ns <= clk_h;
			when done =>
				clkoutl <= '0';
				shift_done <= '1'; 
				shift_ns <= none;
			when others =>
				clkoutl <= '0';
				shift_done <= '0'; 
				shift_ns <= none; 
		end case;
	end process shift_fsm; 				

end Behavioral;
