#!/usr/bin/python


""" Simple interface via serial to the SRS DS360


func.setfreq(Hz)
func.setamp(double, vPP)
func.setsine()
func.setnoise()



"""


def truncstr(value):
    # turns value into a string and trunkates it at 6 figures

    s = "%6.6f" % value
    if abs(value) < 1.0:
        return s[0:7]
    else:
        return s[0:7]


import serial

class SRSfunc:

    def __init__(self, serialport):

        # we assume 9600 8N2
        self.serial = serial.Serial(serialport, 9600, stopbits=2)

        # initialize
    def setoutputenable(self,  state):
        if state == "on":
            self.serial.write("OUTE 1\n")
        elif state == "off":
            self.serial.write("OUTE 0\n")

    def setbalanced(self):
        self.serial.write("OUTM 1\n")

    def setunbalanced(self):
        self.serial.write("OUTM 0\n")
        

    def setmode(self, mode):
        print "Setting mode to ", mode
        self.serial.write("FUNC %d\n" % mode)
        self.serial.write("FUNC? \n")
        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        self.mode = int(float(resultstr))

    def setsine(self):
        self.serial.write("FUNC 0\n")
        self.serial.write("FUNC? \n")
        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        self.mode = int(resultstr)
        
        
    def setnoise(self):
        self.serial.write("FUNC 2\n")
        self.serial.write("FUNC?\n")
        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        self.mode = int(resultstr)
        
    def setoffset(self, os):
        """ Sets an offset voltage, only works when output is unbalanced"""

        self.serial.write("OFFS %s\n" % truncstr(os))

        self.serial.write("OFFS?\n")

        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        resultstr = resultstr[0:(len(resultstr)-1)]
        self.offset =  float(resultstr) 


    def setfreq(self, freq):
        """ sets the frequency in Hz,
        unless freq is a tuple, in which case we set the
        two-tone frequencies"""

        if isinstance(freq, float):

            self.serial.write("FREQ %s\n" % truncstr(freq))
            self.serial.write("FREQ?\n")

            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()

            resultstr = resultstr[0:(len(resultstr)-1)]
            self.freq =  float(resultstr) 
        elif isinstance(freq, tuple):
            self.serial.write("TTAF %s\n" % truncstr(freq[0]))
            self.serial.write("TTAF?\n")

            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()

            resultstr = resultstr[0:(len(resultstr)-1)]
            freqA =  float(resultstr) 

            self.serial.write("TTBF %s\n" % truncstr(freq[1]))
            self.serial.write("TTBF?\n")

            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()

            resultstr = resultstr[0:(len(resultstr)-1)]
            freqB =  float(resultstr) 

            self.freq = (freqA, freqB)

            

    
    def setamp(self, amp):
        """ Sets the amplitude in volts (decimal values okay).
        note that if amp is a tuple, we actually set the IMD
        amp values, ToneA and ToneB"""

        if isinstance(amp, float):
            
            outstr = "AMPL %sVP\n" % truncstr(amp)
          
            self.serial.write(outstr)
            
            self.serial.write("AMPL? VP\n")
            
            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()
                
            resultstr = resultstr[0:(len(resultstr)-1)]
            
            self.amp = float(resultstr)
        elif isinstance(amp, tuple):
            
            
            outstr = "TTAA %sVP\n" % truncstr(amp[0])
            
            self.serial.write(outstr)
            
            self.serial.write("TTAA? VP\n")
            
            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()
                
            resultstr = resultstr[0:(len(resultstr)-1)]
            ampA = float(resultstr)


            outstr = "TTBA %sVP\n" % truncstr(amp[1])
            self.serial.write(outstr)
            self.serial.write("TTBA? VP\n")
            
            resultstr = ""
            while resultstr.find('\n') == -1:
                resultstr += self.serial.read()
                
            resultstr = resultstr[0:(len(resultstr)-1)]
            ampB = float(resultstr)

            self.amp = (ampA, ampB)
            
 

def main():
    r = SRSfunc(0)

    r.setmode(0)
    print "The mode is %d" % r.mode
    r.setfreq(769.53125)
    print "The frequency is %f"  % r.freq 
    r.setamp(3.7736)
    print "The amplitude is %f " % r.amp

    r.setunbalanced()
    r.setoffset(0.10)
    
    print "The offset is %f " % r.offset
    raw_input()

    r.setmode(4)
    print "The mode is %d" % r.mode
    r.setfreq((769.53125, 1000))
    print "The A freq is %f Hz, the b %f Hz"  % r.freq 
    r.setamp((3.7736, 1.2))
    print "The amplitude is %f, %f " % r.amp

    r.setbalanced()
   
    
    
    
if __name__ == "__main__":
    main()
    
        
