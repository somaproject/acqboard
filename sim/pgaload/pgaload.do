# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/distRAM.vhd
vcom -93 -explicit ../../vhdl/PGAload.vhd

-- simulation entities
vcom -93 -explicit ../components/PGA/PGA.vhdl
vcom -93 -explicit pgaloadtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work pgaloadtest
view wave
add wave *
view structure
