#!/usr/bin/python
from scipy import * 
import sinleqsq
import thdn_notch
import readacq
import pylab

def rawTHDN():

    fid = readacq.RawFile('/home/jonas/test.dat')
    fs = 192000.0
    x = fid.read(1000)
    x = fid.read(100000)
    xr = x/32768.0

    fftlen = 2**17;

    # code to figure out the center frequency
    fsamps = linspace(0, fs, fftlen)
    fvals =  abs(fft(xr, n=fftlen))
    f =  fsamps[argmax(fvals)]
    
    xfiltered = sinleqsq.lpf(xr, 200, f, fs)
    print "Unfiltered: "

    sinleqsq.measureTHDN(xr, fs, freq=f, phase=0.0)
    print "Filtered:" 
    sinleqsq.measureTHDN(xfiltered, fs, freq=f, phase=0.0)
    



if __name__ == "__main__":
    rawTHDN()
    
