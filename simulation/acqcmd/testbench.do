# ACQBOARD.VHD generic .DO file
# Because modelsim was, well, sucking, I've made my own .DO 
vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/control.vhd
vcom -93 -explicit ../../vhdl/clocks.vhd
vcom -93 -explicit ../../vhdl/input.vhd
vcom -93 -explicit ../../vhdl/samplebuffer.vhd
vcom -93 -explicit ../../vhdl/rmaccontrol.vhd
vcom -93 -explicit ../../vhdl/filterarray.vhd
vcom -93 -explicit ../../vhdl/multiplier.vhd
vcom -93 -explicit ../../vhdl/accumulator.vhd
vcom -93 -explicit ../../vhdl/rounding.vhd
vcom -93 -explicit ../../vhdl/overflow.vhd
vcom -93 -explicit ../../vhdl/rmac.vhd
vcom -93 -explicit ../../vhdl/distram.vhd
vcom -93 -explicit ../../vhdl/pgaload.vhd
vcom -93 -explicit ../../vhdl/encode8b10b.vhd
vcom -93 -explicit ../../vhdl/decode8b10b.vhd
vcom -93 -explicit ../../vhdl/fibertx.vhd
vcom -93 -explicit ../../vhdl/decoder.vhd
vcom -93 -explicit ../../vhdl/fiberrx.vhd
vcom -93 -explicit ../../vhdl/loader.vhd
vcom -93 -explicit ../../vhdl/eepromio.vhd
vcom -93 -explicit ../../vhdl/control.vhd
vcom -93 -explicit ../../vhdl/acqboard.vhd


-- simulation entities
vcom -93 -explicit ../test_PGA.vhdl
vcom -93 -explicit ../test_SendCMD.vhd
vcom -93 -explicit test_EEPROM.vhdl
vcom -93 -explicit testbench.vhd



vsim -t 1ps -L xilinxcorelib -lib work testbench
view wave
add wave *
view structure
