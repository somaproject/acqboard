#!/usr/bin/python


"""
code to run through some chunk of acquisition





"""


# for i in [channels]
# for j in [voltages]
# for f in [frequencies]
from ATSio.ATS import *
from scipy import * 
import time


def RawRuns():

    ats = ATS2()
    ats.mode = Modes.SINE
    ats.output = 'unbal'
    ats.onA = True
    for c in ['AC']:
        for v in r_[0.1:4.0:0.1]:

            ats.ampVppA = v
            
            for f in r_[100:12100:100]:
                print v, f
                ats.freq1 = f
                time.sleep(2)

if __name__ == "__main__":
    RawRuns()
