--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    17:20:28 06/22/05
-- Design Name:    
-- Module Name:    main - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( CLK : in std_logic;
           CNV : out std_logic;
           DIN : in std_logic;
           LED0 : out std_logic;
           LED1 : out std_logic;
           SCK : out std_logic);
end main;

architecture Behavioral of main is
  signal counter : std_logic_vector(7 downto 0) := (others => '0');
  signal ledcnt : std_logic_vector(15 downto 0) := (others => '0');  
begin

  main: process(CLK)
    begin
      if rising_edge(CLK) then
        if counter = X"A0" then
          counter <= (others => '0');
        else
          counter <= counter + 1; 
        end if;

        if counter = X"00" then
          CNV <= '0';
          ledcnt <= ledcnt + 1; 
        else
          CNV <= '1'; 
        end if;

        LED0 <= ledcnt(15);

        

        if counter > X"60" then
          SCK <= counter(1);
          
        else
          SCK <= '0'; 
        end if;

        LED1 <= DIN; 
      end if;
    end process main;
   


    
end Behavioral;
