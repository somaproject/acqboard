#!/usr/bin/python



from scipy import *
from pylab import *
import sys

"""
Generate 10 cycles over 1024 samples; roughly 1 kHz actual signal

"""


t = r_[0:1024]
t = t/1024.0

x = sin(t * 2 * pi * 10)*0.98

xrnd = round(x*2**15)

xes = []
for i in xrnd:
    xstr =  "%4.4X" % int(i)
    if len(xstr) > 4 :
        xstr = xstr[4:8]
        
    xes.append(xstr)

for i in range(32):
    sys.stdout.write("INIT_%02X => X\"" % i) 
    for j in range(16):
        sys.stdout.write(xes[i*16 + (15 - j)])
    sys.stdout.write("\",\n")
    sys.stdout.flush()
