
from struct import *
import os
import sys
sys.path.append("../../")
from acqboardcmd.acqboardcmd import AcqBoardCmd
from acqboardcmd import acqboard
import time

class AcqStatDissassemble(object):

    def __init__(self, string):
        print "The length of the string is", len(string)
        r = unpack("bbbb", string) 
        self.cmdsts = r[0]
        self.cmdid = r[1]
        self.success = r[2]
        self.loading = False
        if r[0] & 0x1:
            self.loading = True




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
        self.__inChanA = 0
        self.__inChanB = 0
        
        self.acqout = acqboard.AcqSocketOut()
        self.acqcmd = AcqBoardCmd()
        self.acqstat = acqboard.AcqSocketStatTimeout(1.0)

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
    

    def setup(self, rawMode = False,  channel = 'A1'):

        self.acqout.open()
        self.acqstat.open()

        self.channel = channel

        if rawMode:
            acqcmdstr = self.acqcmd.switchmode(3, rawchan=self.channel)
        else:
            acqcmdstr = self.acqcmd.switchmode(0, rawchan=self.channel)

        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 acqcmdstr);


        # set continuous channel A
        acqcmdstr = self.acqcmd.setinputch(0, self.__inChanA)
        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 acqcmdstr);
        

        # set continuous channel B
        acqcmdstr = self.acqcmd.setinputch(1, self.__inChanB)
        sendCommandAndReTransmit(self.acqout,
                                 self.acqcmd,
                                 self.acqstat,
                                 acqcmdstr);
        

        

    def done(self):
        print "board states closing"
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


            for i in acqcmdstr:
                print hex(ord(i)), 

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

            yield h

    
            
