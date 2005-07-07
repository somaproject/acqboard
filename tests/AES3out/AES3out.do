# testbench.do file

vlib work

# actual hardware 
#vcom -93 -explicit ../../vhdl/distRAM_dualport.vhd
#vcom -93 -explicit bitencode.vhd
#vcom -93 -explicit input.vhd
vcom -93 -explicit aes3_timesim.vhd



-- simulation entities
vcom -93 -explicit AES3reader.vhd
vcom -93 -explicit aes3test.vhd


vsim -t 1ps -L xilinxcorelib -lib work aes3test
view wave
add wave *
view structure
