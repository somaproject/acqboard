#!/usr/bin/python
import sys
import time
import sourcestates
import boardstates
import read
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

class AllTHDNExperiment(object):
    """

    This takes in a list of channels, and runs the same gains, board
    states, etc. across all the channels, and saves the results in the
    same format as before. I'm not sure how much time this will
    ultimately save since we have board state changes across all channels.

    But it should speed it up at least a bit.     

    """
    

    def __init__(self, filename, title, raw = False, balanced=False):

        self.chans = []

          
        self.h5file = tables.openFile(filename, mode = "w", title = title)
        self.raw = raw

        self.balanced = balanced
        self.chanlist = ['A1', 'A2', 'A3', 'A4', 'AC',
                         'B1', 'B2', 'B3', 'B4', 'BC']

        

    def getSineTable(self, chanName, gain, hpf, fs):
        """
        returns the sine table at this node


        """
        try:
            chgroup = self.h5file.getNode("/", chanName, classname='Group')
        except LookupError:
            chgroup = self.h5file.createGroup("/", chanName,
                                                  "Channel %s " %chanName)


        try:
            gaingroup = self.h5file.createGroup(chgroup,
                                                "gain%d" % gain,
                                                "gain")
            gaingroup._v_attrs.gain = gain
            
        except tables.NodeError:
            gaingroup = self.h5file.getNode(chgroup, "gain%d" % gain,
                                            classname="Group")
            
            
        try:
            hpfgroup = self.h5file.createGroup(gaingroup,
                                               "hpf%d" % hpf,
                                               "hpf")
        except tables.NodeError:
            hpfgroup = self.h5file.getNode(gaingroup,
                                           "hpf%d" % hpf,
                                           classname="Group")
        try:
            table = hpfgroup.sine
        except:
        
            table = self.h5file.createTable(hpfgroup, "sine",
                                            SineRecord,
                                            "notes")

        table.attrs.fs = fs
        return table
    
    def run(self):
        self.runChans()
        
    def runChans(self):
        
        
        self.bs.setup(rawMode = False, channels = self.chans)

        channums = []
        for i in self.chans:
            for pos, c in enumerate(self.chanlist):
                if i == c:
                    channums.append(pos)
        print "self.chans = ", self.chans

        for g in self.bs.gainIter():
            # create table insde of sine node
            self.ss.setup(self.balanced) 
            for h in self.bs.hpfIter():            
                for f in self.ss.freqIter():
                    for v in self.ss.vppIter(g):
                            

  
                    
                        # This is very fragile; 
                        # it's all python's fault. 
                        time.sleep(0.1)

                        print channums
                        
                        x = read.normread(2**18, channums)

                        y = diff(x)

                        for i, c in enumerate(self.chans):
                            table =  self.getSineTable(c, g, h, 32000)

                            row = table.row
                            row['frequency'] = f
                            row['sourcevpp'] = v
                            row['data'] = x[i][2**17:]
                            row.append()

                        time.sleep(0.0)

                        table.flush()

               

        self.bs.done()


def test():

    filename = sys.argv[1]
    e = AllTHDNExperiment(filename, "Comprehensive Test for Board 05",
                          raw=False, balanced=True)

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
    b.gains = [100, 200, 500, 1000, 2000, 5000, 10000]
    #b.gains = [100]
    b.inChanB = 0
    b.inChanA = 0    
    #b.gains = [1]
    f1 = 100
    f2 = 10000
    #s.freqs = logspace(log10(f1), log10(f2), 20)
    s.freqs = linspace(f1, f2, 40)
    #s.freqs = array([100.0, 500.0, 1000.0, 10000.0])
    s.vpps = [3.9]

    e.bs = b
    e.ss = s
    e.chans = ['A2']
    e.run()

def QuickAllChannelTest(filename):

    """ Across all channels, we try and measure
    the THD+N at a single frequency / voltage just to make sure
    everything is working.

    """
    e = AllTHDNExperiment(filename, "A quick test of all chans",
                          raw=False, balanced=True)

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
    b.gains = [100, 200, 500, 1000, 2000, 5000, 10000]
    b.inChanB = 0
    b.inChanA = 0    
    s.freqs = array([1000.0])
    s.vpps = [3.9]

    e.bs = b
    e.ss = s
    e.chans = ['A1', 'A2', 'A3', 'A4', 'AC', 'B1', 'B2', 'B3', 'B4', 'BC']
    e.run()


if __name__ == "__main__":
    filename = sys.argv[1]

    #QuickAllChannelTest(filename)
    test()
