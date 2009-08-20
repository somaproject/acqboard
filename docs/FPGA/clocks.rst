
================
Clocks
================

.. Status: verified timings are correct in the code. 

The FPGA is clocked at 72 MHz via a DCM-doubled 36-MHz input clock signal. 

A series of centralized synchronized clock-enables coordinates events
across the entire FPGA.

.. tabularcolumns:: |l|c|c|p{7cm}|

===================  ========  ===========  ============================================
Clock name 	     Ticks     Frequency    Use
-------------------  --------  -----------  --------------------------------------------
:signal:`INSAMPLE`   375       192.0 kHz    Input sample clock enable -- sets the input sampling rate
:signal:`OUTSAMPLE`  2250      32.0 kHz	    Output sample clock enable -- controls the output sample rate.
:signal:`OUTBYTE`    90	       800.0 kHz    Output byte clock enable, enables each symbol (encoded byte) on the output fiber interface.
:signal:`CLK8` 	     9	       8.0 MHz 	    Fiber output bit clock.
:signal:`SPICLK`     180       400.0 kHz    SPI clock for interfacing with EEPROM. 
===================  ========  ===========  ============================================
