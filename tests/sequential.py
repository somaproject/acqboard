#!/usr/bin/python

from struct import *
f=open('/home/jonas/data.raw.dat', 'rb')

sample = f.read(32)
pos = 0
line = 0

while sample:
    
    line = line + 1
    sample = f.read(32)
    if len(sample) < 32 :
        print line
    result = unpack("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", sample);

    #for i in range(24):
        
    #    if result[i+1] != (pos+1) and (pos != 238):
    #        print "error at ",  pos+1,  result[i+1]
    #        print result
    #        print line
    #    pos = result[i+1]
    #simple test
    if result[0] != 188:
        print result
        print line
