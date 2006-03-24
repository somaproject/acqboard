
import sys
import scipy
from scipy import *
import tables
#import sinleqsq
import pylab
import sinleqsq as pysinlesq
sys.path.append("../sinlesq/")
import sinlesq as csinlesq
from matplotlib.ticker import FormatStrFormatter


def nvNoisePgram(x, fs, wlen, N = 2**12):
    """
    assumes that x is a float vector of voltage measurements

    fs is sampling rate in hz
    
    Returns a list of the real sampling frequencies
    and the noise spectrum in nv/rt htz

    normalizes x first by removing the mean

    """
    
    xws = x.reshape(wlen, -1)

    sgs = empty((len(xws), N), dtype=Float)

    for i in range(len(xws)):
        f = signal.fft(xws[i] - mean(xws[i]), N)
        sgs[i] = abs(f)**2


    meanspec = mean(sgs)

    fsp = meanspec[:(N/2)]

    freqs = arange(N/2, dtype=Float) / N * fs

    return  fsp.astype(Float), freqs

def tableNoiseSpectra(table, fs):
    """
    takes in a table and returns
    a noise spectrum for each row

    freq should be constant across all 
    """

    N = 2**12
    
    gains = empty(len(table))
    specs = empty((len(table),N/2) , dtype=Float)
    
    for i in range(len(table)):
        r = table[i] 
        x = array(r['data'], Float64)
        xv = x * 4.096/2**16/r['gain']
        xvnormed = xv - mean(xv) 

        
    
        gains[i] = r['gain']

        (spec, freq) = nvNoisePgram(xvnormed, fs, 64,  N)
        specs[i] = spec
        
    return freq, gains, specs

    

def measureNoise(filename):
    """ Measuring noise is not an easy thing to do; what should
    we be actually looking at? how do we control for gains? 


    
    """
    f = tables.openFile(filename)

    (g1, nb1, nv1, rv1, bstd1) = getNoise(f.root.B1.noise.hpf0)
    (g2, nb2, nv2, rv2, bstd2) = getNoise(f.root.B1.noise.hpf1)
    
    print g1, nv1
    
    pylab.scatter(g1, rv1*1e6, c='r')
    pylab.plot(g1, rv1*1e6, c='r')
    
    pylab.scatter(g2, rv2*1e6, c='b')
    pylab.plot(g2, rv2*1e6, c='b')

    
    pylab.xlabel('gain')
    pylab.ylabel('uV RMS')

    pylab.figure(2)
    pylab.scatter(g1, bstd1, c='r')
    pylab.plot(g1, bstd1, c='r')


    pylab.scatter(g2, bstd2, c='b')
    pylab.plot(g2, bstd2, c='b')

    
    pylab.xlabel('gain')
    pylab.ylabel('bit std dev')

def tableRMSNoise(table):
    # takes in a table of noise data  and returns an array
    # of (gains, rmsnoise) 

    gains = empty(len(table))
    rmsnoise = empty(len(table), dtype=Float64)
    
    for i in range(len(table)):
        r = table[i] 
        x = array(r['data'], Float64)
        xv = x * 4.096/2**16/r['gain']
        xvnormed = xv - mean(xv) 
        
        rms = sqrt(mean(xv**2))


        gains[i] = r['gain']
        rmsnoise[i] = rms
    return gains, rmsnoise

    
    
def plotTableNoise(tables, prefix = "" ):

    for t in tables:
        (g, noise) = tableRMSNoise(t)

        pylab.semilogy(g, noise * 1e6, label = name)

    pylab.xlabel("gain")
    pylab.ylabel("Noise RMS (uV)")
    pylab.legend()
    pylab.grid()

    

def plotAllNoise(filename):
    f = tables.openFile(filename)

    for t in f.walkNodes('/', 'Table'):

        (g, noise) = tableRMSNoise(t)

        pylab.semilogy(g, noise * 1e6, label = t._v_pathname)
        


    pylab.xlabel("gain")
    pylab.ylabel("Noise RMS (uV)")
    pylab.legend()
    pylab.grid()
    pylab.show()
    

if __name__ == "__main__":
    plotAllNoise(sys.argv[1])
