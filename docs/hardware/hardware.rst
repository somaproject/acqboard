******************************
Components and Circuit Design 
******************************

The design of the Soma Acquisition hardware matches the signal chain closely, but for the purpose of this discussion we will divide
it into the analog and digital subsections (figure
:latex:`ref{overview_schematic}`) .  The analog subsection runs off
bipolar 5V rails, and the digital side is powered by an independent 5V
digital supply.

==============================
Analog 
==============================

Input front-end
------------------------------

The AD8221AR (:desig:`U12`) (figure :latex:`ref{input_schematic}`) was
chosen as the input instrumentation amplifier due to its excellent
linearity and high common-mode rejection
:bibcite:`analog_devices_ad8221_2007`. We use a fixed gain of 100 set
by :desig:`R26` -- programmable gain at this stage would necessitate
the introduction of an analog mux, which would unacceptably degrade
performance.

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

To optionally high-pass filter the input, a single-pole RC filter
(figure :latex:`ref{pga_schematic}`) is combined with the JFET-input
:part:`AD8510` (:bibcite:`analog_devices_AD8510_2009`, :desig:`U7`)
and an :part:`ADG619` SPDT analog mux
(:bibcite:`analog_devices_ADG619_2007`). The high input impedance of
the AD8510 results in minimum impact to the overall signal chain.

The bipolar programmable-gain :part:`LTC6910-1`
(:bibcite:`linear_technology_LTC6910-1_2009`) :desig:`U8` provides
gains of 0, 1, 2, 5, 10, 20, 50, and 100, allowing us to maximize the
input dynamic range of the ADC.


Programmable Gain Shift Register Network
----------------------------------------

For each channel we have four bits of state: the three for PGA state
and one for HPF state. We use a cascaded array of shift registers
(figure :latex:`ref{shiftreg_schematic}`) to propagate these settings
from the FPGA to the actual analog components.


Input Anti-Aliasing Filter
----------------------------------------

To achieve filtering we use an eight-pole Bessel filter in a multiple
feedback configuration (figure :latex:`ref{aafilter_schematic}`) ,
implemented via low-noise JFET quad op-amp AD8513AR
:bibcite:`analog_devices_AD8513_2009`.

The last stage is biased with V\ :subscript:`OS` to create a single-sided signal for
the unipolar ADC.

ADC
---

The differential input, single-supply ADCs :part:`AD7685` :desig:`U2`
(:bibcite:`analog_devices_ad7685_2007`) are driven at 192 ksps from
a common conversion signal (figure :latex:`ref{adc_schematic}`) . Each
ADC's voltage reference input ( V\ :subscript:`REF`) is individually
buffered to limit the voltage drop on the reference with each ADC
cycle.

Voltage Refernece
--------------------------------

:part:`LM4140CCM-4.1` :desig:`U28` is used as the voltage reference,
providing V\ :subscript:`REF` at 4.096V with a 0.1% initial accuracy
and excellent 3 ppm / C stability
:bibcite:`National_Semiconductor_LM4140_2005`. The output of the
reference is low-pass filtered before being distributed to the ADCs,
which are individually-buffered. The voltage reference is
voltage-divided via precision resistors to provide the V\
:subscript:`OS` offset.


==============================
Digital
==============================

Galvanic Isolation
--------------------

To isolate ground current flow, we use the :part:`IL715-3`
(:desig:`U14`) and :part:`IL716-3` high-speed galvanic isolation ICs
:bibcite:`nve_il715_2009` to bridge the analog-digital domain (figure
:latex:`ref{isolation_schematic}`). 


FPGA
----

The Xilinx Spartan-3 VQ100 :part:`XC3s200-4Q100` :desig:`U4`
(:bibcite:`xilinx_spartan-3_2009`) performs all the control, signal
processing, and communication tasks on the Acquisition Board (figure
:latex:`ref{fpga_schematic}`) . The FPGA is driven by a single 36 MHz
digital oscillator.

The primary bitstream is contained within a :part:`XCFS01` Platform
Flash EEPROM. Both the Spartan-3 and the Platform Flash EEPROM are
connected to the primary JTAG chain (figure
:latex:`ref{fpgapower_schematic}`). To power the FPGA we take the input
5V and convert it to the 3.3 V for IO, the 2.5V aux level, and the 1.2
V core. 

Optical Interface
------------------

The 8MHz serial link is carried at 650 nm via 1 mm plastic optical
fiber. We use the Avago :part:`HFBR-1528` transmitter
:bibcite:`avago_hfbr-1528_2009` and :part:`HFBR-2528` receiver :bibcite:`avago_hfbr-2528_2009`, which
can transmit up to 10 MBd over 50 m of the inexpensive plastic fiber.

==============================
Mechanics, PCB, Enclosure
==============================

The resulting Acquisition Board is a four-layer FR-4 PCB measuring 7
inches by 5.5 inches. The majority of signal routing takes place 
on the top layer (figure :latex:`ref{gerber_layer1}`) with
dedicated split power and ground planes (figures :latex:`ref{gerber_layer2}`
and :latex:`ref{gerber_layer3}`). 
