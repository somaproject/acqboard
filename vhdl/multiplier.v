/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used             *
*     solely for design, simulation, implementation and creation of            *
*     design files limited to Xilinx devices or technologies. Use              *
*     with non-Xilinx devices or technologies is expressly prohibited          *
*     and immediately terminates your license.                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"            *
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                  *
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION          *
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION              *
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS                *
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                  *
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE         *
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY                 *
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                  *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          *
*     FOR A PARTICULAR PURPOSE.                                                *
*                                                                              *
*     Xilinx products are not intended for use in life support                 *
*     appliances, devices, or systems. Use in such applications are            *
*     expressly prohibited.                                                    *
*                                                                              *
*     (c) Copyright 1995-2002 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synopsys directives "translate_off/translate_on" specified
// below are supported by XST, FPGA Express, Exemplar and Synplicity
// synthesis tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file multiplier.v when simulating
// the core, multiplier. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "Coregen Users Guide".

module multiplier (
	clk,
	a,
	b,
	q,
	sclr);    // synthesis black_box

input clk;
input [13 : 0] a;
input [17 : 0] b;
output [31 : 0] q;
input sclr;

// synopsys translate_off

	MULT_GEN_V5_0 #(
		8,	// bram_addr_width
		0,	// c_a_type
		14,	// c_a_width
		14,	// c_baat
		0,	// c_b_constant
		0,	// c_b_type
		"0000000000000001",	// c_b_value
		18,	// c_b_width
		1,	// c_enable_rlocs
		0,	// c_has_aclr
		0,	// c_has_a_signed
		1,	// c_has_b
		0,	// c_has_ce
		0,	// c_has_loadb
		0,	// c_has_load_done
		0,	// c_has_nd
		0,	// c_has_o
		1,	// c_has_q
		0,	// c_has_rdy
		0,	// c_has_rfd
		1,	// c_has_sclr
		0,	// c_has_swapb
		"mem",	// c_mem_init_prefix
		0,	// c_mem_type
		0,	// c_mult_type
		0,	// c_output_hold
		32,	// c_out_width
		1,	// c_pipeline
		1,	// c_reg_a_b_inputs
		0,	// c_sqm_type
		1,	// c_stack_adders
		1,	// c_standalone
		1,	// c_sync_enable
		1)	// c_use_luts
	inst (
		.CLK(clk),
		.A(a),
		.B(b),
		.Q(q),
		.SCLR(sclr),
		.O(),
		.A_SIGNED(),
		.LOADB(),
		.LOAD_DONE(),
		.SWAPB(),
		.CE(),
		.ACLR(),
		.RFD(),
		.ND(),
		.RDY());


// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of multiplier is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of multiplier is "black_box"

endmodule

