"""





"""

import sys
sys.path.append("../../code")
import filt
from fixed import *

def verify(simname):

    xu = []
    # read in the ADCs:
    for i in range(5):
        xun1 = []
        xun2 = []
        fid = file("%s.adcin.%d.dat" % (simname, i))

        for l in fid.readlines():
            (s1, s2) = l.split()
            xun1.append(int(s1))
            xun2.append(int(s2))

        xu.append(xun1)
        xu.append(xun2)

    print "converting to fixed, bipolar"
    # now convert to fixed, bipolar
    x = []
    for chan in range(10):
        xn = []
        print "hah" 
        for i in range(len(xu[chan])):
            xn.append(fixed(xu[chan][i]-2**15, 16))

        x.append(xn)

    print "reading in filter"
    # read in the filter:
    h = []
    fid = file("%s.filter.dat" % simname)
    for i in fid.readlines():
        h.append(fixed(long(i), 22))

        
    # compute the ys
    y = []
    yraw = []
    yrnd = []
    for xi in x:
        print "rmacing"
        y_raw = filt.rmac(xi, h, 24)
        yraw.append(y_raw)
        print "convrnding"
        y_rnd = filt.convrnd(y_raw, 16)

        yrnd.append(y_rnd)

        y_overf = filt.overf(y_rnd, 1)

        y.append(y_overf)

    # at this point we should have the covolved, NOT DOWNSAMPLED ys


def main():
    
    verify("basic")


if __name__ == "__main__":
    main()
    
