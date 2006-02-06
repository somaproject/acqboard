#!/usr/bin/python
"""


Compute and plot various analytic measurements of acqboard performance




"""

import sys
from tables import *
from scipy import *
from pylab import *

import raw
import thdn

def plotTHDN():
    """
    Plot the thd+N as a function of frequency
    """

    filename = sys.argv[2]
    
    h5file = openFile(filename)
    table =  h5file.root.A1.sine.La2

    for i in table.iterrows():
        f = i['frequency']
        data = i['data']/32768.0
        #plot(r_[data[2**16-100:2**16], data[0:100]])
        #show()
        dbar = mean(data)
        
        print f, thdn.calcTHDN(f, 256000, data-dbar)
        
    
def freqres(filename):
    h5file = openFile(filename)
    table =  h5file.root.A1.sine.La2
    
    dlen = 2**14
    t = r_[0:dlen]/256000.0
    s = sin(t*2*pi*1000);
    maxpower = sqrt(sum(s**2))
    
    freqs = []
    power = []

    for i in table.iterrows():
        f = i['frequency']
        data = i['data'][0:dlen]/32768.0
        xbar = mean(data)
        rmspower = sqrt(sum((data-xbar)**2))
        freqs.append(f)
        power.append(rmspower/maxpower)
        
    semilogx(freqs, 20*log10(power))
        #plot(i['data'])
    grid(1)
    xlabel('Frequency (Hz)')
    ylabel('dB')

    show()



if __name__ == "__main__":
    if sys.argv[1] == "freqres":
        pass
    elif sys.argv[1] == "thdn":
        plotTHDN()
