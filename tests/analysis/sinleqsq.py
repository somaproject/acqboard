#!/usr/bin/python
"""
Attempt to use least squares to fit a sinusoid to our input data


We use the example in the scipy tutorial with

yi = A sin (2*pi*k*xi +theta)



"""
from scipy import *
#from pylab import * 
import gologicread

def residuals(p, y, x):
    A, k, theta, os = p
    
    err = y - (A*sin(2*pi*k*x+theta)+os)
    return err

def peval(x, p):
    return p[0]*sin(2*pi*p[1]*x + p[2]) + p[3]


def findlsq(p0, x, t):
    """
    attempt to fit a sine with three variable parameters to x in a
    least-squarese sense

    p = [Amplitude, frequency, phase]
    
    """

    plsq = optimize.leastsq(residuals, p0, args=(x, t))

    return plsq

    
def main():
    RN = 100000
    fs = 32e6/161
    xin = gologicread.serial(sys.argv[1]);
    

    
    xin = array(xin)/32768.0 - 1.0
    hlen = 120 
    #h = signal.remez(hlen, r_[0, 0.1, 0.15, 0.5], r_[1.0, 0.0])
    #xh = signal.convolve(h, xin)
    #x = xh[hlen:(RN-hlen)]
    x = xin[100:]
    
    # phase calculation
    print "mean = ", mean(x)
    
    p0 = [max(x)-min(x), float(sys.argv[2]),  sys.argv[3], mean(x)];

    t = r_[0.0:len(x)]/fs

    plsq = findlsq(p0, x, t);

    p = plsq[0]
    
    xprime = peval(t, p);

    print "amplitude = %0.10f" % p[0]
    print "frequency = %0.10f" % p[1]
    print "phase     = %0.10f" % p[2]
    print "offset    = %0.10f" % p[3]

    err = (xprime - x)**2; 
    print "Error is %0.20f " % mean(err)

    rmsnoise = sqrt(sum(err)/len(x))

    rmssignal = abs(p[0])/sqrt(2)

    print rmssignal, rmsnoise
    print "THD+N = %0.3f" % (20*log10(rmsnoise/rmssignal))
    
    ENOB = log2(2/(rmsnoise*sqrt(12)))
    print "ENOB = %0.5f" % ENOB

    errreal = xprime -x
    #plot(x[:10000])
    #plot(xprime[:10000])
    #plot(errreal[:10000] * 1e4)
    #show()
    #hist(errreal[:10000])
    #show()
if __name__ == "__main__":
    main()
