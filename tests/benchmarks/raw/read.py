#!/usr/bin/python

from numarray import *
import socket
from os import unlink
from struct import *

"""

Code to read in n samples of raw data via the protointerface domain socket system
"""

def read(nsamples):



    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    
    
    s.connect("/tmp/acqboard.out")
    
    
    
    nsamp = 0; 
    
    resultstr = ""
    fid = file("/tmp/readdata.tmp", 'w')
    sample = s.recv(512)
    
    while (nsamp < (2*nsamples*24.0/12.0 + 200)):
        tmpstr =s.recv(1024)
        nsamp += len(tmpstr)
        #resultstr += tmpstr
        fid.write(tmpstr)

    fid.close()
    fid = file("/tmp/readdata.tmp")
    resultstr = fid.read()
    offset = 18
    datastr = resultstr[offset:]

        

    # now, we format
    data = zeros(nsamples, Int16)
    
    pos = 0
    for i in range(len(datastr)/2):

        #print i, len(datastr), len(datastr)/2, pos
        if i % 12 < 6 :
            if pos < nsamples:
                data[pos] = unpack(">h", datastr[(2*i):(2*(i+1))])[0]
                pos += 1             

    s.close()

    
    return data
