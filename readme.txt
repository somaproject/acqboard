To do:

Change ADC buffer amps + filter stage into RRIO op-amps
Figure out some solution to the voltage problem. 


Simulations of butterworth input amps


So, there's this problem in that the system, as designed, uses non-RRIO adc buffer op-amps (the AD8021). This sucks, a lot. 

Because if we want to level-shift our input +-2.5 to 0-5V unipolar, we need a RRIO buffer. Plus, there are (IMHO) issues with the adc reliably sampling stuff that gets too close to its rails. 

So, ideally, the ADC could sample 0-4.096 V, and the inputs could be limited to +-2.048 V. Which is great, just switch in a new voltage regulator. We'll still
have to design-in a new buffer amp, but whatever, it may not really need to be RRIO if it can go to within 1V of the rails. 

But how do we find a 1.024V  voltage reference fto bias the buffer OAs?. Accuracy (as in initial, and TCO) isn't that big of a deal because it will
all be taken care of digitally. But the Ibias Is pretty high, and i'm not sure how it varies with amplitude, etc. 

Now, to pick a new Op-Amp:

part	price/160  Ibias (nA)	Vnoise	Voffset	SFDR	notes
AD8027		   4000/6000	
AD8510		   0.075				input v from -2 to +2.5
AD8671		   40		3	75		VOUT too low
AD820							Crappy THD+N
AD8651							VOUT too low
AD8627						-90 


Ha ha, we can just use the AD8027 :) We just need to buffer the voltage-divided reference through an OA. Although, ass, it's performance is mediocre in the THD+N measurement. 

However, the AD8519 supposedly has THD+N in unity gain of 120 dB, although there aren't really graphs. But it will most certainly work as an ADC driver, assuming that the voltage inputs aren't an issue. 

Now, for some math: 
our voltage reference is accurate to 0.1%, and drifts at 25 ppm/C
Resistors for dividing: 0.1%, drift 25 ppm/c

After contacting people, it looks like I may just be SOL wrt getting tempco-matched resistors.  But I can find 25ppm/C ones. 

Now, let's assume values of 10k each, and let's assume that TCo is positive. Now, the tempcos are potentially going to co-vary, because they are in close physical proximity. But ignore that -- let's assume R2 stays constant, and R1 varies at 25 ppm/C, for maximum difference. That works out to Vout = Vin(1+Tco)/(2+Tco), or (for 25 ppm/c) roughly 6 ppm/C. This puts a lot of the responsibility for stability on the voltage reference. We can use a OPA227 to buffer the output. 

--------------------------------------------------------------------------
Soma Command configuration
--------------------------------------------------------------------------
The soma command interface over fiber is spartan at best. 

Each transmit packet has a CMDST byte, a CMDID byte, and a CHKSUM byte.

The acqboard can be in one of three modes:
    Mode 0: normal mode, acquiring and filtering data. 
    Mode 1: offset disable -- dc offset compensation is disabled
    Mode 2: disables the input and disables offsets. Just outputs programmed sample buffer. 

Each of these modes has a "loading" bit.

Note that there is this "problem" with there only being one acqboard interface but two DSPs. this means channel modification commands have to be very careful!!!







--------------------------------------------------------------------------
So, general system properties, etc: 

AD8221 has amazing stuff... the new data sheet is an inspiration to all of humanity!

--------------------------------------------------------------------------
AA Filter component value selection:
--------------------------------------------------------------------------

For the LTC1653-3, the equation is:
R = 10k * (256kHz)/Fc; 

from the dsp folder:

The first filter has a -3 db at 10056.32 Hz
The second filter has a -3 db at 29829.14 Hz
The combined (both) filter has a -3 db at 9605.82 Hz
The combined (both) filter has a -96 db at 129371.07 Hz

We assume that their Fc == -3 dB point, thus 
The LTC1563-3 Resistors are 255k , part 9C08052A2553FKHFT from digikey




---------------------------------------------------------------------------
input stage
---------------------------------------------------------------------------
499 0hm .5% \0805 resistors, RR12P499DCT-ND from digikey
