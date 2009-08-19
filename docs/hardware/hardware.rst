******************************
Components and Circuit Design 
******************************

The design of the Soma Acquisition hardware matches the [Signal
Chain]_ closely, but for the purpose of this discussion we will divide
it into the analog and digital subsections.

Overview: 
   analog bipolar low-level side
   digital high-frequency side

==============================
Analog 
==============================

Input front-end
------------------------------

(see :ref:`input_schematic`)

The AD8221AR (:part:`U12`) is used as an input instrumentation
amplifier due to it's excellent linearity and high common-mode
rejection [AD8221_DataSheet]_. We use a fixed gain of 100 set by
:part:`R26` -- programmable gain at this stage would necessitate the
introduction of an analog mux, which would unacceptably degrade
performance.

The input stage is AC-coupled to deal with the issues mentioned in
:doc:`signalchain/signalchain`. We use a simple single pole RC filter
with a 0.1 Hz cutoff at the input. There are other methods of
AC-coupling the input of a three-op-amp instrumentation amp
([OtherACCouplingTrick]_ ), but these AC couple after the input has
gone through at least one stage of internal amplification. The very
high DC component in our common mode voltages would overwhelm this
stage.



Input high-pass filter and Programmable gain
---------------------------------------------
(see :ref:`pga_schematic`)

To optionally high-pass filter the input, a single-pole RC filter is
combined with the JFET-input AD8510 ([AD8510_DataSheet]_, :part:`U7`)
and an ADG619 SPDT analog mux ([ADG619_DataSheet]_). The high input
impedance of the AD8510 results in minimum impact to the overall
signal chain.

The bipolar programmable-gain LTC6910-1 :part:`U8` provides gains of
0, 1, 2, 5, 10, 20, 50, and 100, allowing us to maximize the input
dynamic range of the ADC.


Programmable Gain Shift Register Network
----------------------------------------

(see :ref:`shiftreg_schematic`)

For each channel we have four bits of state: the three for PGA state
and one for HPF state. We use a cascaded array of shift registers
to propagate these settins from the FPGA to the actual analog components. 


Input Anti-Aliasing Filter
----------------------------------------
(see :ref:`aafilter_schematic`)

Eight-pole bessel

Low-noise JFET in-amp

Last stage we bias with Vos. 

ADC
---
(see :ref:`adc_schematic`)

:part:`AD7685` :designator:`U2`

Differential input, single-supply

Individually buffer voltage reference


Voltage Refernece
--------------------------------
Use :part:`LM4140CCM-4.1` :designator:`U28`. 

Low-pass filter, use it for VRef. 

Then voltage-divide it, amplify the output, use that for VOs. 
Use super-accurage resistors to prevent thermal drift. 

Power
-----

==============================
Digital
==============================

Galvanic Isolation
--------------------
(see :ref:`isolation_schematic`)

To isolate ground current flow, we use the :part:`IL715-3`
(:designator:`U14`) and :part:`IL716-3` galvanic isolation ICs to
bridge the analog-digital domain. 

FPGA
----
(see :ref:`fpga_scheamtic`)

The Xilinx Spartan-3 VQ100 :part:`XC3s200-4Q100: :designator:`U4` 
performs all the control, signal processing, and communication tasks on
the Acquisition Board. Driven by a single 36 MHz digital oscillator. 

FPGA EEPROM
-----------

JTAG Chain
----------

Power
-----
(see :ref:`fpgapower_scheamtic`)


==============================
Mechanics, PCB, Enclosure
==============================

Protocase, enclosure schematics, etc. 
Gerbers


