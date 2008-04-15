#!/usr/bin/python
import numpy as n
import pylab

def increasing(offset):
    N = 256
    x = n.arange(0, N-1, dtype=n.int16)

    return x + offset

def impulse():
    N = 256
    x = n.zeros(N, dtype=n.int16)
    x[0] = 2**15-1

    return x

def sine(freq):

    fs = 32000.
    N = 256
    t = n.arange(0, N-1, dtype=n.float)/ fs
    x = n.sin( t * fs * freq * 2 * 3.1415)
    # conversion
    y=  (x * 32767).astype(n.int16)
         
    
    return y
    
def impulsefilter():
    x = n.zeros(256, dtype=n.int32)
    x[0] = 2**21-1
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
writesamp("sine.samp", sine(100))

writesamp("impulse.firdat", impulsefilter())
writesamp("ramp.firdat", rampfilter())
writesamp("pattern.firdat", patternfilter())
