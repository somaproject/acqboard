from scipy import *
from pylab import * 

def iirnotch(wc, bw):
    """ generate a basic notch filter.
        see filttest()
        
    """
    Ab = abs(10*log10(.5))
    bwnorm = bw*pi
    wcnorm = wc*pi
    
    Gb   = 10**(-Ab/20.0)
    beta = (sqrt(1-Gb**2)/Gb)*tan(bwnorm/2)
    gain = 1/(1+beta);

    num  = gain*r_[1, -2*cos(wcnorm), 1]
    den  = r_[1, -2*gain*cos(wcnorm), (2*gain-1)]
    return (num, den)


def notchfilt(fsig, fs, x):
    # filter the vector x at sample rate fs to get rid of fsig

    wc = fsig/(float(fs)/2)
    bw = wc / 30.0
    (b, a) = iirnotch(wc, bw)
    return signal.lfilter(b,a,x)

def calcTHDN(fsig, fs, x):
    """
    We compute the THD+N by using a second-order notch filter to remove the
    primary component.

    Since the filter is IIR, we initially assume initial rest, and then
    filter over and over again using the final values from the previous
    iteration as the initial conditions for the next.
    
    """

    wc = fsig/(fs/2); bw = wc/20;
    (b, a) =  iirnotch(wc, bw)

    
    y = signal.lfilter(b, a, x)
    szi = signal.lfiltic(b, a, y, x)
    for i in range(10):
        (y, zf) = signal.lfilter(b, a, x, zi=szi)
        szi = zf

    
    

    t = r_[0:len(x)]/float(fs)
    
    fakesine = sin(fsig*2*pi*t)
    #x = fakesine
    
    suby = y[(len(y)/2):len(y)]
    subx = x[(len(x)/2):len(x)]
    print sum(subx**2), sum(suby**2)
    ypow = sqrt(sum(suby**2)/len(suby))
    xpow = sqrt(sum(subx**2)/len(subx))
    

    return 20*log10(ypow/(xpow-ypow))


def filttest():

    fs = 256000.0
    xlen = 1.0
    nrecord = 2**16
    
    t = cast['d'](r_[0:nrecord]/fs)
    
    # 10khz sine
    f = fs * 1000/nrecord
    print f

    snrs = []
    for bits in r_[20:8:-1]:
        x = sin(2*pi*f*t)*2**(bits -1)
        x2 = round(x)/2**(bits -1)
        snrs.append(calcTHDN(f, fs, x2))
    print snrs
        
    snrd = []
    for i in range(len(snrs)-1):
         snrd.append(snrs[i] - snrs[i+1])
         
    print mean(snrd)
    
    
if __name__ == "__main__":
    filttest()
