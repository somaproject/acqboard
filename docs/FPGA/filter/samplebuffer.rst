
Sample Buffer
---------------------------

The sample buffer stores 256 16-bit samples for each of the 10
channels (figure :latex:`ref{fpga_samplebuffer}`). The dual-port
Spartan-3 BlockRam allows for an independent interface to
simultaneously read out the samples. The assertion of
:signal:`ALLCHAN` writes all channels. :signal:`CHAN[3:2]` selects
which internal block is used; :signal:`CHAN[1:0]` selects which range
in the block is written to.


.. figure:: samplebuffer.svg
   :autoconvert:
   :latexwidth: 6in
   :label: fpga_samplebuffer
   
   Sample buffers for 10 channels of input data. 
