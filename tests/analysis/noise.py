
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
import numpy as n

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
        #rms = sqrt(mean(xvnormed**2))
        rms = std(xv)

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

def generateNoiseTable(h5file):
    """ tenerates a table of noises at each gain across
    channels, one for hpf=1 and one for hpf=0
    """

    chans = ['A2']
    gains = {100:0, 200:1,
             500:2, 1000:3,  2000:4, 5000:5, 10000:6}

    hpf0noises = n.empty((len(chans), len(gains)), Float)
    hpf1noises = n.empty((len(chans), len(gains)), Float)
    
    for i, c in enumerate(chans):
        changroup = t.root._v_children[c].noise
        

        (g, noise) = tableRMSNoise(changroup.hpf0)

        # insert into array
        for j, ga in enumerate(g):
            hpf0noises[i][gains[ga]] =  noise[j]

        (g, noise) = tableRMSNoise(changroup.hpf1)
        for j, ga in enumerate(g):
            hpf1noises[i][gains[ga]] =  noise[j]
        

    glist = []
    for i in range(7):
        for k, v in gains.iteritems():
            if v == i:
                glist.append(str(k))
    
    p0 = pylab.bar(n.arange(0, 7), hpf0noises.mean(0) * 1e6,
              yerr = hpf0noises.std(0) * 1e6,
              width = 0.35, color = 'g')
    p1 = pylab.bar(n.arange(0, 7) + 0.4, hpf1noises.mean(0) * 1e6,
              yerr = hpf0noises.std(0) * 1e6,
              width = 0.35, color='b')
    pylab.xticks(n.arange(0, 7) + 0.30, glist)

    pylab.legend((p0[0], p1[0]), ('HPF disabled', 'HPF enabled'))

    pylab.xlabel('gain')
    pylab.ylabel('RMS Noise (uV)')
    pylab.title('Voltage noise RMS RTI averaged across channels')
    pylab.show()
    

def plotAllNoise(filename):
    f = tables.openFile(filename)

    for t in f.walkNodes('/', 'Table'):

        (g, noise) = tableRMSNoise(t)

        pylab.plot(g, noise * 1e6, label = t._v_pathname)
        


    pylab.xlabel("gain")
    pylab.ylabel("Noise RMS (uV)")
    pylab.legend()
    pylab.grid()
    pylab.show()
    

if __name__ == "__main__":
    #plotAllNoise(sys.argv[1])
    t = tables.openFile(sys.argv[1])
    generateNoiseTable(t)
    
