#!/usr/bin/python
import sys
import time
import sourcestates
import boardstates
from read import * 
import tables
from scipy import * 
from matplotlib import pylab

class SineRecord(tables.IsDescription):
    frequency     = tables.FloatCol()
    sourcevpp     = tables.FloatCol()
    data          = tables.Int16Col(shape=(2**16,))


class Experiment(object):

    def __init__(self, filename, title):

        self.A1 = []
        self.A2 = []
        self.A3 = []
        self.A4 = []
        self.AC = []
        self.B1 = []
        self.B2 = []
        self.B3 = []
        self.B4 = []
        self.BC = []
          
        self.h5file = tables.openFile(filename, mode = "w", title = title)
        
    def run(self):

        chanlist = ['A1', 'A2', 'A3', 'A4', 'AC', 'B1', 'B2', 'B3', 'B4', 'BC']


        for chan in chanlist:
            self.runChan(chan)

    def runChan(self, chanName):

        chan = eval("self.%s" % chanName)

        if len(chan) > 0 :
            try:
                chgroup = self.h5file.getNode("/", chanName, classname='Group')
            except LookupError:
                chgroup = self.h5file.createGroup("/", chanName,
                                                  "Channel %s " %chanName)

            
        for set in chan:
            (bs, ss) = set

            print "setting up board channel with ", chanName
            bs.setup(chanName)

            
            for g in bs.gainIter():

                try:
                    gaingroup = self.h5file.createGroup(chgroup,
                                                        "gain%d" % g,
                                                        "gain")
                    gaingroup._v_attrs.gain = g
                    
                except tables.NodeError:
                    gaingroup = self.h5file.getNode(chgroup, "gain%d" % g,
                                                    classname="Group")
                    
                # open node in file
                for h in bs.hpfIter():
                    # open node in file
                    try:
                        hpfgroup = self.h5file.createGroup(gaingroup,
                                                           "hpf%d" % h, "hpf")
                    except tables.NodeError:
                        hpfgroup = self.h5file.getNode(gaingroup, "hpf%d" % h,
                                                    classname="Group")

                    # if this is a sine, we do one thing:
                    if isinstance(ss, sourcestates.SineStates):
                        # create sine node
                        table = self.h5file.createTable(hpfgroup, "sine",
                                                        SineRecord, "notes")

                        # create table inside of sine node
                        ss.setup(True) # output is balanced
                        
                        for f in ss.freqIter():
                            for v in ss.vppIter(g):


                                row = table.row
                                row['frequency'] = f
                                row['sourcevpp'] = v
                                
                                
                                # read the data
                                x = read(2**17)
                                row['data'] = x[2**16:]
                                row.append()

                        table.flush()
            bs.done()

def simpleTest(filename):

    e = Experiment(filename, "A test experiment")

    b = boardstates.BoardStates()
    s = sourcestates.SineStates()
    gainSet = {0:0,
               1:1,
               2:2,
               5:3,
               10:4,
               20:5,
               50:6,
               100:7}
    b.gainSet = gainSet
    b.hpfs = [0, 1]
    #b.gains = [1, 2, 5, 10, 20, 50, 100]
    b.gains = [1]
    f1 = 20
    f2 = 1000
    #s.freqs = logspace(log10(f1), log10(f2), 100.)
    s.freqs = linspace(f1, f2, 100)
    
    s.vpps = [4.05]
    
    e.A4.append((b, s))
    #b2 = boardstates.BoardStates()
    
    #b2.gainSet = gainSet
    #b2.gains = [50, 100]
    #s2 = sourcestates.SineStates()
    #s2.freqs = linspace(f1, f2, 50)
    #s2.vpps = [2.0]
    #e.A4.append((b2, s2))

    print "ready to run" 
    e.run()

if __name__ == "__main__":
    simpleTest(sys.argv[1])
