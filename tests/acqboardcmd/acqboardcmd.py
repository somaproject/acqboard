#!/usr/bin/python
"""
This is the reference implementation for the acqboard command interface.
This file, and the commands.ai doc should always be in sync.


create a new acqboardcmd object:
   cmd = acqboardcmd();

   then,
   result = cmd.setgain(chan, value)

   will return a six-char packed string of the command packet
   to set the gain of chan to value

   cmdid = current (most-recently-written) command ID
   
"""

from struct import *

class AcqBoardCmd:

    def __init__(self):
        self.cmdid = 0
        
    def updatecmd(self):
        if self.cmdid == 15 :
            self.cmdid = 0
        else:
            self.cmdid += 1
            
    def switchmode(self, mode):
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x0
        str = pack("BBBBBB", cmdbyte, mode, 0x0, 0x0, 0x0, 0x0);

        return str;
    
    def setgain(self, chan, gain):
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x1
        str = pack("BBBBBB", cmdbyte, chan, gain, 0x0, 0x0, 0x0);

        return str;
    
    def setinputch(self, chan, input):
        # chans:
        #   A : chan = 0
        #   B : chan = 1
        
        self.updatecmd()        
        str = ""

        if chan == 0 :
            chanval = 4
        elif chan == 1:
            chanval = 5

        
        cmdbyte = (self.cmdid << 4) | 0x2
        str = pack("BBBBBB", cmdbyte, chanval, input, 0x0, 0x0, 0x0);

        return str;
        
    def sethpfilter(self, chan, filter):
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x3
        str = pack("BBBBBB", cmdbyte, chan, filter, 0x0, 0x0, 0x0);

        return str;
        
        
    def writeoffset(self, chan, gain, value):
        None
        
    def writefilter(self, addr, value):
        None
        
    def writesamplebuffer(self, addr, value):
        None
        

if __name__ == "__main__":
    cmd = AcqBoardCmd()

    print unpack("BBBBBB", cmd.switchmode(4))
    print unpack("BBBBBB", cmd.setgain(7, 4))
    print unpack("BBBBBB", cmd.setinputch(0, 3))
    
