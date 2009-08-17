
EEPROM I/O
-----------


The EEPROM is a SPI-serial component which can store up to 32 kB of
ram. We store 16-bit big-endian words as in table \ref{eepromaddr}.

-------------   -----------------------------------------
Word Address	Data 
-------------	-----------------------------------------
0-511 		Filter (256 2-word samples) 
512 - 757 	sample buffer initial values (256 words) 
1024 - 1535	offset values for each gain (512 words) 
-------------	-----------------------------------------


On each operation we execute the EEPROM's write-enable (WREN)
instruction, and then a full two bytes.  Since we have 12 bits of
address, we place the 11 input bits on the line and always have the
LSB be zero.

We use the two-byte read and two-byte write seqence capability of the
eeprom for both reads and writes. We never cross page boundary since
we always start with LSB = 0.

To interface to the SPI EEPROM we use a single output mux driven by
:signal:`CNT`.

.. figure:: EEPROMIO.svg
   :autoconvert:

.. figure:: EEPROMIO.fsm.svg
   :autoconvert:
