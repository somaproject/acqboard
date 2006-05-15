#!/usr/bin/python
"""
generic code to let us read in and process AD's continuous data


The goal here is a read function that returns an MxN vector of data, where
we have specified M, and optionally N (length), although some will not support it (such as this function)


"""

import numpy
import sys
import pylab
import scipy
import re
import os

class ADio(object):
    """
    We have gain properties that we can read and are populated
    by constructing the object

    """
    
    
    def __init__(self, fname, chans):
        
        self.filename = fname
        self.fid = file(self.filename, 'rb')
        self.chans = chans
        self.bsize = 3072
        self.ccnt = 8
        self.vrange = (-10.0, 10.0)
        self.bits = 12
        self.fsize = os.stat(fname)[6]

        self.gains = []
        reampgain = re.compile("% channel (\d+) ampgain:\s+(\d+).*")
        txt = ""
        while txt != "%%ENDHEADER\n":
            txt = self.fid.readline()
            r = reampgain.match(txt)
            if r:
                c = int(r.groups()[0])
                if c in self.chans:
                    self.gains.append(int(r.groups()[1]))

    def read(self, N):
        """ Please note that N is only a suggestion of how much
        you should read; check actual return value.

        Returns chans as Int16s """

        bufstoread = int(scipy.ceil(float(N)/self.bsize))

        possibleread = int(self.fileleft() / (self.bsize*8*2))

        print bufstoread, possibleread
        readnum = min(bufstoread, possibleread)
        outvars = numpy.empty((len(self.chans), readnum*self.bsize),
                              numpy.Int16)
        
        for i in range(readnum):
            ts = self.fid.read(4)
            # now read in a full buffer:
            x = numpy.fromfile(self.fid, dtype=numpy.Int16, count=self.bsize*8)
            x.shape = (-1, 8)
            y =  x.transpose()
            outvars[:, i*self.bsize:(i+1)*self.bsize] = y[self.chans, :]
            
        return outvars

    def fileleft(self):
        return self.fsize - self.fid.tell()

    def readVoltages(self, N):
        """ Just like read() except performs gain compensation
        and returns 32-bit floats """
        x = self.read(N)
        y = numpy.empty(x.shape, dtype=numpy.Float32)
        g = numpy.array(self.gains)

        v = self.vrange[1] - self.vrange[0]
        y =  x.astype(numpy.Float32) / 2**(self.bits - 1) * v

        volts = numpy.empty(x.shape, dtype=numpy.Float32)
        for i, g in enumerate(g):
            volts[i, :] = y[i, :] / g
            
        return  volts
    
    def eof(self):
        if self.fileleft() < self.bsize:
            return True
        else:
            return False
        
        
def test():
    x = ADio(sys.argv[1], [0, 1, 2, 3])
    y =  x.readVoltages(100000)
    print x.gains, y.shape
    pylab.plot(y[0, :] * 1e6)
    pylab.ylabel('voltages (uV)')
    pylab.show()

if __name__ == "__main__":
    test()
    
            
