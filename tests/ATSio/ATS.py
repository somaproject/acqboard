#!/usr/bin/python


"""

Very basic wrapper around the ATS GPIB interface.


"""

from Gpib import *
import re

class Modes:
    SINE = 0
    NOISE = 1
    SQUARE = 2
    

class ATS2(object):
    def __init__(self):
        self.gpib  = Gpib('ats2'); 
        self.gpib.clear()
        

    def setAmpVppA(self, val):
        self.gpib.write(":AGEN:AMPL A,%fVPP" % val)

    def getAmpVppA(self):
        self.gpib.write(":AGEN:AMPL? A,VPP")
        response = self.gpib.read(1024)
        valmatch = re.search(":AGEN:AMPL A,([\d\.]+)VPP", response)
        return float(valmatch.groups()[0])
    
    ampVppA = property(getAmpVppA, setAmpVppA)

    def setAmpVppB(self, val):
        self.gpib.write(":AGEN:AMPL B,%fVPP" % val)


    def getAmpVppB(self):
        self.gpib.write(":AGEN:AMPL? B,VPP")
        response = self.gpib.read(1024)
        valmatch = re.search(":AGEN:AMPL B,([\d\.]+)VPP", response)
        return float(valmatch.groups()[0])
    
    ampVppB = property(getAmpVppB, setAmpVppB)

    def setOutput(self, val):
        if val == "bal":
            self.gpib.write(":AGEN:CONFIG BAL")
        elif val == "unbal":
            self.gpib.write(":AGEN:CONFIG UNBAL")
        else:
            raise TypeError

    def getOutput(self):
        self.gpib.write(":AGEN:CONFIG?")
        response = self.gpib.read(1024)
        valmatch = re.search(":AGEN:CONFIG (\w+)", response)
        if valmatch.groups()[0] == "BAL":
            return "bal"
        elif valmatch.groups()[0] == "UNBAL":
            return "unbal"
        else:
            raise TypeError
        
    output = property(getOutput, setOutput)

    def setFreq1(self, val):
        self.gpib.write(":AGEN:DASINE:FRQ1 %fHZ" % val)


    def getFreq1(self):
        self.gpib.write(":AGEN:DASINE:FRQ1? HZ")
        response = self.gpib.read(1024)
        valmatch = re.search(":AGEN:DASINE:FRQ1 ([\d\.]+)HZ", response)
        return float(valmatch.groups()[0])
    
    freq1 = property(getFreq1, setFreq1)

    def setFreq2(self, val):
        self.gpib.write(":AGEN:DASINE:FRQ2 %fHZ" % val)


    def getFreq2(self):
        self.gpib.write(":AGEN:DASINE:FRQ2? HZ")
        response = self.gpib.read(1024)
        valmatch = re.search(":AGEN:DASINE:FRQ2 ([\d\.]+)HZ", response)
        return float(valmatch.groups()[0])
    
    freq2 = property(getFreq2, setFreq2)

    def setMode(self, val):
        if val == Modes.SINE :
            self.gpib.write(":AGEN:WFM DASINE,STER")

    def getMode(self):
        self.gpib.write(":AGEN:WFM?")
        response = self.gpib.read(1024)
        print response
        if response == ":AGEN:WFM DASINE,STEREO\n":
            return Modes.SINE
        else:
            raise TypeError, "INvalid mode returned"

    mode = property(getMode, setMode)


    def setOnA(self, val):
        
        self.gpib.write(":AGEN:OUTPUT?")
        response = self.gpib.read(1024)
        if val:
            if response == ":AGEN:OUTPUT B\n":
                self.gpib.write(":AGEN:OUTPUT AB")
            else:
                self.gpib.write(":AGEN:OUTPUT A")
        else:
            if response == ":AGEN:OUTPUT AB\n":
                self.gpib.write(":AGEN:OUTPUT B")
            elif response == ":AGEN:OUTPUT B\n":
                pass
            else:
                self.gpib.write(":AGEN:OUTPUT OFF")
    
    def getOnA(self):
        self.gpib.write(":AGEN:OUTPUT?")
        response = self.gpib.read(1024)
        if response == ":AGEN:OUTPUT A\n":
            return True
        elif response == ":AGEN:OUTPUT AB\n":
            return True
        else:
            return False

    onA = property(getOnA, setOnA)
        
    def setOnB(self, val):
        
        self.gpib.write(":AGEN:OUTPUT?")
        response = self.gpib.read(1024)
        if val:
            if response == ":AGEN:OUTPUT A\n":
                self.gpib.write(":AGEN:OUTPUT AB")
            else:
                self.gpib.write(":AGEN:OUTPUT B")
        else:
            if response == ":AGEN:OUTPUT AB\n":
                self.gpib.write(":AGEN:OUTPUT A")
            elif response == ":AGEN:OUTPUT A\n":
                pass
            else:
                self.gpib.write(":AGEN:OUTPUT OFF")
    
    def getOnB(self):
        self.gpib.write(":AGEN:OUTPUT?")
        response = self.gpib.read(1024)
        if response == ":AGEN:OUTPUT B\n":
            return True
        elif response == ":AGEN:OUTPUT AB\n":
            return True
        else:
            return False

    onB = property(getOnB, setOnB)
        
            
def main() :
    a = ATS2()
    #a.gpib.write(":AGEN:DASINE:FRQ1 31000.4Hz")
    #a.gpib.write(":AGEN:DASINE:FRQ2 31000.4Hz")
    #a.gpib.write("ERRS?")
    #print a.gpib.read(2041) 
    #a.gpib.write(":AGEN:SET?")

    a.freq1 = 1000.0
    a.ampVppA = 0.039
    a.onA = True
    a.onB = True
    a.output = 'bal'

    print a.onA
    print a.freq1
    print a.output
if __name__ == "__main__":
    main()
