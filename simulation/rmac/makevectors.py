#!/usr/bin/python


# simple code to make the buffers

from fixed import *
from random import *

class bufferset:

    def __init__(self):
        self.xfile = open("x.dat", 'w')
        self.xbase = open("xbase.dat", 'w')
        self.hfile = open("h.dat", 'w')
        self.yfile = open("y.dat", 'w')

    def add_vector(self, xvect, xbase, hvect, y):
        # note that all these values are expected to be ints
        for x in xvect :
            self.xfile.write("%d " % x.val)
        self.xfile.write("\n")

        for h in hvect :
            self.hfile.write("%d " % h.val)
        self.hfile.write("\n")

        self.xbase.write("%d \n" % xbase)
        self.yfile.write("%d \n" % y.val)
        print "len(xvect) = %d, len(hvect)= %d"% (len(xvect), len(hvect))

    def close(self):
        self.xfile.close()
        self.hfile.close()
        self.yfile.close()
        self.xbase.close()



def sim_rmac(x, h):
    # n is the precision.
    # assume x is 16-bit, h is 22 bit, fixed-point
    n = 26
    
    sum = fixed(0, 7+n);
    for i in range(144):
        p=  x[i]*h[i]
        q = p
        sum += p.trunc(n-1) # because of the way sum does things
        #print "%d : %d (p) = %d (x) * %d (h), truncated to %d" % (i, q.val, x[i].val, h[i].val, p.trunc(n).val)
        
        
    yrnd = sum.convrnd(15)

    ytrunk = yrnd
    if yrnd.val > 32767:
        ytrunk.val = 32767
    elif yrnd.val < -32768:
        ytrunk.val = -32768

    print "we have a sum %d, convrnd to %d, with trunk %d" %(sum.val, yrnd.val, ytrunk.val)    
    return ytrunk 


def xtobuf(x, xbase):
    # turns an array of x such that it can be read starting at xbase
    p  = x
    for i in range(256 - len(x)):
        p.append(fixed(0, 15))

    p.reverse()

    for i in range(xbase + 1):
        r = p.pop()
        p.insert(0, r)
    return p
        
    

x = []
h = []



# impulse and impulse
for i in range (256):
    x.append(fixed(0, 15))
    h.append(fixed(0,21))

x[0] = fixed(32767, 15)
h[0] = fixed(2097151, 21)

bufs = bufferset()

bufs.add_vector(x, 0, h, fixed(32767, 15))


# h[n] = 1-e, x[n] = lsb
# to check and make sure we're only MACing 120 times
for i in range (256):
    x[i] = fixed(1, 15)
    h[i] = fixed(2097151, 22)

bufs.add_vector(x, 0, h, fixed(144*1, 15))



# now, actual math checks:

############################################################################
# test extended precision of the accumulator:
############################################################################

for i in range(256) :
    x[i] = fixed(32767, 21)
for i in range (0, 79):
    h[i] = fixed(2097151, 21)
    
for i in range (71, 143):
    h[i] = fixed(-2097151, 21) # not -2097152 because 2s complement is asymmetric
    

bufs.add_vector(x, 0, h, fixed(0, 15))



for i in range(256) :
    x[i] = fixed(-32768, 15)
for i in range (0, 71):
    h[i] = fixed(2097151, 21)
    
for i in range (71, 143):
    h[i] = fixed(-2097151, 21) # not -2097152 because 2s complement is asymmetric
    

bufs.add_vector(x, 0, h, fixed(0, 15))



for i in range(256) :
    x[i] = fixed(32767, 15)
for i in range (0, 71):
    h[i] = fixed(2097151, 21)
    
for i in range (71, 143):
    h[i] = fixed(-2097152, 21) 
    

bufs.add_vector(x, 0, h, fixed(-1, 15)) #slightly less than -1, but we have rounding power!

############################################################################
# CONVERGENT ROUNDING
############################################################################


for i in range (256):
    x[i] = fixed(0, 15)
    h[i] = fixed(0, 21)
    

x[0] = fixed(6, 15)
h[0] = fixed(1048576, 21)  #1/2
bufs.add_vector(x, 0, h, fixed(3, 15)) # no rounding


for i in range (256):
    x[i] = fixed(0, 15)
    h[i] = fixed(0, 21)
    

x[0] = fixed(3, 15)
h[0] = fixed(1048576, 21)  #1/2
bufs.add_vector(x, 0, h, fixed(2, 15)) # round up towards two


for i in range (256):
    x[i] = fixed(0, 15)
    h[i] = fixed(0, 21)

x[0] = fixed(5, 15)
h[0] = fixed(1048576, 21)  #1/2
bufs.add_vector(x, 0, h, fixed(2, 15)) #round down towards two


###########################################################################
# overflow detection
###########################################################################


#positive overflow
for i in range (256):
    x[i] = fixed(0, 15)
    h[i] = fixed(0, 21)

x[0] = fixed(32767, 15)
h[0] = fixed(2097151, 21)
bufs.add_vector(x, 0, h, fixed(32767, 15)) # equals

x[255] = fixed(1, 15)
h[1] = fixed(2097151, 21)
bufs.add_vector(x, 0, h, fixed(32767, 15)) # won't overflow



for i in range (256):
    x[i] = fixed(0, 15)
    h[i] = fixed(0, 21)

x[0] = fixed( -32768, 15)
h[0] = fixed(2097151, 21)
bufs.add_vector(x, 0, h, fixed(-32768, 15)) # equals

x[255] = fixed(-1, 15)
h[1] = fixed(2097151, 21)
bufs.add_vector(x, 0, h, fixed(-32768, 15)) # won't overflow




#############################################################################
#simulated rmac
#############################################################################

for j in range(4000):

    x1 = []
    h1 = []
    for i in range(144):
        x1.append(fixed(randrange(-32768, 32767), 15))
        h1.append(fixed(randrange(-2097152/4, 2097151/4), 21)) # slightly smaller

    # pad out h1
    for i in range(256-144):
        h1.append(fixed(0, 21))
        
    y = sim_rmac(x1, h1)


    #print x1
    xbuf = xtobuf(x1, 0)
    #print xbuf
   

    bufs.add_vector(xbuf, 0, h1, y)

bufs.close()
