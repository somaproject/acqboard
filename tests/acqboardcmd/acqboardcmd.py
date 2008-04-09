#!/usr/bin/python
"""
This is the reference implementation for the acqboard command interface.
This file, and the commands doc should always be in sync.


create a new acqboardcmd object:
   cmd = acqboardcmd();

Status is 6 3 255
   then,
   result = cmd.setgain(chan, value)

   will return a six-char packed string of the command packet
   to set the gain of chan to value

   cmd.cmdid is the  current (most-recently-written) command ID
   
   
"""

from struct import *
    
class AcqBoardCmd:

    channames = { 'A1' : 0, 'A2' : 1, 'A3' : 2, 'A4' : 3, 'AC' : 4,
                 'B1' : 6, 'B2' : 7, 'B3' : 8, 'B4' : 9, 'BC' : 5}
    
    cmdfilename = "/tmp/cmdid"
    
    def __init__(self):
        self.cmdid = 2

        try:  # this is so that we have persistent cmdid across invocations
            self.fid = open(self.cmdfilename, 'ra+b')
            self.fid.seek(0)
            b = self.fid.read(1)
            assert len(b) == 1
            self.cmdid = unpack("B", b)[0]
            print("acqboardcmd: recovered %d from %s." % (self.cmdid,
                                                          self.cmdfilename))
            
        except IOError:
            self.fid = open(self.cmdfilename, 'w+b')
            self.cmdid = 2
            print("acqboardcmd interface: created file %s" % self.cmdfilename)
            

        self.fid.seek(0)
        self.fid.write(pack("B", self.cmdid))
        self.fid.flush()
    
    def cacheString(self, str):
        self.latestString = str
        return str

        
    def updatecmd(self):
        if self.cmdid == 15 :
            self.cmdid = 0
        else:
            self.cmdid += 1
        self.fid.seek(0)
        self.fid.write(pack("B", self.cmdid))
        self.fid.flush()
        
    def noop(self):
        self.updatecmd()        

        cmdbyte = (self.cmdid << 4) | 0x0
        str = pack("BBBBBB", cmdbyte, 0x00, 0x00, \
                   0x0, 0x0, 0x0);


        return self.cacheString(str)
    
        
    def switchmode(self, mode, rawchan='AC' ):
        self.updatecmd()        
        str = ""

            

        cmdbyte = (self.cmdid << 4) | 0x7
        str = pack("BBBBBB", cmdbyte, mode, self.channames[rawchan], \
                   0x0, 0x0, 0x0);


        return self.cacheString(str)
    
    def setgain(self, chan, gain):
        """ Gains are 'actual' gains, i.e. 0, 100, 200, 500,
        1000, 2000, 5000, 10000"""

        
        if gain == 0:
            gainset = 0
        elif gain == 100:
            gainset = 1
        elif gain == 200:
            gainset = 2
        elif gain == 500:
            gainset = 3
        elif gain == 1000:
            gainset = 4
        elif gain == 2000:
            gainset = 5
        elif gain == 5000:
            gainset = 6
        elif gain == 10000:
            gainset = 7
        else:
            print "NOT A VALID GAIN"

            return None 

        return self.setgainnum(chan, gainset)
    

    def setgainnum(self, chan, gainnum):
        """ Actually set the gain to gain setting number 'gainnum' """

        self.updatecmd()        
        str = ""
   
        cmdbyte = (self.cmdid << 4) | 0x1
        
        str = pack("BBBBBB", cmdbyte, self.channames[chan], gainnum, 0x0, 0x0, 0x0);
        
        return self.cacheString(str)

    def setinputch(self, tet, chan):
        # chans:
        #   A : chan = 0
        #   B : chan = 1
        
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x2
        str = pack("BBBBBB", cmdbyte, tet, chan, 0x0, 0x0, 0x0);

        return self.cacheString(str)
        
    def sethpfilter(self, chan, filter):
        self.updatecmd()        
        str = ""
        
        cmdbyte = (self.cmdid << 4) | 0x3
        str = pack("BBBBBB", cmdbyte, self.channames[chan], \
                   filter, 0x0, 0x0, 0x0);

        return self.cacheString(str)
    
        
        
    def writeoffset(self, chan, gain, value):
        None
        
    def writesamplebuffer(self, addr, value):
        print "writesamplebuffer address ", addr, " with value ", value 
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x6
        lowbyte = value & 0xFF
        highbyte = (value >> 8 ) & 0xFF
        print "Lowbyte", lowbyte, " higbyte", highbyte
        str = pack("BBBBBB", cmdbyte, addr, 0x00, highbyte,lowbyte, 0x0);

        
        return self.cacheString(str)

    def writefilter(self, addr, value):
        print "writefilter address ", addr, " with value ", value 
        self.updatecmd()        
        str = ""

        cmdbyte = (self.cmdid << 4) | 0x5

        x = pack("i", value);
        y = unpack("BBB", x[0:3])
        fid = file('/tmp/filter.out', 'a')
        str = pack("BBBBBB", cmdbyte, addr, y[2] ,y[1] , y[0], 0x0 );
        fid.write("value: %d, bytes : %d %d %d\n" % (value, y[2], y[1], y[0]))
        fid.close()

        
        return self.cacheString(str)
        

if __name__ == "__main__":
    cmd = AcqBoardCmd()

    print unpack("BBBBBB", cmd.switchmode(4))
    print unpack("BBBBBB", cmd.setgain('A3', 100))
    print unpack("BBBBBB", cmd.setinputch(0, 3))
    
