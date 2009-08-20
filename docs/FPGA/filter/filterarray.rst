Filter Array
--------------

.. figure:: filterarray.svg
   :autoconvert:
   :latexwidth: 6in

   Filter coefficient buffer and write pattern. 

The filter array uses BlockRAM to store the 22-bit fixed-point filter
coefficients. The double-buffering allows for independent read-write
ports to let the Control and EEPROM write the coefficients on
mode-switch. Coefficients are written 16-bits at a time via
:signal:`DIN[15:0]` and read out via :signal:`H[21:0]`.
