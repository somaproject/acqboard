# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/input.vhd
vcom -93 -explicit ../../vhdl/distRAM_dualport.vhd


-- simulation entities
vcom -93 -explicit ../components/ADC/ADC.vhd
vcom -93 -explicit inputtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work inputtest
view wave
add wave *
view structure
