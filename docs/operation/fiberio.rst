*************************************
Operation and interfacing
*************************************

The acquisition board has four modes of operation, one normal
multichannel mode, one mode for offset compensation, one mode for link
testing with simulated output, and one mode for single-channel test.

Interfacing with the acquisition board is accomplished via a plastic
optical fiber interface for enhanced electrical isolation even over
long data transmission distances.


Modes
=================
The acquisition board has four modes of operation, designed to set the
internal state and prevent accidental configuration modification
during operation.

**Normal acquisition mode (Mode 0)** 
    Mode 0 is the normal acquisition
    mode; in this mode all 10 channels are sampled at the full normal
    sampling rate and the data is transmitted over the optical link
    using the standard encoding scheme. In this mode, gain and
    hardware filter settings can be changed, but nothing else.

**Offset disable mode (Mode 1)**
       Offset disable mode disables the internal offset compensation. The
       values transmitted are thus the actual measured ADC values. This is
       the only mode in which new offset values can be saved to the board's
       internal non-volatile memory (EEPROM).

**Input disable mode (Mode 2)**
      Input disable mode disables all reading from the ADCs; in
      this mode no change of input or analog settings has any effect on the
      board. While in this mode, the board will continuously transmit a test
      pattern stored in the on-board EEPROM.

      In this mode, both the test pattern and the digital low-pass filter
      can be modified and written to. The sample pattern **is** filtered by
      the digital filter, and can be used as a mechanism to verify that the
      filter coefficients were properly written.

**Raw mode (Mode 3)**
    Raw mode simply outputs the raw, unfiltered, non-decimated
    data from a single selected channel. The 192 ksps data stream occupies
    multiple words in the transmitted data stream. This can be useful to
    characterize the analog properties of a given channel, and to debug
    signal integrity problems.


Fiber IO
==========

The Acquisition Board's external interface is a bidirectional 8 MHz
fiber-optic link over  1mm plastic optical fiber. Both the TX
and RX streams are encoded using 8b/10b encoding.

The Acqboard transmits an 8b/10b-encoded frame of 24 bytes, preceded
by the K28.5 comma character (figure
:latex:`ref{fiber_txpacket}`). 

.. figure:: txpacket.svg
   :autoconvert:
   :pngdpi: 150
   :label: fiber_txpacket
   
   Format of 24-byte frame transmitted by the Acquisition Board. 

The Command Status byte consists of three active bits. CMDST[1:0] are
the mode numbers, indicating the current active mode.  CMDST[0] is a
"loading" bit, and is high **during transition into a new mode.** Mode
switching is not instantaneous because the board needs to read values
from EEPROM, a (comparatively) slow process.

Every command sent to the board contains  a 4-bit Command ID (CMDID);
this is a nonce which indicates command completion. The most
recently-completed Command ID is transmitted with each full
frame. When a command is **done executing** the output Command ID is
changed to reflect this.

CMDRP is the command response field; CMDRP[4:1] are the bits of
the most-recently executed CMDID; CMDRP[0] tells whether or not this
command was successful.

The data fields are 1.15-bit twos-complement fixed point samples from
their corresponding ADCs; they are transmitted MSB first.

Normally, the Acqboard receives a stream of valid 8b/10b encoded
zeros; a new command is indicated by the presence of the comma
character in the data stream followed by a packet (figure
:latex:`ref{fiber_rxpacket}`). A typical command packet is below, and
consists of six bytes. The specific internals of the commands are
explained in the following section.

.. figure:: rxpacket.svg
   :autoconvert:
   :pngdpi: 150
   :label: fiber_rxpacket

   Format of six-byte command sent to the acquisition board. 

Commands
============

The following commands are valid in any mode

Universal Commands
------------------

Switch Mode
^^^^^^^^^^^^

.. figure:: switchmode.cmd.svg
   :autoconvert:
   :pngdpi: 150
   :label: fiber_switchmode

   Switch mode command. 


Switch the current acqboard mode to **mode**. If changing to the
RAW mode, the **chan** field is the 4-bit number of the raw
channel to be transmitted. In all other modes, this field is ignored. 

Note that some mode transitions can take up to 300 ms; during this
time the transmitted packet's CMDST will reflect the new mode, but the
**loading** bit will be high until the mode has been entered. Only
once loading is completed will the CMDID be updated.

Set Gain
^^^^^^^^

.. figure:: setgain.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Set gain command. 

Sets the gain of channel **chan** to one of the preset gain
values **gain**. Valid in all modes.

Set Input
^^^^^^^^^
.. figure:: setinput.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Set input command. 

Select which of the four primary input channels will be used
as input to the secondary input channel. 

High Pass Filter Enable
^^^^^^^^^^^^^^^^^^^^^^^

.. figure:: setfilter.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Enable HPF command. 

Enable or disable the high pass filter on channel the indicated channel.


Mode 1 Commands
----------------

Write offset
^^^^^^^^^^^^^
.. figure:: writeos.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Write offset command. 

This command writes the 16-bit twos-complement value in V as the
digital offset for channel **chan** when the gain on that channel is
set to **gain**. To measure the inherit DC offset (and thus compute
the compensation value) you must be in offset-disable mode.

Mode 2 Commands
----------------

Write filter
^^^^^^^^^^^^^
.. figure:: writefil.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Write filter command. 

This command writes the 22-bit twos-complement value in V as the
addr-th coefficient for the low-pass filter.

Write Sample Buffer
^^^^^^^^^^^^^^^^^^^
.. figure:: writesamp.cmd.svg
   :autoconvert:
   :pngdpi: 150

   Write sample buffer command. 

This command writes the 16-bit twos-complement value in V as the
addr-th sample in the no-input sample buffer.

