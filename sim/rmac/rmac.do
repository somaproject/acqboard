# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/accumulator.vhd
vcom -93 -explicit ../../vhdl/multiplier.vhd
vcom -93 -explicit ../../vhdl/overflow.vhd
vcom -93 -explicit ../../vhdl/rounding.vhd
vcom -93 -explicit ../../vhdl/RMAC.vhd

-- simulation entities
vcom -93 -explicit rmactest.vhd


vsim -t 1ps -L xilinxcorelib -lib work rmactest
view wave
add wave *
view structure
