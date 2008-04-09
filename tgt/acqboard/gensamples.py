#!/usr/bin/python
import numpy as n
import pylab

def increasing(offset):
    x = n.arange(0, 2047, dtype=n.int16)

    return x + offset

def impulse():
    x = n.zeros(2048, dtype=n.int16)
    x[0] = 2**15-1

    return x

def sine(freq):

    fs = 32000.
    N = 2048
    t = n.arange(0, N-1, dtype=n.float)/ fs
    x = n.sin( t * fs * freq * 2 * 3.1415)
    pylab.plot(x)
    pylab.show()
    # conversion
    y=  (x * 32767).astype(n.int16)
         
    
    return y
    
    

def writesamp(filename, data):

    fid = file(filename, 'w')
    for i in data:
        fid.write("%d\n" % i)


writesamp("sequential.samp", increasing(0))
writesamp("impulse.samp", impulse())
writesamp("sine.samp", sine(100))


