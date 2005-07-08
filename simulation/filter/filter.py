"""





"""

import sys
from scipy import *
from pylab import * 


N = 6 # N is downsample factor


DDELAY = 150
    # how far into the signal the impuls is, in INSAMPLE ticks
    


def verify(simname):

    siglen = 200 
    simfid = file("%s.simoutput.dat" % simname)
    simout = io.read_array(simfid, lines=((0, siglen*N),))

    fid = file("%s.output.dat" % simname)
    out = io.read_array(fid, lines=((1, siglen+1),))

    print simout.shape
    shifts = []
    for chan in range(10):
        maxos = 0
        shift = 0
        os = 0
        for i in range(N):
            ysim = simout[i:(320+i):N]

            offset = []
            # then we try 10 shifts back:
            for j in range(5):

                offset.append(
                    sum( r_[zeros(j), out[0:(54-j),chan]]
                         * ysim[:, chan]))

            # forward
            for j in range(1, 6 ):
                offset.append( sum(out[j:(54+j), chan] *  ysim[:, chan]))

            if max(offset) > maxos:
                maxos = max(offset)
                shift = i
                os = argmax(offset)

        print os, maxos, shift
        shifts.append(shift)

    chan = 0
    
    shiftedout = simout[shifts[chan]:(siglen*N):N, chan]
    print shiftedout.shape
    print out.shape
    outchan = out[:len(shiftedout), chan]
    print outchan.shape
    #plot (shiftedout - outchan)
    plot (outchan)
    #plot(out[0:1000, chan])
    
    #print len(simout[shifts[chan]:((siglen-1)*8):8, chan]),
    #len(out[0:siglen, chan])
    #plot((simout[shifts[chan]:((siglen-1)*N):N, chan] - out[0:siglen, chan])*1000)
    #plot(simout[:, chan])
    show()
    
    #show()
    

def main():
    
    verify("basic")


if __name__ == "__main__":
    main()
    
