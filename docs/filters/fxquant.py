#!/usr/bin/python
"""
fixed-point quantization for a variety of schemes:

first, we create a quantization object :
    quant = fxquant(bit)

    then you quant(x) to quantize the coefficients in x

    

"""

from scipy import *

class fxquant:

    def __init__(self, bits):
        self.bits = bits


    def toInts(self, vect):
        rounded = zeros(vect.shape, Float)

        ints = zeros(vect.shape, Int32)
        
        for i in range(len(vect)):
            rounded[i] = vect[i] * 2**(self.bits-1)
            ints[i] = int(round(rounded[i]))

        return ints




def main():
    fx = fxquant(16)

    x = r_[-1, -0.5, 0.5, 32767/32768.0]
    print fx.toInts(x)


if __name__ == "__main__":
    main()
    


