"""





"""

import sys
from scipy import *
from matplotlib.matlab import * 

def verify(simname):
    simfid = file("%s.simoutput.dat" % simname)
    simout = io.read_array(simfid, lines=((0, 1000),))

    fid = file("%s.output.dat" % simname)
    out = io.read_array(fid, lines=((1, 600),))

    print simout.shape

    yin = out[0:40, 0]
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

    #print dsoffset, max(dsoffset[:, 2])
    plot(simout[5:640:8, 0])
    plot(out[0:80, 0])
    plot((simout[5:640:8, 0]- out[0:80, 0])*1000)
    show()
    
    #show()
    

def main():
    
    verify("basic")


if __name__ == "__main__":
    main()
    
