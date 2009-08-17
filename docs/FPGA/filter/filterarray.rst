Filter Array
--------------

.. figure:: filterarray.svg

The filter array uses a block of BlockRAM to store the 22-bit
fixed-point filter coefficients. The double-buffering allows for
independent read-write points to let the Control and EEPROM write the
coefficents on mode-switch.

Coefficients are written 16-bits at a time as indicated in Figure
\ref{filterarray}.
