Input
~~~~~~~~~~~~~

The FPGA input module (figure \ref{input}) controls ADC sampling, bit
acquisition, offset compensation, and the eventual write-out of the
sample bits.

.. figure:: input.svg
   :autoconvert:

ADC interface

 The two sets of ADCs are serially chained, providing :signal:`SDIA`
and :signal:`SDIB`. The ADC FSM (figure \ref{adcfsm}) controls the
sampling sequence; CONCNT the delay between the assertion of
:signal:`CNV` and the bit read-out; :signal:`BITCNT` sends the sample
clock. To compesate for the ADC readout delay and the propagation
delay across the galvanic isolators, we delay the :signal:`LSCK` via a
shift-register into :signal:`BITEN`.

.. figure:: adc.inputFSM.svg
   :autoconvert:

We go out of our way to make sure we keep the digital signals are
quite during the ADC's conversion period.

Offset arithmatic

The 16-bit unipolar ACD samples are converted to bipolar samples and
then added to the per-channel offset values. The resulting
:signal:`SUM` is checked for overflow and then written to.

Output writing

For each :signal:`INSAMPLE` assertion we cycle through all channels and
hthen write the resulting offset-adjusted values to the downstream
modules.
