*******************************
Digital Design of FPGA 
*******************************

The Xilinx Spartan-3 is used for acquisition control, digital
filtering, and data encoding and transmission. The modular firmware
architecture (figure :latex:`ref{fpga_overview}` ) implements this
functionality in VHDL.

.. figure:: FPGA.svg
   :autoconvert:
   :latexwidth: 6in
   :label: fpga_overview

   Overall architecture of the FPGA firmware for signal processing and amplifier control. 


.. toctree:: 

     clocks.rst
     filter/input.rst
     filter/samplebuffer.rst
     filter/filterarray.rst
     filter/rmac.rst
     io/io.rst
     pga.rst
     eepromio.rst
     loader.rst
     control.rst

.. Control}



.. \section{Storage}
.. \import{.}{eepromio.tex}

