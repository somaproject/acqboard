# testbench.do file

vlib work

# actual hardware 
vcom -93 -explicit ../../vhdl/fibertx.vhd
vcom -93 -explicit ../../vhdl/decode8b10b.vhd
vcom -93 -explicit ../../vhdl/encode8b10b.vhd


-- simulation entities
vcom -93 -explicit ../components/deserialize/deserialize.vhd
vcom -93 -explicit fibertxtest.vhd


vsim -t 1ps -L xilinxcorelib -lib work fibertxtest
view wave
add wave *
view structure
