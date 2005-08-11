#!/usr/bin/python


import os
import sys

from scipy import *
from matplotlib.pylab import *



def serial(filename):


    fid = file(filename)


    fid.readline()
    fid.readline()


    bits = []

    for line in fid.readlines():
        res = line.split()
        x = eval('0x' +  res[1])

        cnv = x % 2
        sclk = x/2 % 2
        din = x/8 % 2
        bits.append(( cnv, sclk, din))
        
    sum = 0
    bitpos = 1
    words = []
    for tick in bits:
        if tick[0] == 0:
            words.append(sum)
            sum = 0
            bitpos = 16
            
        else:
            if tick[1] ==1:
                sum += 2**(bitpos - 1) * tick[2]
                bitpos -= 1
    return words
if __name__ == "__main__":    serial()
