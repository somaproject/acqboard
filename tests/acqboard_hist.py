#!/usr/bin/python

import socket
from os import unlink
from struct import *
import sys
sys.path.append("analysis/")
import readacq
from matplotlib.matlab import *
import gtk 

def update():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    
    s.connect("/tmp/acqboard.out")
    
    sample = s.recv(512)
    pos = 0
    line = 0
    
    fid = open('/tmp/test.hist.dat', 'w')
    
    plineerror = 0
    
    for i in range(4000):

        sample =s.recv(1024)
        fid.write(sample)

    fid.close()
    s.close()

    
    r = readacq.RawFile('/tmp/test.hist.dat')

    x = r.read(100000)
    
    #hist(x, max(x)-min(x))
    #show()
    hist(x, max(x)-min(x))
    show()


update()
