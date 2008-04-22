
from struct import *
import os
import sys
sys.path.append("../../")
from acqboardcmd.acqboardcmd import AcqBoardCmd
from acqboardcmd import acqboard
import fiberdebug

import time

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
        self.__inChanA = 0
        self.__inChanB = 0
        
        self.acqcmd = AcqBoardCmd()
        self.abi = fiberdebug.AcqBoardInterface("10.0.0.2")


    def setInChanA(self, value):
        self.__inChanA = value
        
    def getInChanA(self):
        return self.__inChanA

    inChanA = property(getInChanA, setInChanA, None)

    def setInChanB(self, value):
        self.__inChanB = value
    def getInChanB(self):
        return self.__inChanB

    inChanB = property(getInChanB, setInChanB, None)
    
    def setGains(self, value):
        if not isinstance(value, list):
            raise "Gains is not a list"
        for g in value:
            if not isinstance(g, int):
                raise "Gain is not an int"

        self.__gains = value
                
    def getGains(self):
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
    

    def setup(self, rawMode = False,  channels = 'A1'):
        """
        Channel can be a list too
        """
        
        if isinstance(channels, list):
            self.channels = channels
        else:
            self.channels = [channels]

        if rawMode:
            acqcmdstr = self.acqcmd.switchmode(3, rawchan=self.channels[0])
        else:
            acqcmdstr = self.acqcmd.switchmode(0, rawchan=self.channels[0])
        print "sending mode switch"
        self.abi.sendCommandAndBlock(self.acqcmd);

        # set continuous channel A
        acqcmdstr = self.acqcmd.setinputch(0, self.__inChanA)
        self.abi.sendCommandAndBlock(self.acqcmd);

        # set continuous channel B
        acqcmdstr = self.acqcmd.setinputch(1, self.__inChanB)
        self.abi.sendCommandAndBlock(self.acqcmd);
        

        

    def done(self):
        print "board states closing"
        
    def gainIter(self):

        for g in self.__gains:

            newgain = self.gainSet[g]
            

            for channel in self.channels:


            
                acqcmdstr =  self.acqcmd.setgainnum(channel,
                                                    newgain)
                self.abi.sendCommandAndBlock(self.acqcmd)


            for i in acqcmdstr:
                print hex(ord(i)), 

            yield g


    
    def hpfIter(self):

        for h in self.__hpfs:

            # debugging for confused state of current board

            #if self.channel == "A4":
            #    channel =  "A1"
            #elif self.channel == "AC":
            #    channel = "A1"

            for channel in self.channels:
                self.acqcmd.sethpfilter(channel, h)
                self.abi.sendCommandAndBlock(self.acqcmd)

            yield h
