#!/usr/bin/python
"""

Simple script to read the output of the logic analyzer, trying to decode the output of the SPI-esque bus

NOTE THAT THIS CODE ASSUMES:

Bit zero: ADCCS
Bit one : SCLK
bit two : SDIN


"""

from matplotlib.matlab import *

def getbit(val, pos):
    return  ( val >> pos) % 2


def readdbit(reader):
    while( getbit(int(reader.next()[1]), 1) == 0):
        pass
    rbits = int(reader.next()[1])
    while( getbit(rbits,1) == 1):
        rbits =int(reader.next()[1])

    return getbit(rbits, 2)
    
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
        if int(x[1]) % 2 == 1 :
            # high edge
            while( getbit(int(reader.next()[1]), 0) == 1):
                pass
            samplea.append(readsamp(reader))
            sampleb.append(readsamp(reader))
        
except StopIteration:
    plot(sampleb)
    show()
    
