----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Generates a SPDIF signal with given sampling rate.           ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
--
-- CVS Revision History
--
-- $Log: spdif_source.vhd,v $
-- Revision 1.3  2004/07/11 16:20:16  gedra
-- Improved test bench.
--
-- Revision 1.2  2004/06/06 15:45:24  gedra
-- Cleaned up lint warnings.
--
-- Revision 1.1  2004/06/03 17:45:18  gedra
-- SPDIF signal generator.
--
--

library ieee;
use ieee.std_logic_1164.all;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity spdif_source is             
	 port (                              -- Bitrate is 64x sampling frequency
    CLKin : IN STD_LOGIC; 
    spdif: out std_logic;
    CLKOUT : out std_logic;
    ADCCONVST : out std_logic;
    ADCCS : out std_logic;
    SCLK : out std_logic;
    SDIN : in std_logic );            -- Output bi-phase encoded signal
end spdif_source;

architecture behav of spdif_source is  

	component DCM
	--
	    generic ( 
	             DFS_FREQUENCY_MODE : string := "LOW";
	             CLKFX_DIVIDE : integer := 1;
			   CLKFX_MULTIPLY : integer := 4 ;
			   STARTUP_WAIT : boolean := False;
	             CLK_FEEDBACK : string := "NONE" 
	            );  
	--
	    port ( CLKIN     : in  std_logic;
	           CLKFB     : in  std_logic;
	           DSSEN     : in  std_logic;
	           PSINCDEC  : in  std_logic;
	           PSEN      : in  std_logic;
	           PSCLK     : in  std_logic;
	           RST       : in  std_logic;
	           CLK0      : out std_logic;
	           CLK90     : out std_logic;
	           CLK180    : out std_logic;
	           CLK270    : out std_logic;
	           CLK2X     : out std_logic;
	           CLK2X180  : out std_logic;
	           CLKDV     : out std_logic;
	           CLKFX     : out std_logic;
	           CLKFX180  : out std_logic;
	           LOCKED    : out std_logic;
	           PSDONE    : out std_logic;
	           STATUS    : out std_logic_vector(7 downto 0)
	          );
	end component;

  constant X_Preamble : std_logic_vector(7 downto 0) := "11100010";
  constant Y_Preamble : std_logic_vector(7 downto 0) := "11100100";
  constant Z_Preamble : std_logic_vector(7 downto 0) := "11101000";
  signal reset, CLK, CLKO,  ispdif: std_logic;
  signal fcnt : natural range 0 to 191;   -- frame counter
  signal bcnt : natural range 0 to 63;    -- subframe bit counter
  signal pcnt : natural range 0 to 63;  -- parity counter
  signal toggle : integer range 0 to 1;
  -- Channel A: sinewave with frequency=Freq/12
  type sine16 is array (0 to 15) of std_logic_vector(15 downto 0);
  signal channel_a : sine16 := ((x"8000"),(x"b0fb"),(x"da82"),(x"f641"),
                                (x"ffff"), (x"f641"), (x"da82"), (x"b0fb"),
                                (x"8000"), (x"4f04"), (x"257d"), (x"09be"),
                                (x"0000"), (x"09be"), (x"257d"), (x"4f04"));
  -- channel B: sinewave with frequency=Freq/24
  type sine8 is array (0 to 7) of std_logic_vector(15 downto 0);
  signal channel_b : sine8 := ((x"8000"), (x"da82"), (x"ffff"), (x"da82"),
                               (x"8000"), (x"257d"), (x"0000"), (x"257d"));
  signal channel_status: std_logic_vector(0 to 191);
  component TOC 
        port (O : out std_logic); 
    end component; 
  signal clken : std_logic := '0';
component BUFG 
  port (
  	I   : in std_logic;
        O    : out std_logic
	); 

end component;

	component RAMB16_S18
	--
	  generic (
	       WRITE_MODE : string := "WRITE_FIRST";
	       INIT  : bit_vector  := X"00000";
	       SRVAL : bit_vector  := X"00000";
	       INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
	       INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
	  );
	--
	  port (DI     : in STD_LOGIC_VECTOR (15 downto 0);
	        DIP    : in STD_LOGIC_VECTOR (1 downto 0);
	        EN     : in STD_logic;
	        WE     : in STD_logic;
	        SSR    : in STD_logic;
	        CLK    : in STD_logic;
	        ADDR   : in STD_LOGIC_VECTOR (9 downto 0);
	        DO     : out STD_LOGIC_VECTOR (15 downto 0);
	        DOP    : out STD_LOGIC_VECTOR (1 downto 0)
	       ); 

	end component;


	signal ramaddr : std_logic_vector(9 downto 0) := (others => '0'); 
	signal ramdata : std_logic_vector(15 downto 0) := (others => '0'); 

	signal adccnt : std_logic_vector(6 downto 0) := (others => '0'); 
	signal ladccs : std_logic := '0';
	signal sclkdelay : std_logic_vector(5 downto 0) := (others => '0'); 
	signal serdin, serdinl : std_logic_vector(31 downto 0) 
		:= (others => '0'); 
	signal chana, chanb : std_logic_vector(15 downto 0)
		:= (others => '0'); 

begin
   
   U1: TOC port map (O=>reset);

  
   freqsyn: dcm generic map (
   		DFS_FREQUENCY_MODE => "LOW",
		CLKFX_DIVIDE => 5,
		CLKFX_MULTIPLY=> 4,
		STARTUP_WAIT => True,
		CLK_FEEDBACK => "NONE"	  
   	) port map (

            CLKIN =>    CLKIN,
            CLKFB =>    '0',
            DSSEN =>    '0',
            PSINCDEC => '0',
            PSEN =>     '0',
            PSCLK =>    '0',
            RST =>      RESET,
            CLKFX =>    CLKO,
		  CLKFX180 => open,
            LOCKED =>   open);
		  
		  
		  
   U0_BUFG: BUFG
  port map (
  	    I => CLKO,
            O => CLK
  	   );
   datarom : RAMB16_S18 generic map (
			INIT_00 => X"1B7C5CF27C7F6EA13866ED98A98184F88D52BF83093A4F9478E5761B483B0000",
			INIT_01 => X"1572CA5E92DB832AA104E1852D25684D7D6764C12759DB969D1C82B69606CFFF",
			INIT_02 => X"BCE406284D2D780A771C4AB90314BA4F8AF78652AE11F3B43DD471657B9858B3",
			INIT_03 => X"668F2A42DE8B9F0982E69468CD2B18795AD97C15700C3B22F0A5ABC2859C8C1C",
			INIT_04 => X"859CABC2F0A53B22700C7C155AD91879CD2B946882E69F09DE8B2A42668F7D71",
			INIT_05 => X"7B9871653DD4F3B4AE1186528AF7BA4F03144AB9771C780A4D2D0628BCE48C1C",
			INIT_06 => X"960682B69D1CDB96275964C17D67684D2D25E185A104832A92DBCA5E157258B3",
			INIT_07 => X"483B761B78E54F94093ABF838D5284F8A981ED9838666EA17C7F5CF21B7CCFFF",
			INIT_08 => X"E484A30E8381915FC79A1268567F7B0872AE407DF6C6B06C871B89E5B7C50000",
			INIT_09 => X"EA8E35A26D257CD65EFC1E7BD2DB97B382999B3FD8A7246A62E47D4A69FA3001",
			INIT_0A => X"431CF9D8B2D387F688E4B547FCEC45B1750979AE51EF0C4CC22C8E9B8468A74D",
			INIT_0B => X"9971D5BE217560F77D1A6B9832D5E787A52783EB8FF4C4DE0F5B543E7A6473E4",
			INIT_0C => X"7A64543E0F5BC4DE8FF483EBA527E78732D56B987D1A60F72175D5BE9971828F",
			INIT_0D => X"84688E9BC22C0C4C51EF79AE750945B1FCECB54788E487F6B2D3F9D8431C73E4",
			INIT_0E => X"69FA7D4A62E4246AD8A79B3F829997B3D2DB1E7B5EFC7CD66D2535A2EA8EA74D",
			INIT_0F => X"B7C589E5871BB06CF6C6407D72AE7B08567F1268C79A915F8381A30EE4843001",
			INIT_10 => X"1B7C5CF27C7F6EA13866ED98A98184F88D52BF83093A4F9478E5761B483B0000",
			INIT_11 => X"1572CA5E92DB832AA104E1852D25684D7D6764C12759DB969D1C82B69606CFFF",
			INIT_12 => X"BCE406284D2D780A771C4AB90314BA4F8AF78652AE11F3B43DD471657B9858B3",
			INIT_13 => X"668F2A42DE8B9F0982E69468CD2B18795AD97C15700C3B22F0A5ABC2859C8C1C",
			INIT_14 => X"859CABC2F0A53B22700C7C155AD91879CD2B946882E69F09DE8B2A42668F7D71",
			INIT_15 => X"7B9871653DD4F3B4AE1186528AF7BA4F03144AB9771C780A4D2D0628BCE48C1C",
			INIT_16 => X"960682B69D1CDB96275964C17D67684D2D25E185A104832A92DBCA5E157258B3",
			INIT_17 => X"483B761B78E54F94093ABF838D5284F8A981ED9838666EA17C7F5CF21B7CCFFF",
			INIT_18 => X"E484A30E8381915FC79A1268567F7B0872AE407DF6C6B06C871B89E5B7C50000",
			INIT_19 => X"EA8E35A26D257CD65EFC1E7BD2DB97B382999B3FD8A7246A62E47D4A69FA3001",
			INIT_1A => X"431CF9D8B2D387F688E4B547FCEC45B1750979AE51EF0C4CC22C8E9B8468A74D",
			INIT_1B => X"9971D5BE217560F77D1A6B9832D5E787A52783EB8FF4C4DE0F5B543E7A6473E4",
			INIT_1C => X"7A64543E0F5BC4DE8FF483EBA527E78732D56B987D1A60F72175D5BE9971828F",
			INIT_1D => X"84688E9BC22C0C4C51EF79AE750945B1FCECB54788E487F6B2D3F9D8431C73E4",
			INIT_1E => X"69FA7D4A62E4246AD8A79B3F829997B3D2DB1E7B5EFC7CD66D2535A2EA8EA74D",
			INIT_1F => X"B7C589E5871BB06CF6C6407D72AE7B08567F1268C79A915F8381A30EE4843001"
		   	)
   	port map  (
   	
		DI => X"0000",
		DIP => "00",
		EN => '1',
		SSR => '0',
		WE => '0',
		CLK => clk,
		ADDR => ramaddr,
		DO => ramdata,
		dop => open); 


  spdif <= ispdif;
  channel_status <= (others => '0');
  CLKOUT <= clk; 
-- Generate SPDIF signal 
  SGEN: process (clk, reset)
  begin  
    if reset = '1' then                   
      fcnt <= 184;      -- start just before block to shorten simulation
      bcnt <= 0;
      toggle <= 0;
      ispdif <= '0';
      pcnt <= 0;
    elsif rising_edge(clk) then
    	  clken <= not clken; 

	  ADCCS <= ladccs; 

  	  if ladccs = '1' then  
	    adccnt <= (others => '0');
	     
	  else 
	 	if adccnt /= "1000000" then
			 adccnt <= adccnt + 1;	
	 	end if;
	  end if; 
	  
	  SCLK <= adccnt(0);
	  sclkdelay <= sclkdelay(4 downto 0) & adccnt(0); 

	 -- latch in data
	 if  sclkdelay(1) = '0' and sclkdelay(0) = '1' then
	 	serdin <= serdin(30 downto 0) & SDIN; 
	 end if; 

	  if clken = '1' then 
	      if toggle = 1 then
	        -- frame counter: 0 to 191

		   if bcnt = 63 then
		   	  ADCCONVST <= '0';
			  serdinl <= serdin; 
			  chana <= serdinl(15 downto 0) - X"8000"; 
			  chanb <= serdinl(31 downto 16) - X"8000"; 

		       if ramaddr = "0111111111" then
			  	ramaddr <= (others => '0');
			  else

			     ramaddr <= ramaddr + 1; 
                 end if; 
		   else
		   	  ADCCONVST <= '1';
		   end if;  

		   if bcnt > 32 then
		   	 lADCCS <= '0';
		   else
		      lADCCS <= '1';
             end if; 
	        if fcnt < 191 then
	          if bcnt = 63 then
	            fcnt <= fcnt + 1;
	          end if;
	        else
	          fcnt <= 0;
	        end if;
	        -- subframe bit counter: 0 to 63
	        if bcnt < 63 then
	          bcnt <= bcnt + 1;
	        else
	          bcnt <= 0;
	        end if;
	      end if;

	      if toggle = 0 then
	        toggle <= 1;
	      else
	        toggle <= 0;
	      end if;





	      -- subframe generation
	      if fcnt = 0 and bcnt < 4 then
	        ispdif <= Z_Preamble(7 - 2* bcnt - toggle);
	      elsif fcnt > 0 and bcnt < 4 then
	        ispdif <= X_Preamble(7 - 2 * bcnt - toggle);
	      elsif bcnt > 31 and bcnt < 36 then
	        ispdif <= Y_Preamble(71 - 2 * bcnt - toggle);
	      end if;
	      -- aux data, and 4 LSB are zero
	      if (bcnt > 3 and bcnt < 12) or (bcnt > 35 and bcnt < 44) then
	        if toggle = 0 then
	          ispdif <= not ispdif;
	        end if;
	      end if;
	      -- chanmel A data
	      if (bcnt > 11) and (bcnt < 28) then
	        if chana(bcnt - 12) = '0' then
	          if toggle = 0 then
	            ispdif <= not ispdif;
	          end if;
	        else
	          ispdif <= not ispdif;
	          if toggle = 0 then
	            pcnt <= pcnt + 1;
	          end if;
	        end if;
	      end if;
	      -- channel B data
	      if (bcnt > 43) and (bcnt < 60) then
	        if chanb(bcnt - 44) = '0' then
	          if toggle = 0 then
	            ispdif <= not ispdif;
	          end if;
	        else
	          ispdif <= not ispdif;
	          if toggle = 0 then
	            pcnt <= pcnt + 1;
	          end if;
	        end if;
	      end if;
	      -- validity bit always 0
	      if bcnt = 28 or bcnt = 60 then
	        if toggle = 0 then
	          ispdif <= not ispdif;
	        end if;
	      end if;
	      -- user data always 0
	      if bcnt = 29 or bcnt = 61 then
	        if toggle = 0 then
	          ispdif <= not ispdif;
	        end if;
	      end if;
	      -- channel status bit
	      if bcnt = 30 or bcnt = 62 then 
	        if channel_status(fcnt) = '0' then
	          if toggle = 0 then
	            ispdif <= not ispdif;
	          end if;
	        else
	          ispdif <= not ispdif;
	          if toggle = 0 then
	            pcnt <= pcnt + 1;
	          end if;
	        end if;
	      end if;
	      -- parity bit, even parity
	      if bcnt = 0 or bcnt = 32 then
	        pcnt <= 0;
	      end if;
	      if bcnt = 31 or bcnt = 63 then
	        if (pcnt mod 2) = 1 then
	          ispdif <= not ispdif;
	        else
	          if toggle = 0 then
	            ispdif <= not ispdif;
	          end if;
	        end if;
	  end if; 
      end if;
    end if;
  end process SGEN;
  
    
end behav;
