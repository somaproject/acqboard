#!/usr/bin/python
"""
Simple filter to take in a file name and returns an array of of data. Just a simple function to handle the reading of the output fromthe adcqboard.raw 


"""

from scipy import *
from matplotlib.matlab import *

def periodogram(x, window, fftlen) :
    y = x * window;
    V = fft(y, fftlen);
    L = len(window);
    U = 1.0/L*sum(window**2)
    
    return (1/(2*pi*L*U)*(abs(V)**2))

def hanning(N):
    #Returns a hanning window, except for the two zeros on the ends
    
    return cos(r_[-(N/2-.5):(N/2+.5)]/(N+1.0)*pi)**2

import sys

l = 100000


fid = file('20040630.raw.sine.dat', 'rb')
g=io.fread(fid, l*12, 's', 's', 1)

x=zeros((l+1)*8)

for i in range(l-2):
    for j in range(8):
        x[i*8+j] =  g[i*12+j+10]
print len(x)


plot(10*log10(periodogram(x, hanning(len(x)), 1024)))
show()
