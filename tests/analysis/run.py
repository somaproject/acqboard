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



class Run:
    """ Run takes in an acqstate and a fstate, and a number of samples,
    and an hdf5 group, and appends a table to that group.

    for example:
         r = Run()
         r.acqstate = myacqstate
         r.fstate = myfstate
         r.run(len)
         r.save(loc, name)

    how does run know whether or not it's a raw? The problem is that the
    parsing code for raw vs non-raw is very very different, and in fact
    non-raw returns effectively 10 separate data streams.  

    acqstate determines whether it's a raw run or not.

    r.save for a raw simply saves the raw
    r.save(h5file, loc, name, chan) for a non-raw saves the non-raw channel

    

    """

    def __init__(self):
        self.acqstate = None
        self.fstate = None
        self.data = None

    def run(self, len):
        t = Test(self.acqstate,self.fstate)

        if self.acqstate.mode == 3:
            # raw!
            self.data = zeros(len, Int16)
            self.data = t.rawrun(len)
        else:
            # HERE IS WHERE WE PUT THE MULTI-CHANNEL CODE
            pass

    def save(self, h5file, group, name, chan=None):

    

        if self.acqstate.mode == 3:
            # raw save
            writeobj = self.data
        else:
            writeobj = self.data[chan]

        h5file.createArray(group, name, writeobj, name)
        a = h5file.leaves[group + "/" + name].attrs

        a.gains = str(self.acqstate.gains)
        a.hpfs = str(self.acqstate.hpfs)
        a.inchana = self.acqstate.inchana
        a.inchanb = self.acqstate.inchanb
        a.mode = self.acqstate.mode
        a.rawchan = self.acqstate.rawchan


        a.fmode = self.fstate.mode
        if self.fstate.mode == 4:
            a.famp = str(self.fstate.amp)
            a.ffreq = str(self.fstate.freq)
        else:
            a.famp = self.fstate.amp
            a.ffreq = self.fstate.freq

        a.foffset = self.fstate.offset
        
    
if __name__ == "__main__":

    h5file = openFile("test.h5", mode = "w", title = "Test file")
    group = h5file.createGroup("/", 'raw', 'Raw outputs')


    
    f = FuncState()

    f.setmode("IMD")
    f.freq = (964.84375, 2894.53125)
    f.amp = (0.020, 0.020)



    a = AcqState()
    a.setmode("raw")
    a.rawchan = 0
    a.gains = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    
    r = Run()
    r.acqstate = a
    r.fstate = f
    r.run(128000)
    r.save(h5file, "/raw", "testrun")
    
    
    h5file.close()
