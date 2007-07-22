# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/clocks.vhd


-- simulation entities
vcom -93 -explicit clocktest.vhd


vsim -t 1ps -L xilinxcorelib -lib work clocktest
view wave
add wave *
view structure
