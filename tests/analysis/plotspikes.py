import readacq
from scipy import *
from matplotlib import pylab


n = 100000
fs = 32000.
f = readacq.RegFile("/home/jonas/rat.2005.12.05.dat", 0)
x = array(f.read(n), Float32)
y = x/2**15 * (4.096/10000)
yuv = y *1e6
t = r_[0:(n/fs):(1/fs)]*1000
pylab.plot(t, yuv)
pylab.ylabel("volts (uV)")
pylab.xlabel('time (ms)')
pylab.grid(1)
pylab.show()
