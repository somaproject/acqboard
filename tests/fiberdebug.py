#!/usr/bin/python
"""
This is our interface to the acqboard through the fiberdebug
module, pynetevent, and the acqboard fiber interface.

fiberdebug.acqboard() represents the acqboard as an object.

What do we want to do?
   SendCommands, and wait for a response
   Do we ever want to send commands when we're recording data? No.


"""

import pynetevent
import sys
import acqboardcmd.acqboardcmd
import struct


class AcqBoardInterface(object):

    CMDFIBERCMD = 0x50
    CMDFIBERDATAA = 128
    CMDFIBERDATAB = 129
    CMDFIBERRESP = 130

    DESTSRCID = 76
    
    
    def __init__(self, IP):
        self.pne = pynetevent.PyNetEvent(IP)
        

    def sendCommandAndBlock(self, acqboardcmd):
        """
        acqboardcmd is an AcqBoardCommand object whose state represents
        the most recent state change to the board;

        we retreive the encoded string with acqboardcmd.latestString
        and the most recent commandID with .

        """

        # setup rx
        for i in range(255):
            self.pne.rxSet.add((130, i))

##         self.pne.rxSet.add((self.CMDFIBERRESP,
##                             self.DESTSRCID))
        SRC = 4

        acmdstr = acqboardcmd.latestString
        # this is a total hack, we extract out the command byte
        bytes = struct.unpack("BHH", acmdstr)
        
        cmdid = bytes[0] >> 4
        cmd = bytes[0] & 0xF
        assert cmdid == acqboardcmd.cmdid
        
        self.pne.startEventRX()

        addrtuple =  (0x00, 0x00, 0x00, 0x00, 0x00,
                            0x00, 0x00, 0x00, 0xFF, 0xFF)

        cmdtuple = (self.CMDFIBERCMD, SRC, (cmdid << 8) | cmd,
                    bytes[1], bytes[2], 0x00, 0x0)

        ## Substantial debugging
        
        cmdtuple = (0x50, 4, (cmdid << 8) | (cmd & 0xF), 1, 0, 0, 0)
        self.pne.sendEvent(addrtuple, cmdtuple)


        success = False

        while success == False:
            erx = self.pne.getEvents()
            # extract out events
            for e in erx:
                cmd = e[0]
                src = e[1]
                if cmd == self.CMDFIBERRESP and src == self.DESTSRCID:
                    # response; extract out bits
                    cmdid = e[2]
                    if cmdid == acqboardcmd.cmdid:
                        success = True


# test
def test():
    #startcmdid = int(sys.argv[1])
    print("Running primary AcqBoard Interface Test")
    abi = AcqBoardInterface("10.0.0.2")
    acmd = acqboardcmd.AcqBoardCmd()
    #acmd.cmdid = startcmdid
    
    acmd.setgain('A1', 0)
    abi.sendCommandAndBlock(acmd)
    
    

if __name__ == "__main__":
    test()
