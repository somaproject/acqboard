#!/usr/bin/python
"""
Command-line interface to control the acqboard; should suck less than the GUI one

examples:
./acqboard mode 0
./acqboard loadfilter foo.firdat
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
import time
import random

class AcqStatDissassemble(object):

    def __init__(self, string):

        r = unpack("bbbb", string) 
        self.cmdsts = r[0]
        self.cmdid = r[1]
        self.success = r[2]
        self.loading = False
        if r[0] & 0x1:
            self.loading = True

        
        print "Disassembled packet with cmdid=", self.cmdid, "Mode =", self.cmdsts >> 1, " loading = ", self.cmdsts & 0x1


def sendCommandAndReTransmit(acqout, acqcmd, acqstat, commandstr):


    acqout.send(commandstr)

    success = False
    while not success: 
        resultstr = acqstat.read()
        if resultstr:
            as = AcqStatDissassemble(resultstr)
            if as.cmdid == acqcmd.cmdid and not as.loading:
                success = True
        else:
            # if indeed we did time out we resend the original command
            print "Acqboard command time-out error; resending command" 
            acqout.send(commandstr)
        

    
class BoardStates(object):
    """

    The gainSet is the set of gains that we will map to the
    gain settings for the acqboard. For example, a [100] in gains is
    turned into a request for the first gain setting in the acqboard. 

    
    """
    def __init__(self):

        self.__gains = [1]
        self.__hpfs = [False]
        self.gainSet = {0: 0,
                        100: 1,
                        200: 2,
                        500: 3,
                        1000: 4,
                        2000 : 5,
                        5000 : 6,
                        10000 : 7}
        
        self.acqout = acqboard.AcqSocketOut()
        self.acqcmd = AcqBoardCmd()
        self.acqstat = acqboard.AcqSocketStatTimeout(1.0)

    
    def setGains(self, value):
        print "setgains"
        if not isinstance(value, list):
            raise "Gains is not a list"
        for g in value:
            if not isinstance(g, int):
                raise "Gain is not an int"

        self.__gains = value
                
    def getGains(self):
        print "getGains"
        return self.__gains

    gains = property(getGains, setGains, None)
    
    
    def setHpfs(self, value):

        if not isinstance(value, list):
            raise "Hpfs is not a list"
        for g in value:
            if not isinstance(g, int):
                raise "Hpf is not an int"

        self.__hpfs = value
                
    def getHpfs(self):
        return self.__hpfs

    hpfs = property(getHpfs, setHpfs)
    

    def setup(self, channel):

        self.acqout.open()
        self.acqstat.open()

        self.channel = channel

        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 self.acqcmd.switchmode(3,
                                                        rawchan=self.channel))
        print "board state setup"

    def done(self):
        self.acqout.close()
        self.acqstat.close()
        
        
    def gainIter(self):

        for g in self.__gains:

            newgain = self.gainSet[g]
            
            

            # debugging for confused state of current board
            channel = self.channel
            #if self.channel == "A4":
            #    channel =  "A1"
            #elif self.channel == "AC":
            #    channel = "A1"

            
            acqcmdstr =  self.acqcmd.setgainnum(channel,
                                             newgain)
            sendCommandAndReTransmit(self.acqout,
                                     self.acqcmd,
                                     self.acqstat,
                                     acqcmdstr)

            print "acqcmd gain set str:",
            for i in acqcmdstr:
                print hex(ord(i)), 

            print "\ngain set", channel, g
            
            yield g


    
    def hpfIter(self):

        for h in self.__hpfs:

            # debugging for confused state of current board
            channel = self.channel
            #if self.channel == "A4":
            #    channel =  "A1"
            #elif self.channel == "AC":
            #    channel = "A1"

            sendCommandAndReTransmit(self.acqout,
                                     self.acqcmd,
                                     self.acqstat,
                                     self.acqcmd.sethpfilter(channel, h))

            print "board state hpf set"
            
            yield h

    
            
class acqcnt:
    def __init__(self):
        self.acqout = acqboard.AcqSocketOut()
        self.acqcmd = AcqBoardCmd()
        self.acqstat = acqboard.AcqSocketStatTimeout(1.0)

        self.gainSet = {0: 0,
                        1: 1,
                        2: 2,
                        5: 3,
                        10: 4,
                        20 : 5,
                        50 : 6,
                        100 : 7}
        
        self.acqout.open()
        self.acqstat.open()

    def setMode(self,  mode, channel):
        acqcmdstr = self.acqcmd.switchmode(mode, rawchan=channel)
        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat, acqcmdstr)
        
                                 
        print "Board switched to mode", mode, " with channel", channel


    def setGain(self, chan, gain):
        newgain = self.gainSet[gain]
        acqcmdstr =  self.acqcmd.setgainnum(chan,
                                            newgain)
        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 acqcmdstr)
        print "Channel ", chan, " gain set to " , gain

    def setHPF(self, chan, state):
        if state:
            acqcmdstr = self.acqcmd.sethpfilter(chan, 1)
        else:
            acqcmdstr = self.acqcmd.sethpfilter(chan, 0)
        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 acqcmdstr)
        
        print "Channel ", chan, " hpf is ", state 

    def writeFilter(self, filename):
        fid = file(filename)
        pos = 0
        self.acqcmd.updatecmd()
        for l in fid.readlines():
            acqcmdstr = self.acqcmd.writefilter(pos, int(l))
            sendCommandAndReTransmit(self.acqout, self.acqcmd,
                                     self.acqstat, acqcmdstr)
            pos += 1
            
    def writeSamples(self, filename):
        fid = file(filename)
        pos = 0
        self.acqcmd.updatecmd()
        for l in fid.readlines():
            acqcmdstr = self.acqcmd.writesamplebuffer(pos, int(l))
            sendCommandAndReTransmit(self.acqout, self.acqcmd,
                                     self.acqstat, acqcmdstr)
            pos += 1
            
def main():
    print sys.argv


    action = sys.argv[1]
    
    ac = acqcnt()
    for i in range(1, random.randint(1, 14)):
        ac.acqcmd.updatecmd()
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

    else:
        print "Proper usage:"
        print "acqcnt mode #modenum #rawchan"
            
        
    


if __name__ == "__main__":
    main()
