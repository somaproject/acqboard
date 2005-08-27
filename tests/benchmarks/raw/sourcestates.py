
from struct import *
import os
import sys
sys.path.append("../../")
import ATSio


class SineStates:

    def __init__(self):

        self.__freqs = [1000.0]
        self.__vpps = [4.0]
        self.ats2 = None
        

    def setFreqs(self, value):

        if not isinstance(value, list):
            raise "Freqs is not a list"
        for f in value:
            if not isinstance(f, float):
                raise "Gain is not an float"

        s.__freqs = value
                
    def getFreqs(self):
        return self.__freqs

    freqs = property(getFreqs, setFreqs)

    
    def setVpps(self, value):

        if not isinstance(value, list):
            raise "Vpps is not a list"
        for v in value:
            if not isinstance(v, int):
                raise "Vpp is not an int"

        s.__vpps = value
                
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
            #result = read.read(2**16)
            # we're not actually doing anything with it yet
            #plot(result[0:2048])
            #sinerun.append(freq, self.vpp, result)
        

    def vppIter(self):
        for v in self.__vpps:
            self.ats2.ampVppA = v

            yield v

    def freqIter(self):
        for f in self.__freqs:
            self.ats2.freq1 = f
            yield f
            
