#!/usr/bin/python
import random

import sys
import math

def to_16bit(x):
    x = int(round(x*(2**16-1)))
    return x

# First impulse to determine relative delay and 
vlen = 10000; 

for r in range(5):
    f = open("basic.adcin.%d.dat" % r, 'w')
    
    for i in range(150):
        f.write("32768 32768\n")
        
    f.write("32768 65535\n")
    f.write("65535 32768\n")

    for i in range(150):
        f.write("32768 32768\n")
        

    if r == 0:
        # first vector is random data
        for i in range(vlen):
            f.write("%d %d \n" % (random.randrange(0, 65535), random.randrange(0, 65535)))
    if r == 1:
        for i in range(vlen):
            # next data is 1 kHz sine
            x1 = math.sin(float(i)/256.0*2*math.pi)+1
            # 10 khz cosine
            x2 = math.cos(float(i)/25.6*2*math.pi)+1
            
            x1rnd = to_16bit(x1/2.0)
            x2rnd = to_16bit(x2/2.0)
        
            f.write("%d %d \n" % (x1rnd, x2rnd))

    if r == 2:
        #100 kHz and 128kHz (alternating)
        for i in range(vlen):
            x1 = math.sin(float(i)/2.560*2*math.pi)+1
            x1rnd = to_16bit(x1/2)
            x2 = (i % 2)*65535
            f.write("%d %d \n" %(x1rnd, x2));
            
    if r == 3:
        # sum and proudct of two freqs. 
        for i in range(vlen):
           x1 = math.sin(float(i)/256.0*2*math.pi)
            # 10 khz cosine
           x2 = math.cos(float(i)/25.6*2*math.pi)

           x1rnd = to_16bit((x1 + x2)/4.0+0.5)
           x2rnd = to_16bit((x1*x2)/2+0.5);
           f.write("%d %d \n" %(x1rnd, x2rnd));
           
    if r == 4 :
        for i in range(vlen):
            if i % 256 == 0 :
                x1 = 65535
            else:
                x1 = 32768

            if i % 256 < 128 :
                x2 = 65535
            else:
                x2 = 32768

            f.write("%d %d \n" %(x1, x2));
                    
    f.close()
                    
