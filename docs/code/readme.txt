
-- files in this directory
analogfilters.m : calculations and graphs of the analog filters on the board,
		 and combines them with an in-memory variable called "h", 
		 that is, the impulse response of the FIR decimating filter. 

fxquant.m : _so_ not my code. code to quantize the coefficients in an intelligent way. 
	  
vect_to_block_22 : takes a vector of type double normalized to between -1 and 1, quantizes the values to acceptable 22-bit twos-complement fixed point values, and then writes out those values in hex optimized for copying into blockselect+ ram. 


------------------------------------------------------------------------------
Signal processing related to the Soma acquisition board. 

First, we need a digital low-pass decimating filter which will (for data sampled at 256kHz) pass t400o 10 kHz with as little ripple as possible, and stop at 16 kHz down by ~85 dB. Why 85 db? The analog filters have already attenuated atthat point, and monotonically attenuate after that.  

Oh, and max it can only be 120 taps long. 


h_01.mat : good example of filter. 


for our analog filters, they are approximated by:

[bf2, af2] = besself(2, 38000);
[bf1, af1] = besself(4, 15250);

such that :

The first filter has a -3 db at 10056.32 Hz
The second filter has a -3 db at 29829.14 Hz
The combined (both) filter has a -3 db at 9605.82 Hz
The combined (both) filter has a -96 db at 129371.07 Hz

Using the equations fomr SLOA049A for a second-order bessel with:
order 2
FSF=1.2736
Q=.5773

we know R2=R1, thus the big variables are R2, R3, C1, and C2. 
Fc=1/(FSF*2*pi*Q*(R3*C1+R2*C1+R3*C1)); 
C2=(Q*(R3*C1+R2*C1+R3*C1))^2/(R2*R3*C1)
so (per the app note)


R2=1.870 k = R9 = R8
R3=1.870 k = R10
C1=1300 pF = C42
C2=3900 pf = C44




