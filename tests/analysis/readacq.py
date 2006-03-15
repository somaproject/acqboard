#!/usr/bin/python

import numpy as numpy

import struct


class DataFile:
    def read(self, N):
        pass
    
class RawFile(DataFile):
    """ Read the acqboard out RAW file format, from the 24 byte
    output sequence.

    """

    
    def __init__(self, filename):
        self.filename = filename
        
        self.fid = file(filename, 'rb')

        # correct for file offset... wtf? 
        self.offset = 9
        self.fid.read(self.offset*2)

        self.pos = 0 

        
    def read(self, N):
        """ returns N shorts."""

        result = zeros( N, 'i2')
        
        
        for i in range(N):
            x = struct.unpack(">h", self.fid.read(2))

            if self.pos == 5:
                self.fid.read(6*2)
                self.pos = 0
            else:
                self.pos += 1

            result[i] = x[0]
            
            
        return result

    
class RegFile(DataFile):
    """ Read the acqboard out regular file format, from the 24 byte
    output sequence.

    This reads in an initial 24*4 bytes to determine the file offset.
    

    """


    
    def __init__(self, filename):
        self.filename = filename
        self.framelen = 12       
        self.fid = file(filename, 'rb')

        n = 6
        x = numpy.fromfile(self.fid, numpy.ubyte, n * 2 *self.framelen)

        hdrpos = []
        candidateoffsets = []
        for i in range(self.framelen * 2):
            res = x[i::self.framelen * 2]
            if sum(res == 0xBC) >= n-1:
                candidateoffsets.append(i)

        print x
        if len(candidateoffsets) == 0:
            raise "offset not found"
        if len(candidateoffsets) > 1:
            raise "too many 0xBC found"

        # success
        self.fid = file(filename, 'rb')
        self.fid.read(candidateoffsets[0])

            
        self.pos = 0 
        
    def read(self, N):
        """ returns N shorts, from each of the requested columns"""

        x = numpy.fromfile(self.fid, numpy.short, N*self.framelen)
        x.shape = (N, self.framelen) 
        return x.transpose().byteswap()
    
    
import sys

#from matplotlib.matlab import *


def example():
    f = RegFile(sys.argv[1], 0)




if __name__ == "__main__":
    example()
