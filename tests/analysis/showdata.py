#!/usr/bin/python
from matplotlib.matlab import *
from scipy import *


import readacq
from tables import *


def plotfft(source, location = None, entry = None):

    
    if isinstance( source, str):
        raw = readacq.RawFile(source)

        x = raw.read(2**16)/32768.0
    else :
        # HD5f data
        x = source[0:2**16]

    Fs = 256000
    phix = fft(x)

    normrealphix = abs(phix[0:(len(phix)/2)])**2 / max(abs(phix)**2)

    w = r_[0:2**15]/float(2**15) * (Fs/2)


    plot(w,10*log10(normrealphix), 'r')
    
    
    axis([ 0, 32000, -100, 1])
    xlabel('Frequency (Hz)')
    ylabel('Power (dB)')
    grid(1)
    
    show()

def showrawfft(sourceArray):

    
    x = sourceArray[0:2**16]

    Fs = 256000
    phix = fft(x)

    normrealphix = abs(phix[0:(len(phix)/2)])**2 / max(abs(phix)**2)

    w = r_[0:2**15]/float(2**15) * (Fs/2)


    plot(w,10*log10(normrealphix), 'r')
    
    
    axis([ 0, 32000, -100, 1])
    xlabel('Frequency (Hz)')
    ylabel('Power (dB)')
    grid(1)
    title('FFT chan %s in raw mode, F=%3.3f, amp=%2.5fVpp' % (sourceArray.attrs.rawchan, sourceArray.attrs.ffreq, sourceArray.attrs.famp))

    
    #text(0.5, 2.5, 'a line', font, color='k')
    show()

def rawnoiseplots(sourceArray):
    s = sourceArray[:2**13]
    plot(sourceArray[:2**13])
    print min(s)
    print max(s)
    srange = (max(s)-min(s))
    print srange
    axis([0, len(s), min(s)-0.05*srange, max(s)+1.1*(srange) ])

    # get out the gain

    changains = eval(sourceArray.attrs.gains)
    title('Noise with no input, channel %s, gain=%d' % (sourceArray.attrs.rawchan, changains[sourceArray.attrs.rawchan]))

    
    # this is an inset axes over the main axes
    a = axes([.55, .55, .3, .3], axisbg='#EEEEFF')
    n, bins, patches = hist(sourceArray[:], 400)
    
    title('Distribution')
    a.set_yticks([])
    a.set_xticks([ min(sourceArray[:])[0],
                   max(sourceArray[:])[0]
                   ])
    a.set_xticklabels([min(sourceArray[:]), 
                 max(sourceArray[:])])
    
    

    # this is another inset axes over the main axes
    a = axes([0.20, 0.55, .3, .3], axisbg='#EEEEFF')
    
    fftlen=2**16
    x = array(sourceArray[:fftlen], Float64)
    xnorm = x - mean(x)

    
    phi = abs(fft(xnorm/2**16))**2
    print(find(phi<= 0))
    phi[0] = mean(phi)
    plot(10*log10(phi[:(fftlen/2)]))
    ylabel('dB')
    title('Frequency Response')
    a.set_xticks([0, fftlen/2])
    a.set_xticklabels(['0', r"$\pi$"])
    show()


class bitstats:
    """ class which is constructed with an array of integers, and returns
    the statistics (as expected) for each bit in that array. We assume
    input values are twos-complement"""

    def __init__(self, x, bits):
        self.vals = x
        self.bits = bits
        for i in x:
            if i > (2**bits -1) or i < (-2**bits):
                print "%d is not in the %d-bit range!!" % (i, bits)
        self.bitsum = zeros(self.bits)

    def sum(self):
        
        for n in self.vals:
            for b in range(self.bits):
                if n & (2**b) != 0:
                    self.bitsum[b] += 1

        return self.bitsum

    def mean(self):
        return self.sum()/float(len(self.vals))

    def makebitarray(self):
        bitarray = zeros((self.bits, len(self.vals)))
        for i in range(len(self.vals)):
            for b in range(self.bits):
                if self.vals[i] & (2**b) != 0:
                    bitarray[b][i] = 1
        return bitarray

    def var(self):
        """ computes variance"""


        return stats.var(self.makebitarray)

        

                
    

import sys
def main():
    
    h5file = openFile("", "r")



if __name__ == "__main__":
    main()
