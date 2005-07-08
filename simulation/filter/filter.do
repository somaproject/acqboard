# ACQBOARD.VHD generic .DO file
# Because modelsim was, well, sucking, I've made my own .DO 
vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/input.vhd
vcom -93 -explicit ../../vhdl/samplebuffer.vhd
vcom -93 -explicit ../../vhdl/rmaccontrol.vhd
vcom -93 -explicit ../../vhdl/filterarray.vhd
vcom -93 -explicit ../../vhdl/multiplier.vhd
vcom -93 -explicit ../../vhdl/accumulator.vhd
vcom -93 -explicit ../../vhdl/rounding.vhd
vcom -93 -explicit ../../vhdl/overflow.vhd
vcom -93 -explicit ../../vhdl/rmac.vhd

-- simulation entities
vcom -93 -explicit ../components/ADC/AD7685.vhd
vcom -93 -explicit ../components/FilterLoad/FilterLoad.vhdl
vcom -93 -explicit filtertest.vhd



vsim -t 1ps -L xilinxcorelib -lib work filtertest
view wave
add wave *
view structure
