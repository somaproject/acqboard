#!/usr/bin/python
"""
Code to simulate acqboard filtering in python, including extended-precision accumulator and convergent rounding.

This is in no way optimized for speed. 

rmac(x, h, precision):
   returns x * h based on our internal model
   does not downsample
   assumes bipolar input
   the inputs are lists of class fixed
   it keeps

overf(y, a, b):
   returns a vector that doesn't overflow an a.b number

"""

from fixed import * 

def rmac(x, h, precision):
    
    #We pad the input vector with len(h) zeros to make the convolution easier
    xbase = x[0].base
    xz = []
    for i in range(len(h)):
        xz.append(fixed(0, xbase))

    x = xz + x + xz

    y = []
    for xpos in range(len(h),  len(x)):
        
        sum = fixed(0,precision)
    
        for k in range(len(h)):
            yn =  h[k] * x[xpos - k]
            sum += yn.convrnd(precision)
        y.append(sum)

    return y

def overf(y, a):
    #
    yo = []
    for i in y:
        yo.append(i.overf(a))

    return yo

def convrnd(y, a):
    yo = []
    for i in y :
        yo.append(i.convrnd(a))
    return yo 


def main():
    # simple test:
    x = [fixed(2**15, 16), fixed(2**14, 16), fixed(2**15, 16)]
    h = [fixed(2**21, 22), fixed(2**21, 22), fixed(0, 22)]

    print rmac(x, h, 24)
    
    x = [fixed(2**17, 16), fixed(2**15, 16), fixed(2**15, 16)]
    h = [fixed(2**21, 22), fixed(2**21, 22), fixed(2**21, 22)]

    y = rmac(x, h, 24)
    print y
    print  "test"
    print overf(convrnd(y, 16), 1)    
if __name__ == "__main__":
    main()
    
