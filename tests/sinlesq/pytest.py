import sinlesq
from Numeric import *
from scipy import *
from matplotlib import pylab

def quant(x, bits):
    return round(x*(2**(bits-1)))/2**(bits-1)



fs = 32000.
#x = io.read_array('/home/jonas/adtest.dat')
#y = array(x, Float64); 
t = r_[0:1:(1/fs)]

n = array(randn(len(t))/2**14)


fc = 300
(b, a) = signal.bessel(1, fc/fs, btype='high')
print b, a
bits = 16

thdnf = []
thdn = []
wl =  r_[20:1000:50]
for w in wl:

    x = sin(w*t * pi * 2)
    y = x + n
    q = signal.lfilter(b, a, y)

    z = quant(q, bits)
    zu = quant(y, bits)
    thdn.append(sinlesq.computeTHDN(zu[2**10:], fs))
    thdnf.append(sinlesq.computeTHDN(z[2**10:], fs))


pylab.plot(wl, thdn, label = "unfiltered")
pylab.plot(wl, thdnf, label = 'filtered')
pylab.grid(True)
pylab.legend()
pylab.show()
