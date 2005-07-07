# ACQBOARD.VHD generic .DO file
# Because modelsim was, well, sucking, I've made my own .DO 
vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/multiplier.vhd
vcom -93 -explicit ../../vhdl/accumulator.vhd
vcom -93 -explicit ../../vhdl/rounding.vhd
vcom -93 -explicit ../../vhdl/overflow.vhd


-- simulation entities
vcom -93 -explicit mactest.vhd



vsim -t 1ps -L xilinxcorelib -lib work mactest
view wave
add wave *
view structure
