#!/usr/bin/python

from scipy import *
from matplotlib.matlab import *

import readacq

def plotmain():
    raw = readacq.RawFile('/home/jonas/test.dat')

    x = raw.read(2**16)/32768.0

    plot(x[0:1000])
    show()
    Fs = 256000
    phix = fft(x)

    print "The length is", len(phix)

    normrealphix = abs(phix[0:(len(phix)/2)])**2 / max(abs(phix)**2)

    w = r_[0:2**15]/float(2**15) * (Fs/2)

    print len(normrealphix), len(w)
    plot(w,10*log10 (normrealphix), 'r')
    
    
    axis([ 0, 10000, -100, 1])
    xlabel('Frequency (Hz)')
    ylabel('Power (dB)')
    grid(1)
    
    show()
    
def main():
    
    raw = readacq.RawFile('test.247.16.dat')

    x = raw.read(2**16)/32768.0

    fs = 256000 
    fftlen = 2**12
    n = fftlen * 2**4
    
    phi = periodogram.periodogram(x, windows.hanning(n), fftlen)
    print mean(phi)
    
    plot(r_[0:fs:(float(fs)/fftlen)] ,20*log10 (phi))
    
    grid(1)
    xlabel('Frequency (Hz)')
    ylabel('Power (dB)') 
    #axis([0, 128000, -100, 10])
    show()
    


if __name__ == "__main__":
    plotmain()
