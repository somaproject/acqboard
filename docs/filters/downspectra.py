#!/usr/bin/python
"""
Takes in a FIR filter h and a downsampling factor n, and returns an object with:
   w : the frequencies it was evaluated at
   Ho : original part of signal
   Ha : aliased components

"""

from scipy import *

class downspectra :
    def __init__(self, h, n):
        self.h = h
        self.n = n

        wtot = 32768

        Yall = abs(fft(h, wtot))
        Yrng = wtot / 2
        

        Y = Yall[0:Yrng]
        Y.shape = (n, Yrng/n)
        self.Ho = 1/float(n)*Y[0, :]

        self.Ha = sum(Y[1:n, :])[::-1]/float(n-1)

        self.w = linspace(0, pi, Yrng/n)
        

def main():
    h = r_[1, 2, 3, 4, 5, 4, 3, 2, 1]
    ds = downspectra(h, 8)

   
if __name__ == "__main__":
    main()
    
