# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/clocks.vhd
vcom -93 -explicit encode8b10b.vhd
vcom -93 -explicit ../../vhdl/fibertx.vhd
vcom -93 -explicit simple.vhd


-- simulation entities
vcom -93 -explicit ../../simulation/components/ADC/ADC.vhd
vcom -93 -explicit simpletest.vhd


vsim -t 1ps -L xilinxcorelib -lib work simpletest
view wave
add wave *
view structure
