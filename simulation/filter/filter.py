"""





"""

import sys
from scipy import *
from matplotlib.matlab import * 

def verify(simname):

    siglen = 200 
    simfid = file("%s.simoutput.dat" % simname)
    simout = io.read_array(simfid, lines=((0, siglen*8),))

    fid = file("%s.output.dat" % simname)
    out = io.read_array(fid, lines=((1, siglen),))

    print simout.shape
    shifts = []
    for chan in range(10):
        maxos = 0
        shift = 0
        os = 0
        for i in range(8):
            ysim = simout[i:(320+i):8]

            offset = []
            # then we try 10 shifts back:
            for j in range(5):
                offset.append(sum(r_[zeros(j),
                                     out[0:(40-j),chan]] * ysim[:, chan]))

            # forward
            for j in range(1, 6 ):
                offset.append( sum(out[j:(40+j), chan] *  ysim[:, chan]))

            if max(offset) > maxos:
                maxos = max(offset)
                shift = i
                os = argmax(offset)

        print os, maxos, shift
        shifts.append(shift)

    chan = 3
    
    plot(simout[shifts[chan]:(siglen*8):8, chan])
    plot(out[0:siglen, chan])
    #print len(simout[shifts[chan]:((siglen-1)*8):8, chan]),
    #len(out[0:siglen, chan])
    plot((simout[shifts[chan]:((siglen-1)*8):8, chan] - out[0:siglen, chan])*1000)
    #plot(simout[:, chan])
    show()
    
    #show()
    

def main():
    
    verify("basic")


if __name__ == "__main__":
    main()
    
