#!/usr/bin/python
"""
HDF5/pytables interface for storing Raw file data. This is largely for storing results of measuring AcqBoard performance in Raw Mode.



"""

from tables import *
from Numeric import *

class SineRecord(IsDescription):
    frequency     = FloatCol()
    sourcevpp     = FloatCol()
    data          = Int16Col(shape=(2**17,))


class H5File:
    def __init__(self, filename, title, acqVersion=4.3):
        self.filename = filename
        self.title = title

        self.h5file = openFile(filename, mode = "w", title = title)
                
    def openChan(self, chanName):
        try:
            group = self.h5file.getNode("/", chanName, classname='Group')
        except LookupError:
            group = self.h5file.createGroup("/", chanName, "Channel %s " %chanName)

        return RawH5Chan(group, self.h5file)

    def __del__(self):
        self.h5file.close()

class RawH5Chan:
    def __init__(self, group, h5file):
        self.group = group
        self.h5file = h5file

    def addSineRun(self, name, notes, gain, hpfen):
        
        # /first try and create the group something something
        try:
            sinegroup = self.h5file.createGroup(self.group, "sine",
                                                "Sinusoidal data ")
        except NameError:
            sinegroup = self.h5file.getNode(self.group, "sine",
                                            classname="Group")
          
        
        table = self.h5file.createTable(sinegroup, name, SineRecord, notes)
        table.attrs.gain = gain
        table.attrs.hpfen = False
        
        return SineRun(table)

        

class SineRun:
    def __init__(self, table):
        self.table = table

    def append(self, freq, vpp, data):
        row = self.table.row
        row['frequency'] = freq
        row['sourcevpp'] = vpp
        row['data'] = data
        row.append()
        

    def __del__(self):
        self.table.flush()


def main ():

    # a simple test:
    rf = RawH5File("simpletest.h5", "My simple test")
    chA1 = rf.openChan('A1')
    sinetest = chA1.addSineRun("testsine", "A very nice sine test", 1, False)
    sinetest.append(997.0, 0.0001, zeros(65536))
    sinetest.append(31.0, 0.0001, zeros(65536))
    sinetest.append(997.0, 0.0001, zeros(65536))

    sinetest = chA1.addSineRun("testsine2", "A very nice sine test", 10, True)
    sinetest.append(997.0, 0.0001, zeros(65536))
    sinetest.append(31.0, 0.0001, zeros(65536))
    sinetest.append(997.0, 0.0001, zeros(65536))

    chA2 = rf.openChan('A2')
    sinetest = chA2.addSineRun("testsine", "A very nice sine test", 10, False)
    sinetest.append(997.0, 0.0001, zeros(65536))
    sinetest.append(31.0, 0.0001, zeros(65536))
    sinetest.append(997.0, 0.0001, zeros(65536))
    
if __name__ == "__main__":
    main()
