from scipy import *
import numpy as n
import pylab



import tables

def pgram(x, M = None, wlen = None):
    N = len(x)
    if M != None:
        L = int(N/(M + 1))
    else:
        # assume wlen defined
        M = N / wlen + 1 
        L = wlen/2
        
    sums = n.zeros(L, dtype=Float)
    #print "Using a window length of ", L , M, "of them" 
    for i in range(M):
        xF = signal.fft(x[i*L : (i+2)*L])

        xF2 = (abs(xF[:L]))**2
        sums += xF2

    wavg = sums / (M)

    return wavg / (2*L**2)


def demo():
    fs = 32000.0
    stddv = 1.0

    normgen = stats.norm(scale=stddv)
    N = 2**22
    x = normgen.rvs(N)

    p = pgram(x, wlen = 64)
    pylab.plot(p)
    pylab.show()
    print sum(p)

noisefile = tables.openFile('/tmp/board.05.noise.h5')

chans = ['A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4']
gains = [100, 1000, 10000]
ws = n.zeros((len(chans), 128), Float)
fs = 32000
N = 256
freqs = n.arange(0, N/2, dtype=Float) / (N) * fs

gc = {100: 'r', 1000: 'g', 10000: 'b'}

for gain in gains:
    for i, c in enumerate(chans):        
        table = noisefile.root._v_children[c].noise.hpf1

        for row in table.where(table.cols.gain == gain):


            x = n.array(row['data'], Float) / row['gain']
            
            xm = x - x.mean()
            w = pgram(xm, wlen = N)
            ws[i] = w

    print len(ws.mean(0)), len(freqs)
    
    pylab.plot(freqs[1:], ws.mean(0)[1:], gc[gain] ,
               label = "g = " +  str(gain) )

pylab.legend()
pylab.xlabel('Frequency (Hz)')
pylab.ylabel('Noise power')
pylab.grid(1)
pylab.title("Noise Power Spectral Density, HPF enabled") 
pylab.show()

for gain in gains:
    for i, c in enumerate(chans):        
        table = noisefile.root._v_children[c].noise.hpf0

        for row in table.where(table.cols.gain == gain):

            
            x = n.array(row['data'], Float) / row['gain']
            xm = x - x.mean()

            w = pgram(xm, wlen = N)
            ws[i] = w

    pylab.plot(freqs[1:], ws.mean(0)[1:], gc[gain],
                label = "g = " +  str(gain))
pylab.legend()

#leg = pylab.gca().get_legend()
#ltext  = leg.get_texts()  # all the text.Text instance in the legend

#pylab.setp(ltext, fontsize='xx-small')    # the legend text fontsize


pylab.xlabel('Frequency (Hz)')
pylab.ylabel('Noise power')
pylab.grid(1)
pylab.title("Noise Power Spectral Density, HPF disabled") 
pylab.show()
