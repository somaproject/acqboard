# ACQBOARD.VHD generic .DO file
# Because modelsim was, well, sucking, I've made my own .DO 
vlib work

# actual hardware 
vcom -93 -explicit control.vhd
vcom -93 -explicit clocks.vhd
vcom -93 -explicit input.vhd
vcom -93 -explicit samplebuffer.vhd
vcom -93 -explicit rmaccontrol.vhd
vcom -93 -explicit filterarray.vhd
vcom -93 -explicit multiplier.vhd
vcom -93 -explicit accumulator.vhd
vcom -93 -explicit rounding.vhd
vcom -93 -explicit overflow.vhd
vcom -93 -explicit rmac.vhd
vcom -93 -explicit distram.vhd
vcom -93 -explicit pgaload.vhd
vcom -93 -explicit encode8b10b.vhd
vcom -93 -explicit decode8b10b.vhd
vcom -93 -explicit fibertx.vhd
vcom -93 -explicit decoder.vhd
vcom -93 -explicit fiberrx.vhd
vcom -93 -explicit loader.vhd
vcom -93 -explicit eepromio.vhd
vcom -93 -explicit control.vhd
vcom -93 -explicit acqboard.vhd


-- simulation entities
vcom -93 -explicit test_ADC.vhd
vcom -93 -explicit test_deserialize.vhd
vcom -93 -explicit test_serialize.vhd
vcom -93 -explicit test_eeprom.vhd
vcom -93 -explicit test_sendcmd.vhd

vcom -93 -explicit acqboard_testbench.vhd


vsim -t 1ps -L xilinxcorelib -lib work testbench
view wave
add wave *
view structure
