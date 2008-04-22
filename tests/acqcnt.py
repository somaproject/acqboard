#!/usr/bin/python
"""
Command-line interface to control the acqboard; should suck less than the GUI one

examples:
./acqboard mode 0
./acqboard filterload foo.firdat
./acqboard loadsamples foo.sampdat
./acqboard gain a1 100
./acqboard hpf a1 off
./acqboard 

"""


from struct import *
import os
import sys
sys.path.append("../../")
from acqboardcmd.acqboardcmd import AcqBoardCmd
from acqboardcmd import acqboard
import fiberdebug
import time

import random

class acqcnt:
    def __init__(self):
        self.acqcmd = AcqBoardCmd()

        self.abi = fiberdebug.AcqBoardInterface("10.0.0.2")

        self.gainSet = {0: 0,
                        1: 1,
                        2: 2,
                        5: 3,
                        10: 4,
                        20 : 5,
                        50 : 6,
                        100 : 7}
        
    def setMode(self,  mode, channel):
        acqcmdstr = self.acqcmd.switchmode(mode, rawchan=channel)
        self.abi.sendCommandAndBlock(self.acqcmd)        
                                 
        print "Board switched to mode", mode, " with channel", channel


    def setGain(self, chan, gain):
        newgain = self.gainSet[gain]
        acqcmdstr =  self.acqcmd.setgainnum(chan,
                                            newgain)
        self.abi.sendCommandAndBlock(self.acqcmd)        

        print "Channel ", chan, " gain set to " , gain

    def setHPF(self, chan, state):
        acqcmdstr = self.acqcmd.sethpfilter(chan, int(state))
        self.abi.sendCommandAndBlock(self.acqcmd)        
        
        print "Channel ", chan, " hpf is ", state 

    def setInputCh(self, tet, chan):
        acqcmdstr = self.acqcmd.setinputch(int(tet), int(chan))
        self.abi.sendCommandAndBlock(self.acqcmd)        
        
        print "Set tet ", tet, "to chan ", chan

    def writeFilter(self, filename):
        fid = file(filename)
        pos = 0
        self.acqcmd.updatecmd()
        for l in fid.readlines():
            acqcmdstr = self.acqcmd.writefilter(pos, int(l))
            self.abi.sendCommandAndBlock(self.acqcmd)        

            pos += 1
        while  pos < 256:
            acqcmdstr = self.acqcmd.writefilter(pos, 0)
            self.abi.sendCommandAndBlock(self.acqcmd)        
            pos += 1
            
    def writeSamples(self, filename):
        """ filename is a file consisting of a list
        of samples, that's it.

        """
        fid = file(filename)
        pos = 0
        self.acqcmd.updatecmd()
        for l in fid.readlines():
            acqcmdstr = self.acqcmd.writesamplebuffer(pos, int(l))

            self.abi.sendCommandAndBlock(self.acqcmd)        

            pos += 1
            
def main():
    print sys.argv


    action = sys.argv[1]
    
    ac = acqcnt()

    if action == "mode":
        mode = int(sys.argv[2])
        chan = 'A1'
        if len(sys.argv) > 3:
            chan = sys.argv[3]
        ac.setMode(mode, chan)
        
    elif action == "gain":
        chan = sys.argv[2]
        gain = sys.argv[3]
        
        ac.setGain(chan, int(gain))
    elif action == "hpf":
        chan = sys.argv[2]
        state = sys.argv[3]
        
        ac.setHPF(chan, state)
    elif action == "filterload":
        filename = sys.argv[2]
        ac.writeFilter(filename)

    elif action == "sampleload":
        filename = sys.argv[2]
        ac.writeSamples(filename)

    elif action == "inputch":
        tet = sys.argv[2]
        chan = sys.argv[3]
        ac.setInputCh(tet, chan)

    else:
        print "Proper usage:"
        print "acqcnt mode #modenum #rawchan"
            
        
    


if __name__ == "__main__":
    main()
