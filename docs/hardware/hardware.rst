******************************
Components and Circuit Design 
******************************

The design of the Soma Acquisition hardware matches the [Signal
Chain]_ closely, but for the purpose of this discussion we will divide
it into the analog and digital subsections.  The analog subsection
runs off bipolar 5V rails, and the digital side is powered by an
independent 5V digital supply.

==============================
Analog 
==============================

Input front-end
------------------------------

(see :ref:`input_schematic`)

The AD8221AR (:desig:`U12`) was chosen as the input instrumentation
amplifier due to it's excellent linearity and high common-mode
rejection :bibcite:`analog_devices_ad8221_2007`. We use a fixed gain
of 100 set by :desig:`R26` -- programmable gain at this stage would
necessitate the introduction of an analog mux, which would
unacceptably degrade performance.

The input stage is AC-coupled to deal with the issues mentioned in
:doc:`signalchain/signalchain`. We use a simple single pole RC filter
with a 0.1 Hz cutoff at the input. There are other methods of
AC-coupling the input of a three-op-amp instrumentation amp
(:bibcite:`stitt_ac_1991`), but these AC couple after the
input has gone through at least one stage of internal
amplification. The very high DC component in our common mode voltages
would overwhelm this stage.

Input high-pass filter and Programmable gain
---------------------------------------------
(see :ref:`pga_schematic`)

To optionally high-pass filter the input, a single-pole RC filter is
combined with the JFET-input :part:`AD8510`
(:bibcite:`analog_devices_AD8510_2009`, :desig:`U7`) and an :part:`ADG619`
SPDT analog mux (:bibcite:`analog_devices_ADG619_2007`). The high input
impedance of the AD8510 results in minimum impact to the overall
signal chain.

The bipolar programmable-gain :part:`LTC6910-1`
(:bibcite:`linear_technology_LTC6910-1_2009`) :desig:`U8` provides gains of 0, 1, 2,
5, 10, 20, 50, and 100, allowing us to maximize the input dynamic
range of the ADC.


Programmable Gain Shift Register Network
----------------------------------------

(see :ref:`shiftreg_schematic`)

For each channel we have four bits of state: the three for PGA state
and one for HPF state. We use a cascaded array of shift registers to
propagate these settins from the FPGA to the actual analog components.


Input Anti-Aliasing Filter
----------------------------------------
(see :ref:`aafilter_schematic`)

To achieve filtering we use an eight-pole bessel filter in a multiple
feedback configuration, implemented via low-noise JFET quad op-amp
AD8513AR :bibcite:`analog_devices_AD8513_2009`. 

The last stage is biased with V\ :subscript:`OS` to create a single-sided signal for
the unipolar ADC.

ADC
---
(see :ref:`adc_schematic`)

The differential input, single-supply ADCs :part:`AD7685` :desig:`U2`
(:bibcite:`analog_devices_AD7685_2007`) are driven at 192 ksps at from
a common conversion signal. Each ADC's voltage reference input ( V\
:subscript:`REF`) is individually buffered to limit the voltage drop
on the reference with each ADC cycle.

Voltage Refernece
--------------------------------

:part:`LM4140CCM-4.1` :desig:`U28` is used as the voltage reference,
providing V\ :subscript:`REF` at 4.096V with a 0.1% initial accuracy
and excellent 3 ppm / C stability. The output of the reference
is low-pass filtered before being distributed to the ADCs, which
are individually-buffered. The voltage reference
is voltage-divided via precision resistors to provide 
the V\ :subscript:`OS` offset. 


==============================
Digital
==============================

Galvanic Isolation
--------------------
(see :ref:`isolation_schematic`)

To isolate ground current flow, we use the :part:`IL715-3`
(:desig:`U14`) and :part:`IL716-3` high-speed galvanic isolation ICs
:bibcite:`NVE_High-Speed_2009` to bridge the analog-digital domain.

FPGA
----
(see :ref:`fpga_scheamtic`)

The Xilinx Spartan-3 VQ100 :part:`XC3s200-4Q100: :desig:`U4`
(:bibcite:`xilinx_spartan-3_2009`) performs all the control, signal
processing, and communication tasks on the Acquisition Board. The FPGA
is driven by a single 36 MHz digital oscillator.

The primary bitstream is contained within a :part:`XCFS01` Platform
Flash EEPROM. Both the Spartan-3 and the Platform Flash EEPROM are
connected to the primary JTAG chain.

To power the FPGA we take the input 5V and convert it to the
3.3 V for IO, the 2.5V aux level, and the 1.2 V core. 

(see :ref:`fpgapower_scheamtic`)

Optical Interface
------------------

The 8MHz serial link is carried at 650 nm via 1 mm plastic optical
fiber. We use the Avago :part:`HFBR-1528` transmitter and
:part:`HFBR-2528` receiver, which can transmit up to 10 MBd over
50 m of the inexpensive plastic fiber. 

==============================
Mechanics, PCB, Enclosure
==============================

Protocase, enclosure schematics, etc. 
Gerbers


