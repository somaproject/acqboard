#!/usr/bin/python
from matplotlib.matlab import *
from scipy import *


Fs = 256000.0
N=2**16
M=247
Ft = M*Fs/N

t = r_[0:1:1/Fs, Float64]

x = sin(2*pi*t*Ft)

print "The test freq is", Ft

xquant = around(x*(2**15), 0)/(2**15)
print xquant.shape
phi = abs(fft(xquant[0:N]))**2+1e-300
phinorm = phi/max(phi)
plot(10*log10(phinorm))
axis([0, N, -200, 100])
show()
