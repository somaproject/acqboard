from scipy import *
from numpy import *
from matplotlib import pylab
import tables
import sinlesq
    
def residuals(p, y, t):  
    A, B, C, w  = p  
    err = y- (A*sin(w * t) + B*cos(w*t)+C)
    return err  
 
def peval(t, p):
    (A, B, C, w) = p
    return A*sin(w * t) + B*cos(w*t)+C


def computeTHDN(x, fs):
    
    t = arange(len(x), dtype=Float64)/fs
    x = x - mean(x)
    range = max(x) - min(x)

    n = 4096
    west = argmax(abs(fft(x, n))[:n/2]) / float(n)*2*pi * fs
    p0 = [range/2, range/2, 0.0, west] 

    plsq = optimize.leastsq(residuals, p0, args=(x, t), ftol=1e-12)  

    

    diff = x - peval(t,plsq[0])
    A, B, C, w = plsq[0]
    rmssignal = sqrt(A**2 + B**2)
    rmsnoise = sqrt(sum(diff**2)/len(diff))
    snrdb =  20*log10(rmssignal/rmsnoise)
        
    return (-snrdb, A, B, C, w)

def test():

    N = 50000
    fs = 32000.0 
    t = arange(N).astype(Float64)/fs

    A, B, C, w = 1/sqrt(2.), 1/sqrt(2.), 0.00, pi/6*100.0
    scale = 0.98

    y_true =( A*sin(w * t) + B*cos(w*t)+C)*scale

    bits = 16

    y_rnd = (round_(y_true*2**(bits-1)))
    print max(y_rnd), min(y_rnd)
    y_meas = y_rnd / (2**(bits -1))

    (snrdb, A, B, C, w) = computeTHDN(y_meas, fs)

    ENOB  = (snrdb-1.76)/6.02

    print "SNR = %f dB, ENOB = %3.2f" % (snrdb, ENOB)


def test1():

    f = tables.openFile('/tmp/test.02.h5')
    x = f.root.B1.gain100.hpf1.sine[3][0]
    y=x.astype(Float64)/2**15

    print computeTHDN(y, 32000.0)

    
if __name__ == "__main__":
    test1()
