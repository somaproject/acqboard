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
        

    def setfreq(self, freq):
        """ sets the frequency in Hz"""

        self.serial.write("FREQ %s\n" % truncstr(freq))

        self.serial.write("FREQ?\n")

        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        resultstr = resultstr[0:(len(resultstr)-1)]
        print resultstr
        self.freq =  float(resultstr) 

    def setamp(self, amp):
        """ Sets the amplitude in volts (decimal values okay)"""
        outstr = "AMPL %sVP\n" % truncstr(amp)
        print outstr
        self.serial.write(outstr)

        self.serial.write("AMPL? VP\n")

        resultstr = ""
        while resultstr.find('\n') == -1:
            resultstr += self.serial.read()

        resultstr = resultstr[0:(len(resultstr)-1)]
        
        self.amp = float(resultstr)


def main():
    r = SRSfunc(0)

    r.setnoise()
    print "The mode is %d" % r.mode
    r.setfreq(769.53125)
    print "The frequency is %f"  % r.freq 
    r.setamp(3.7736)
    print "The amplitude is %f " % r.amp

    
if __name__ == "__main__":
    main()
    
        
