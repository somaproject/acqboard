#!/usr/bin/python

"""
Basic code to read the output of the ATS




"""

from scipy import *
from matplotlib.matlab import * 
import sys


def read2(filename):
    fid = file(filename)
    fid.readline()
    fid.readline()
    fid.readline()
    fid.readline()
    
    return io.read_array(fid, ",", (0, 1))
    
def read3(filename):
    fid = file(filename)
    fid.readline()
    fid.readline()
    fid.readline()
    fid.readline()
    
    return io.read_array(fid, ",", (0, 1, 2, 3))
    



if __name__ == "__main__":
    if sys.argv[1] == "freqres":
        x = read2(sys.argv[2])
        plot(log10(x[:,0]), x[:,1])

        minx = min(x[:,0])
        maxx = max(x[:,0])
        miny = min(x[:,1])*.9
        maxy = max(x[:,1])*1.02
        print minx, maxx
        print miny, maxy
        axis([log10(minx), log10(maxx), miny, maxy])

        grid(1)

        r = logspace(log10(minx), log10(maxx), 8)

        ticks = []
        for i in r:
            ticks.append("%3.0f" % i)

        xticks(log10(r), ticks, fontsize=10 )
        title("Frequency Response")
        xlabel("Frequency (Hz)")
        ylabel("signal power (dB)")
        show()

    elif sys.argv[1] == "thdn":
        x = read3(sys.argv[2])
        print x[:,2]
        
        plot(log10(x[:,0]), x[:,1])
        plot(log10(x[:,0]), x[:,2])

        axis([log10(20), log10(20000), -120, -60])
        r = logspace(log10(20), log10(20000), 10)

        ticks = []
        for i in r:
            ticks.append("%3.0f" % i)

        xticks(log10(r), ticks, fontsize=10 )
        grid(1)

        title("THD+N")
        xlabel("Frequency (Hz)")
        ylabel("ratio (dB)")
        legend(("2nd+3rd", "All"))
               
        
        show()

    elif sys.argv[1] == "alin":
        # this option takes in a number of linearity measurements

        maxx = 0.0
        minx = 100000.0

        titles = []
        for i in sys.argv[2:]:
            x = read2(i)
            titles.append(i)
            xm = mean(x[:, 1])
            plot(log10(x[:, 0]), x[:,1]-xm)

        r = logspace(log10(min(x[:,0])), log10(max(x[:,0])), 10)

        ticks = []
        for i in r:
            ticks.append("%3.2f" % (i*1000.0))

        xticks(log10(r), ticks, fontsize=10 )
        grid(1)

        legend(titles)
        title("Amplitude linearity")
        xlabel("input voltage (mV)")
        ylabel("normalized gain (dB)")
        show()
