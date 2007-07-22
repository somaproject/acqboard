# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/distRAM_dualport.vhd
vcom -93 -explicit ../../vhdl/input.vhd
vcom -93 -explicit ../../vhdl/clocks.vhd
vcom -93 -explicit ../../vhdl/encode8b10b.vhd
vcom -93 -explicit ../../vhdl/FiberTX.vhd
vcom -93 -explicit ../../vhdl/raw.vhd



-- simulation entities
vcom -93 -explicit ../../vhdl/decode8b10b.vhd
vcom -93 -explicit ../components/deserialize/deserialize.vhd
vcom -93 -explicit ../components/ADC/AD7685.vhd
vcom -93 -explicit rawtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work rawtest
view wave
add wave *
view structure
