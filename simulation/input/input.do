# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/input.vhd

-- simulation entities
vcom -93 -explicit ../ADC/ADC.vhd
vcom -93 -explicit inputtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work inputtest
view wave
add wave *
view structure
