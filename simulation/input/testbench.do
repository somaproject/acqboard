# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/input.vhd

-- simulation entities
vcom -93 -explicit ../test_ADC.vhd
vcom -93 -explicit testbench.vhd


vsim -t 1ps -L xilinxcorelib -lib work testbench
view wave
add wave *
view structure
