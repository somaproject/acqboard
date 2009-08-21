.. |pm| replace:: +- 

.. &plusmn;

**************
 Signal Chain
**************

This chapter outlines the design and implementation of the primary
Soma Acquisition Board signal processing chain, from low-level
differential input to encoded binary data. Here we present the
high-level design only, with all figures reflecting simulation and
design specification.

The Soma Acquisition Board signal chain can be partitioned into an
analog signal acquisition section and a digital signal processing
section. The signal acquisition section amplifies the differential
input and scales the signal to make maximal use of the
analog-to-digital converter. Digital signal processing removes aliased
components, frames the data, and encodes the resulting optical output
signal.


.. figure:: signalchain.svg
   :autoconvert:
   :latexwidth: 5in
   :label: signal-chain

   The Soma Acquisition Board signal processing chain.

Signals are divided into two sets of four (A1-A4, B1-B4) with each set
having an optional fifth channel (AC and BC, respectively) (Figure
:ref:`signal-chain`).

=================================
 Input Differential Amplification
=================================

Eight input channels with high common-mode rejection accept |pm| 20
mV.  A constant differential input gain of 100 preamplifies weak input
signals, removing common-mode contamination.  To accommodate the large
DC offsets inherent in most electrophysiology recording environments,
the inputs are AC-coupled.

Optional analog high-pass filtering
=============================================

Low-frequency (1-200 Hz) local field potential (LFP) oscillations can
range to several millivolts. The higher-frequency extracellular action
potentials (spikes) are normally sub-millivolt. When recording spikes
the larger-amplitude LFP could potentially saturate our amplifier;
thus we have an optional single-pole high-pass filter (f\ :sub:`-3dB`\
=300 Hz ) that can optionally remove these low-frequency oscillations
and maximize spike acquisition dynamic range.

Each group of four input channels feeds into an optional fifth channel
(A.C and B.C) which can independently filter the
differentially-amplified input. This allows for each bundle of four
channels to record high-frequency, low-amplitude spike signals and to
simultaneously record the low-frequency, higher-voltage LFP.


Programmable gain
===================

The programmable gain amplification stage ranges over two orders
of magnitude. The table below shows the PGA gain, total
system gain, maximum input voltage, and LSB size for the possible
settings.

:latex:`begin{singlespace}`

   ========   ===========  ===================  =========
   PGA gain   Total Gain   Input Voltage Range  LSB size 
   --------   -----------  -------------------  ---------
   1           100         |pm| 20.480 mV        625 nV
   2           200         |pm| 10.240 mV        312 nV
   5           500  	   |pm| 4.096 mV      	 125 nV
   10          1000 	   |pm| 2.048 mV       	 62.5 nV
   20          2000 	   |pm| 1.024 mV       	 31.3 nV
   50          5000 	   |pm| 0.410 mV       	 12.5 nV
   100         10000 	   |pm| 0.205 mV       	 6.3 nV
   ========   ===========  ===================  =========

:latex:`end{singlespace}`

Analog to Digital Conversion
============================

To achieve 16-bit resolution with an input bandwidth of 10kHz, we
oversample the input signal, downsample, and digitally filter. This
allows us to use a more lenient analog antialiasing filter at the cost
of sampling at a faster rate. The filtering process is the combination
of the following factors:

  - an initial antialiasing filter
  - The analog-to-digital conversion step
  - fixed-point FIR filtering
  - downsampling


Antialiasing Filter & ADC
-------------------------

To achieve our desired sampling rate, an 8-pole Bessel filter
achieves greater than 96 dB attenuation within the stop-band while
maintaining linear phase (constant group delay) across the passband.
Over the desired 10 kHz bandwidth the filter droops 1.5 dB. 

.. figure:: soma-1.analog.freqres.svg
   :autoconvert:
   :latexwidth: 5in

   Anti-aliasing filter total frequency response.

.. figure:: soma-1.analog.pass.svg
   :autoconvert:
   :latexwidth: 5in

   Antialiasing filter passband frequency response

.. figure:: soma-1.analog.grd.svg
   :autoconvert:
   :latexwidth: 5in

   Anti-aliasing filter group delay.


A 16-bit ADC running at 192 kSPS samples the resulting 
antialiased signal.

Filtering
----------

We filter the sampled data using an 143-Tap FIR filter using
fixed-point convolution. We use an extended-precision multiplier,
22-bit filter coefficients, and an extended-width accumulator to
reduce the quantization artifacts. 

The Parks-McClellan optimum equiripple FIR filter is used for a cutoff
at 10 kHz; the resulting frequency response (and coefficient-quantized
frequency response) are seen in the figure below. The 143-tap filter
gives the required stopband attenuation while keeping FIR-induced
passband ripple to under 0.5 dB, while fitting in our allocated FPGA
resources.

.. figure:: soma-1.digital.quant.svg
   :autoconvert:
   :latexwidth: 5in

   Frequency response of FIR filter, both ideal (float-point) response and the filtering performance when coefficients are quantized to 22 bits. 


Downsampling
-------------

We filter and then downsample; the filtering step is actually only
performed once for every M=6 input samples, as the other M-1
samples would be removed in the decimation step and thus be wasted.

======================================
Total response, designed and measured
======================================

The resulting frequency response of the combined analog and digital
filters are shown in figures blah, including zoomed-in passband and
stopband performance. The frequency response following decimation is
also shown, with the sum of the (imperfectly filtered) antialiased
components highlighted. Note that this gives us a theoretical
signal-to-alias ratio in excess of 100 dB, below that of our 
ADC quantization noise floor. 

.. figure:: soma-1.digital.aggregate.svg
   :autoconvert:
   :latexwidth: 5in

   Aggregate pre-decimation signal chain filtering.


.. figure:: soma-1.digital.pass.svg
   :autoconvert:
   :latexwidth: 5in

   Aggregate pre-decimation signal chain passband.

.. figure:: soma-1.digital.withaliases.svg
   :autoconvert:
   :latexwidth: 5in

   Aggregate post-decimation filtering.



=======================
Digital Output
=======================

The resulting sampled bytes are transmitted at 32 ksps over an 8MHz
650nm 8b/10b-encoded link. A separate input 8b/10b link sends commands
to control gain, filter settings, and the like. This allows complete
long-haul electrical isolation between the acquisition system
and the downstream noisy digital analysis. 

Transmission of the a serial bitstream requires the receiver to
synchronize to the bitstream so as to determine bit
boundaries. Transitions between one and zero bits can be used to infer
the clocking parameters, but long strings of ones or zeros may result
in a gradual precession and, eventually, a bit error. To prevent this,
we use the 8b/10b encoding scheme.

8b/10b encodes 8-bit symbols in 10 bits of data
:bibcite:`Widmer_DC-Balanced_1983` selecting code words to guarantee a
bit transition at least every six bits. 8b/10b also includes defines
framing ("comma") characters which simplify packet identification.
