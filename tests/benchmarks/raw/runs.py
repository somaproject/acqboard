"""




"""

import HDF5File
import read
import socket

from matplotlib.pylab import *
from struct import *
import os
import sys
sys.path.append("../../acqboardcmd")
sys.path.append("../acqboardcmd")
sys.path.append("../")
import ATSio.ATS
import ATSio.ATS
import acqboardcmd
import acqboard
import time


def intcycles(freq, reclen, fs):
    """ Returns the frequency closest to freq that will give you an
    integer number of cycles in a record of reclen length when sampled at
    fs"""

    x = reclen/float(fs)*freq
    if round(x) % 2 > 0:
        n = round(x)/(reclen/float(fs))
    else:
        n = round(x+1.0)/(reclen/float(fs))
    
    return n


class SineRun:
    def __init__(self, h5file):
        self.h5file = h5file

        self.name = None
        self.channel = None
        self.range = None
        self.gain = None
        self.hpf = None
        self.vpp = None

        self.note = ""

        self.acqout = acqboard.AcqSocketOut()
        self.acqout.open()
        self.acqcmd = acqboardcmd.AcqBoardCmd()
        self.acqstat = acqboard.AcqSocketStat()

        self.acqstat.open()
        
        self.ats2 = ATSio.ATS.ATS2()
        
    def run(self):
        if self.name == None:
            raise TypeError, "name not set"
        if self.channel == None:
            raise TypeError, "channel not set"
        if self.range == None:
            raise TypeError, "range not set"
        if self.gain == None:
            raise TypeError, "gain not set"
        if self.hpf == None:
            raise TypeError, "hpf not set"
        if self.vpp == None:
            raise TypeError, "vpp not set"

        # open the file
        
        rafChan = self.h5file.openChan(self.channel)
        print self.name, self.gain, self.hpf, self.note
        
        sinerun = rafChan.addSineRun(self.name, self.note, self.gain, self.hpf)
        
        # set the protointerface board state
        
        self.acqout.send(self.acqcmd.switchmode(3, rawchan=self.channel))
        self.acqstat.read()
        

        
        self.acqout.send(self.acqcmd.setgain(self.channel, self.gain))
        self.acqstat.read()
        # here is where we set HPF
        self.acqout.send(self.acqcmd.sethpfilter(self.channel, self.hpf))
        self.acqstat.read()
        

        # now, the function generator
        self.ats2.ampVppA = self.vpp
        self.ats2.output = 'unbal'
        self.ats2.mode = 0
        self.ats2.onA = True


        for freq in self.range:
            self.ats2.freq1 = freq
            readFreq = self.ats2.freq1
            result = read.read(2**16)
            # we're not actually doing anything with it yet
            #plot(result[0:2048])
            sinerun.append(freq, self.vpp, result)
        
        
