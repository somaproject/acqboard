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
So, general system properties, etc: 

AD8221 has amazing stuff... the new data sheet is an inspiration to all of humanity!
