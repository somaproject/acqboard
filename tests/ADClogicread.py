#!/usr/bin/python
"""

Simple script to read the output of the logic analyzer, trying to decode the output of the SPI-esque bus

NOTE THAT THIS CODE ASSUMES:

Bit zero: ADCCS
Bit one : SCLK
bit two : SDIN


"""
ADCCS = 10
SCLK = 11
SDIN = 12

from matplotlib.pylab import *

def getbit(val, pos):
    return  ( val >> pos) % 2


def readdbit(reader):
    while( getbit(int(reader.next()[1]), SCLK) == 0):
        pass
    rbits = int(reader.next()[1])
    while( getbit(rbits,SCLK) == 1):
        rbits =int(reader.next()[1])

    return getbit(rbits, SDIN)
    
def readsamp(reader):
    x = 0
    f = 32768;
    
    for i in range(16):
        s = readdbit(reader)
        if s == 1 :
            x += f
        f = f /  2
        
    return x

import csv
reader = csv.reader(file("default.csv"))

samplea = []
sampleb = []
try:
    while(1):
        x = reader.next()
        if getbit(int(x[1]), ADCCS)  == 1 :
            # high edge
            while( getbit(int(reader.next()[1]), ADCCS) == 1):
                pass
            samplea.append(readsamp(reader))
            sampleb.append(readsamp(reader))
        
except StopIteration:
    
    plot(sampleb)
    show()
    
