#!/usr/bin/python

"""actual code to create, run the data. How to do this...

For each raw run, the state will be stored as:


function generator freq
function generator amplitude
channel
gain
hpf
data


"""

from  tables import *
from numarray import * 
from test import *


class RawRecord(IsDescription):
    ffreq     = FloatCol()
    famp      = FloatCol()
    channel   = Int8Col()
    gain      = Int8Col()
    hpf       = Int8Col()
    data      = Int16Col(shape=(128000))




class RawRun:
    """ takes in the indicated parameters, performs a run, and appends
    the relevant information to the row rawRunRow"""

    def __init__(self, chan, fmode, ffreq, famp, gain, hpf):
        self.ffreq = ffreq
        self.famp = famp
        self.chan = chan
        self.gain = gain
        self.hpf = hpf

        f = FuncState()
        f.setmode(fmode)
        f.freq = ffreq
        f.amp = famp
        

        a = AcqState()
        a.setmode("raw")
        
        a.gains = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        a.gains[chan] = gain

        a.hpfs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        a.hpfs[chan] = hpf

        t = Test(a,f)

        self.data = zeros(128000, Int16)
        self.data = t.rawrun(128000)

    def append(self, rowrun):
        rowrun['ffreq'] = self.ffreq
        rowrun['famp'] = self.famp
        rowrun['channel'] = self.chan
        rowrun['gain'] = self.gain
        rowrun['hpf'] = self.hpf
        rowrun['data'] = self.data

        rowrun.append()

        
        
    
    
    
if __name__ == "__main__":

    h5file = openFile("tutorial1.h5", mode = "w", title = "Test file")
    group = h5file.createGroup("/", 'raw', 'Raw outputs')
    table = h5file.createTable(group, 'sineruns', RawRecord, "Runs from sine input")
    runrow = table.row

    run = RawRun(0, "sine", 964.84375, 0.030, 1, 0)

    run.append(runrow)

    table.flush()

    h5file.close()
