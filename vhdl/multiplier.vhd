--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2002 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file multiplier.vhd when simulating
-- the core, multiplier. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "Coregen Users Guide".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Express, Exemplar and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

-- synopsys translate_off
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

Library XilinxCoreLib;
ENTITY multiplier IS
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(13 downto 0);
	b: IN std_logic_VECTOR(21 downto 0);
	q: OUT std_logic_VECTOR(35 downto 0);
	sclr: IN std_logic);
END multiplier;

ARCHITECTURE multiplier_a OF multiplier IS

component wrapped_multiplier
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(13 downto 0);
	b: IN std_logic_VECTOR(21 downto 0);
	q: OUT std_logic_VECTOR(35 downto 0);
	sclr: IN std_logic);
end component;

-- Configuration specification 
	for all : wrapped_multiplier use entity XilinxCoreLib.mult_gen_v5_0(behavioral)
		generic map(
			c_a_width => 14,
			c_out_width => 36,
			c_b_type => 0,
			c_has_b => 1,
			c_has_rdy => 0,
			c_has_sclr => 1,
			bram_addr_width => 8,
			c_has_nd => 0,
			c_reg_a_b_inputs => 1,
			c_enable_rlocs => 1,
			c_mult_type => 0,
			c_has_rfd => 0,
			c_has_swapb => 0,
			c_baat => 14,
			c_use_luts => 1,
			c_has_load_done => 0,
			c_has_a_signed => 0,
			c_has_ce => 0,
			c_has_aclr => 0,
			c_sync_enable => 1,
			c_output_hold => 0,
			c_stack_adders => 1,
			c_mem_type => 0,
			c_b_constant => 0,
			c_has_q => 1,
			c_has_loadb => 0,
			c_pipeline => 1,
			c_has_o => 0,
			c_standalone => 1,
			c_mem_init_prefix => "mem",
			c_a_type => 0,
			c_b_width => 22,
			c_b_value => "0000000000000001",
			c_sqm_type => 0);
BEGIN

U0 : wrapped_multiplier
		port map (
			clk => clk,
			a => a,
			b => b,
			q => q,
			sclr => sclr);
END multiplier_a;

-- synopsys translate_on

