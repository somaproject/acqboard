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



class AcqBoardInterface(object):

    CMDFIBERCMD = 0x50
    CMDFIBERDATAA = 128
    CMDFIBERDATAB = 129
    CMDFIBERRESP = 0x82

    DESTSRCID = 76
    
    
    def __init__(self, IP):
        self.eio = NetEventIO(IP)
        

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
# test
def test():
    #startcmdid = int(sys.argv[1])
    print("Running primary AcqBoard Interface Test")
    abi = AcqBoardInterface("10.0.0.2")
    acmd = acqboardcmd.AcqBoardCmd()
    #acmd.cmdid = startcmdid
    
    #acmd.setgain('A1', 0)
    acmd.switchmode(3)
    abi.sendCommandAndBlock(acmd)
    
    

if __name__ == "__main__":
    test()
