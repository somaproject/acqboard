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
    data          = tables.Int16Col(shape=(2**17,))
    
class NoiseRecord(tables.IsDescription):
    gain = tables.Int16Col()
    data          = tables.Int16Col(shape=(2**16,))


class Experiment(object):

    def __init__(self, filename, title, raw, balanced=False):

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
        self.raw = raw

        self.balanced = balanced
        self.chanlist = ['A1', 'A2', 'A3', 'A4', 'AC',
                         'B1', 'B2', 'B3', 'B4', 'BC']
    def run(self):

        for chan in self.chanlist:
            print "Running for channel ", chan
            self.runChan(chan)

    def runChan(self, chanName):

        chan = eval("self.%s" % chanName)
        for i, v in enumerate(self.chanlist):
            if chanName == v:
                chanNum = i
                
        
        
        if len(chan) > 0 :
            try:
                chgroup = self.h5file.getNode("/", chanName, classname='Group')
            except LookupError:
                chgroup = self.h5file.createGroup("/", chanName,
                                                  "Channel %s " %chanName)

            
        for set in chan:
            (bs, ss) = set

            bs.setup(self.raw, chanName)

            if isinstance(ss, sourcestates.SineStates):
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
                                                               "hpf%d" % h,
                                                               "hpf")
                        except tables.NodeError:
                            hpfgroup = self.h5file.getNode(gaingroup,
                                                           "hpf%d" % h,
                                                           classname="Group")

                        # if this is a sine, we do one thing:
                        if isinstance(ss, sourcestates.SineStates):
                            # create sine node
                            table = self.h5file.createTable(hpfgroup, "sine",
                                                            SineRecord,
                                                            "notes")

                            if self.raw:
                                table.attrs.fs = 192000
                            else:
                                table.attrs.fs = 32000

                            # create table insde of sine node
                            ss.setup(self.balanced) 

                            for f in ss.freqIter():
                                for v in ss.vppIter(g):


                                    row = table.row
                                    row['frequency'] = f
                                    row['sourcevpp'] = v

                                    # This is very fragile; 
                                    # it's all python's fault. 
                                    time.sleep(0.1)

                                    if self.raw:
                                        x = rawread(2**17)
                                    else:
                                        x = normread(2**18, [chanNum])
                                    #pylab.plot(x[:1000])
                                    #pylab.show()
                                    y = diff(x)
                                    row['data'] = x[0][2**17:]
                                    row.append()
                                    time.sleep(0.0)

                            table.flush()

               
            elif isinstance(ss, sourcestates.NoiseStates):

                try:
                    noisegroup = self.h5file.createGroup(chgroup,
                                                            "noise",
                                                            "noise")
                    
                except tables.NodeError:
                    noisegroup = self.h5file.getNode(chgroup, "noise",
                                                    classname="Group")

                    # open node in file
                for h in bs.hpfIter():
                    # open node in file


                    
                    table = self.h5file.createTable(noisegroup, "hpf%d" %h ,
                                                    NoiseRecord,
                                                    "notes")

                    if self.raw:
                        table.attrs.fs = 192000
                    else:
                        table.attrs.fs = 32000
                        
                        for g in bs.gainIter():
                            row = table.row
                            row['gain'] = g
                            
                            # This is very fragile; 
                            # it's all python's fault. 
                            time.sleep(1.0)
                            
                            if self.raw:
                                x = rawread(2**17)
                            else:
                                x = normread(2**17, [chanNum])

                            row['data'] = x[0][2**16:]
                            row.append()
                            time.sleep(0.0)
                                
                            table.flush()
            bs.done()

def simpleTest(filename):

    e = Experiment(filename, "A test experiment", raw=False, balanced=True)

    b = boardstates.BoardStates()
    s = sourcestates.SineStates(chanA=True, chanB=True)
    gainSet = {0:0,
               100:1,
               200:2,
               500:3,
               1000:4,
               2000:5,
               5000:6,
               10000:7}
    
    b.gainSet = gainSet
    b.hpfs = [0, 1]
    b.gains = [10000]
    #b.gains = [100]
    b.inChanB = 0
    b.inChanA = 0    
    #b.gains = [1]
    f1 = 50
    f2 = 10000
    #s.freqs = logspace(log10(f1), log10(f2), 20)
    s.freqs = linspace(f1, f2, 20)
    #s.freqs = array([100.0, 500.0, 1000.0, 10000.0])
    s.vpps = [3.9]
    
    e.A1.append((b, s))
    e.A2.append((b, s))
    e.A3.append((b, s))
    e.A4.append((b, s))
    e.B1.append((b, s))
    e.B2.append((b, s))
    e.B3.append((b, s))
    e.B4.append((b, s))
##     e.BC.append((b, s))

    #e.AC.append((b, s))
    


    print "ready to run" 
    e.run()

def noiseTest(filename):

    e = Experiment(filename, "A test experiment", raw=False, balanced=False)

    b = boardstates.BoardStates()
    s = sourcestates.NoiseStates()
    gainSet = {0:0,
               100:1,
               200:2,
               500:3,
               1000:4,
               2000:5,
               5000:6,
               10000:7}
    b.gainSet = gainSet
    b.hpfs = [0, 1]
    b.gains = [100, 200, 500, 1000, 2000, 5000, 10000]
    e.A1.append((b, s))
    e.A2.append((b, s))
    e.A3.append((b, s))
    e.A4.append((b, s))
    e.AC.append((b, s))
    
    e.B1.append((b, s))
    e.B2.append((b, s))
    e.B3.append((b, s))
    e.B4.append((b, s))
    e.BC.append((b, s))


    print "ready to run" 
    e.run()

def CMRRTest(filename):

    e = Experiment(filename, "A test experiment", raw=False, balanced=False)

    b = boardstates.BoardStates()
    s = sourcestates.SineStates(gainScale = False)
    gainSet = {0:0,
               100:1,
               200:2,
               500:3,
               1000:4,
               2000:5,
               5000:6,
               10000:7}
    
    b.gainSet = gainSet
    b.hpfs = [1, 0]
    #b.gains = [100, 200, 500, 1000, 2000, 5000, 10000]
    b.gains = [1000, 10000]
    #b.gains = [1]
    f1 = 20
    f2 = 10000
    s.freqs = logspace(log10(f1), log10(f2), 10.)
    #s.freqs = linspace(f1, f2, 20)
    
    s.vpps = [3.0]
    
    #e.A1.append((b, s))
    #e.A1.append((b, s))
    e.A2.append((b, s))
    #e.A3.append((b, s))
    #e.A4.append((b, s))
    #e.AC.append((b, s))
    e.run()
    
if __name__ == "__main__":
    if sys.argv[1] == "noise":
        noiseTest(sys.argv[2])
    elif sys.argv[1] == "sine":
        simpleTest(sys.argv[2])
    elif sys.argv[1] == "cmrr":
        CMRRTest(sys.argv[2])
