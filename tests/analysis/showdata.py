#!/usr/bin/python

from scipy import *
from matplotlib.matlab import *

import readacq
from tables import *


def plotfft(source, location = None, entry = None):

    
    if isinstance( source, str):
        raw = readacq.RawFile(source)

        x = raw.read(2**16)/32768.0
    else :
        # HD5f data
        x = source['data'][0:2**16]

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


import sys
def main():
    
    h5file = openFile("../results/test.h5", "r")
    plotfft(h5file.root.raw.sineruns[0])


if __name__ == "__main__":
    main()
