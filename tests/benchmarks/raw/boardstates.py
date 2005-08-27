
from struct import *
import os
import sys
sys.path.append("../../")
from acqboardcmd.acqboardcmd import AcqBoardCmd
from acqboardcmd import acqboard
import time

class AcqStatDissassemble(object):

    def __init__(self, string):

        r = unpack("bbbb", string) 
        self.cmdsts = r[0]
        self.cmdid = r[1]
        self.success = r[2]
        self.loading = False
        if r[0] & 0x1:
            self.loading = True

        print "Disassembled packet with cmdid=", self.cmdid


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

    def __init__(self):

        self.__gains = [1]
        self.__hpfs = [False]

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
        
    def gainIter(self):

        for g in self.__gains:

            newgain = g
            
            if g == 1:
                newgain = 100

            sendCommandAndReTransmit(self.acqout,
                                     self.acqcmd,
                                     self.acqstat,
                                     self.acqcmd.setgain(self.channel,
                                                         newgain))



            print "board state gain set" 
            yield g


    
    def hpfIter(self):

        for h in self.__hpfs:

            sendCommandAndReTransmit(self.acqout,
                                     self.acqcmd,
                                     self.acqstat,
                                     self.acqcmd.sethpfilter(self.channel, h))

            print "board state hpf set"
            
            yield h

    
            
