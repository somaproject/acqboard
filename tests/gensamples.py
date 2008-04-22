#!/usr/bin/python
import numpy as n
import pylab

def increasing(offset):
    N = 256
    x = n.arange(0, N-1, dtype=n.int16)

    return x + offset

def const(offset):
    N = 256
    x = n.arange(0, N-1, dtype=n.int16)
    x[:] = offset
    return x

def impulse():
    N = 256
    x = n.zeros(N, dtype=n.int16)
    x[0] = 2**15-1

    return x

def sine(freq):

    fs = 32000.
    N = 256.0
    t = n.arange(0, fs, dtype=n.double) / fs
    t = t[:N]
    rt = t * freq * 2.0 * 3.141592
    x = n.sin( rt)

    y=  (x * 32767).astype(n.int16)
    z = n.zeros(200)
    dsx = x[::6]
        
    z[0:(len(dsx))] = dsx
    z[len(dsx):2*(len(dsx))] = dsx
    pylab.plot(z)
    pylab.grid(1)
    pylab.show()
    q = n.zeros(200)
    q[0:56] = y[200:]
    q[56:106] = y[:50]
    pylab.plot(q)
    pylab.show()
    return y
    
def impulsefilter(offset = 0):
    x = n.zeros(256, dtype=n.int32)
    x[offset] = 2**21-1
    return x

def patternfilter():
    x = n.zeros(143, dtype=n.int32)
    x[0] = 2**21-1
    x[1] = 2**21-1
    x[2] = 2**21-1
    x[3] = 2**21-1
    return x

def rampfilter():
    N = 144
    x = n.arange(0, N-1, dtype=n.float)/N
    
    y = x* 2**21-1
    return y.astype(n.int32)

def writesamp(filename, data):

    fid = file(filename, 'w')
    for i in data:
        fid.write("%d\n" % i)


writesamp("sequential.samp", increasing(0))
writesamp("impulse.samp", impulse())
#writesamp("sine.samp", sine(132))
writesamp("sine.samp", sine(125))
writesamp("const.samp", const(1))

writesamp("impulse.firdat", impulsefilter())
writesamp("impulse.0.firdat", impulsefilter(0))
writesamp("impulse.1.firdat", impulsefilter(1))
writesamp("impulse.2.firdat", impulsefilter(2))
writesamp("impulse.3.firdat", impulsefilter(3))
writesamp("impulse.4.firdat", impulsefilter(4))
writesamp("impulse.5.firdat", impulsefilter(5))
writesamp("ramp.firdat", rampfilter())
writesamp("pattern.firdat", patternfilter())
