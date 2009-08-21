Repeated Multiply / Accumulate
------------------------------

FIR filtering is performed by the repeated multiply-accumulate module; the filter used is that described earlier. 

RMAC
~~~~
.. figure:: RMAC.svg
   :autoconvert:
   :latexwidth: 6in
   :label: fpga_rmac

   Repeated Multiply-Accumulate (RMAC) module for fixed-point convolution.


The repeated multiply-accumulate unit is composed (figure
:latex:`ref{fpga_rmac}`) of the following subcomponents:


**Sample Counters** 
	 Under control of the RMAC FSM, the RMAC drives the
	 sample buffer address pointer :signal:`XA[7:0]` and the
	 filter coefficient buffer address pointer
	 :signal:`HA[7:0]`. The sample buffer address pointer begins
	 at location :signal:`XBASE[7:0]` and counts backwards through
	 the buffer.

**Multiplier** 
   The pipelined multiplier performs fixed-point
   multiplication of the input, truncating the output at 1.23 bits of
   data.

**Extended-Resolution Accumulator**
    For each iteration through the sample buffer, the accumulator sums
    the resulting sample/coefficient products. The arithmetic is done with
    7 extra bits of precision on the left side of the decimal, allowing
    for extended range and to prevent saturation mid-convolution.

**Convergent Rounding**
    Convergent rounding of the input is
    performed, resulting in the output being in **8.15** format.

**Overflow Detection**
   If the output is too large to be
   expressed in 1.15 format than the value saturates at either positve or
   negative extreme.


The RMAC is controlled by a FSM (figure :latex:`ref{fpga_rmac_fsm}`)
that is designed to convolve one channel's data per
:signal:`STARTMAC`. When :signal:`STARTMAC` is asserted, the system
convolves up to a maximum length L=143, and then asserts
:signal:`MACDONE`.

.. figure:: RMAC_fsm.svg
   :autoconvert:
   :label: fpga_rmac_fsm
   
   Controlling FSM for the RMAC.


RMAC control
~~~~~~~~~~~~~

The RMAC control (figure :latex:`ref{fpga_rmac_control}`) coordinates filtering
across all 10 channels as well as incrementing the base address of the
sample buffer, thus controlling the output interface of the sample
ring buffer. The associated FSM (figure :latex:`ref{fpga_rmac_control_fsm}`) is
equally simple, asserting :signal:`STARTMAC` to the RMAC engine and
waiting for completion.

.. figure:: RMACcontrol.svg
   :autoconvert:
   :label: fpga_rmac_control
   
   The RMAC pointer controller. 


.. figure:: RMACcontrol.fsm.svg
   :autoconvert:
   :label: fpga_rmac_control_fsm
   
   The RMAC controller FSM. 
