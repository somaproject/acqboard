#!/usr/bin/python
"""
This is our interface to the acqboard through the fiberdebug
module, pynet, and the acqboard fiber interface.

fiberdebug.acqboard() represents the acqboard as an object.

What do we want to do?
   SendCommands, and wait for a response
   Do we ever want to send commands when we're recording data? No.


"""


from somapynet.event import Event
from somapynet import eaddr
from somapynet.neteventio import NetEventIO

import sys
import acqboardcmd.acqboardcmd
import struct
import numpy as n
import pylab

class AcqBoardInterface(object):

    CMDFIBERCMD = 0x50
    CMDFIBERDATAA = 128
    CMDFIBERDATAB = 129
    CMDFIBERRESP = 0x82

    DESTSRCID = 76
    
    
    def __init__(self, IP, set = 'A'):
        self.eio = NetEventIO(IP)
        self.set = set
        

    def sendCommandAndBlock(self, acqboardcmd):
        """
        acqboardcmd is an AcqBoardCommand object whose state represents
        the most recent state change to the board;

        we retreive the encoded string with acqboardcmd.latestString
        and the most recent commandID with .

        """

        # setup rx
        self.eio.addRXMask(self.CMDFIBERRESP, xrange(256) )

        SRC = 3

        acmdstr = acqboardcmd.latestString
        # this is a total hack, we extract out the command byte
        bytes = struct.unpack("BBBBBB", acmdstr)
        
        cmdid = bytes[0] >> 4
        cmd = bytes[0] & 0xF
        assert cmdid == acqboardcmd.cmdid
        
        self.eio.start()
        ea = eaddr.TXDest()
        ea[:] = 1
        e = Event()
        e.cmd = self.CMDFIBERCMD
        e.src = SRC
        e.data[0] = (cmdid << 8) | cmd
        e.data[1] = bytes[4] << 8 | bytes[3]
        e.data[2] = bytes[2] << 8 | bytes[1]


        ## Substantial debugging
        
        #cmdtuple = (0x50, 4, (cmdid << 8) | (cmd & 0xF), 1, 0, 0, 0)
        #self.pne.sendEvent(addrtuple, cmdtuple)
        print "sending event", e
        self.eio.sendEvent(ea, e)
        

        success = False

        while success == False:
            erx = self.eio.getEvents()
            # extract out events
            for e in erx:
                #print e
                if e.cmd == self.CMDFIBERRESP: # and e.src == self.DESTSRCID:
                    # response; extract out bits
                    cmdid = e.data[0]
                    if cmdid == acqboardcmd.cmdid:
                        success = True

        self.eio.stop()
    def getSamples(self, N):
        """ Very simple interface to getting
        samples -- at the moment we just return N samples
        from either the A channels or the B channels"""

        data = n.zeros((5, N), dtype=n.int16)
        if self.set == "A":
            self.eio.addRXMask(self.CMDFIBERDATAA, xrange(256) )
        else:
            self.eio.addRXMask(self.CMDFIBERDATAB, xrange(256) )


        self.eio.start()
        receivedN = 0
        while (receivedN < N):
            erx = self.eio.getEvents()
            for e in erx:
                if receivedN < N:
                    for i in xrange(5):
                        print e
                        data[i][receivedN]  = e.data[i]
                receivedN += 1
        self.eio.stop()

        return data

def test():
    #startcmdid = int(sys.argv[1])
    print("Running primary AcqBoard Interface Test")
    abi = AcqBoardInterface("10.0.0.2")
    acmd = acqboardcmd.AcqBoardCmd()
    #acmd.cmdid = startcmdid
    
    #acmd.setgain('A1', 0)
    acmd.switchmode(3)
    abi.sendCommandAndBlock(acmd)

def test2():
    set = sys.argv[1]
    chan = [int(x) -1 for x in sys.argv[2:]]
        
    abi = AcqBoardInterface("10.0.0.2", set=set)
    x = abi.getSamples(1000)
    pylab.subplot(len(chan), 1, 1)
    for i, v in enumerate(chan):
        pylab.subplot(len(chan), 1, i+1)
        pylab.plot(x[v][:100])
    
               
    pylab.show()
                 
                 
    

if __name__ == "__main__":
    test2()
