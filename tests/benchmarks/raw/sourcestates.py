
from struct import *
import os
import sys
sys.path.append("../../")
import ATSio

class NoiseStates(object):
    pass

class SineStates(object):

    def __init__(self):

        self.__freqs = [1000.0]
        self.__vpps = [4.0]
        self.ats2 = None
        

    def setFreqs(self, value):

        for f in value:
            if not isinstance(f, float):
                raise "Gain is not an float"

        self.__freqs = value
                
    def getFreqs(self):
        return self.__freqs

    freqs = property(getFreqs, setFreqs)

    
    def setVpps(self, value):

        if not isinstance(value, list):
            raise "Vpps is not a list"
        for v in value:
            if not isinstance(v, float):
                raise "Vpp is not an float"

        self.__vpps = value
                
    def getVpps(self):
        return self.__vpps

    vpps = property(getVpps, setVpps)

    def setup(self, balanced):

        self.ats2 = ATSio.ATS.ATS2()        

        if balanced:
            self.ats2.output = 'bal'
        else:
            self.ats2.output = 'unbal'
      
        self.ats2.mode = 0
        self.ats2.onA = True


        for freq in self.__freqs:
            self.ats2.freq1 = freq
            readFreq = self.ats2.freq1

    def close(self):
        pass

    def vppIter(self, gain = 1.0):
        for v in self.__vpps:
            newv = v/gain
            self.ats2.ampVppA = newv

            yield newv

    def freqIter(self):
        for f in self.__freqs:
            self.ats2.freq1 = f
            yield f
            
