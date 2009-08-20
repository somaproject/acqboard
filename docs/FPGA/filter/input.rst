Input
~~~~~~~~~~~~~

The FPGA input module controls ADC sampling, bit acquisition, offset
compensation, and the eventual write-out of the sample bits.

.. figure:: input.svg
   :autoconvert:
   :latexwidth: 6in

   Input control which deserializes ADC samples and performs offset compensation. 

   
ADC interface 
    The ten ACDs are configured in two serial chains of five
    ADCs each, corresponding to input channel sets A and B, and giving
    rise to :signal:`SDIA` and :signal:`SDIB`. The ADC FSM
    controls the sampling sequence; CONCNT the delay
    between the assertion of :signal:`CNV` and the bit read-out;
    :signal:`BITCNT` sends the sample clock. To compesate for the ADC
    readout delay and the propagation delay across the galvanic
    isolators, we delay the :signal:`LSCK` via a shift-register into
    :signal:`BITEN`.

.. figure:: adc.inputFSM.svg
   :autoconvert:

   ADC input FSM,  which reads all ADC serial bitstreams upon the 
   assertion of input clock signal :signal:`INSAMPLE`. 

We go out of our way to make sure we keep the digital signals are
quite during the ADC's conversion period.

Offset arithmatic
       The 16-bit unipolar ACD samples are converted to bipolar samples and
       then added to the per-channel offset values. The resulting
       :signal:`SUM` is checked for overflow and then written to.

Output writing
       For each :signal:`INSAMPLE` assertion we cycle through all channels and
       then write the resulting offset-adjusted values to the downstream
       modules.
