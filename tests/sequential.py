#!/usr/bin/python


from struct import *
f=open('/home/jonas/data.python.dat', 'rb')

sample = f.read(32)
pos = 0
line = 0


plineerror = 0
while sample:
    
    line = line + 1
    
    sample = f.read(32)
    if len(sample) < 32 :
        print line
    result = unpack("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", sample);

    for i in range(24):
        
        if result[i+1] != (pos+1) and (pos != 238):
            #print "error at ",  pos+1,  result[i+1], "line :", line
            #print result
            #print line
            
            print (line - plineerror)
            plineerror = line
        pos = result[i+1]
    
