#!/usr/bin/python

import socket
from os import unlink
from struct import *


s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)


s.connect("/tmp/acqboard.out")

sample = s.recv(512)
pos = 0
line = 0

fid = open('/home/jonas/test.dat', 'w')

plineerror = 0

while (sample):

    sample =s.recv(1024)
    fid.write(sample)
    
    
