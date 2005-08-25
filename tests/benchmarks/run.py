#!/usr/bin/python

"""actual code to create, run the data. How to do this...

For each raw run, the state will be stored as:


function generator freq
function generator amplitude
channel
gain
hpf
data


"""

from tables import *
from numarray import *
from test import *
from run import *



class Run:
    """ Run takes in an acqstate and a fstate, and a number of samples,
    and an hdf5 group, and appends a table to that group.

    for example:
         r = Run()
         r.acqstate = myacqstate
         r.fstate = myfstate
         r.run(len)
         r.save(loc, name)

    how does run know whether or not it's a raw? The problem is that the
    parsing code for raw vs non-raw is very very different, and in fact
    non-raw returns effectively 10 separate data streams.  

    acqstate determines whether it's a raw run or not.

    r.save for a raw simply saves the raw
    r.save(h5file, loc, name, chan) for a non-raw saves the non-raw channel

    

    """

    def __init__(self):
        self.acqstate = None
        self.fstate = None
        self.data = None

    def run(self, len):
        t = Test(self.acqstate,self.fstate)

        if self.acqstate.mode == 3:
            # raw!
            self.data = zeros(len, Int16)
            self.data = t.rawrun(len)
        else:
            # HERE IS WHERE WE PUT THE MULTI-CHANNEL CODE
            pass

    def save(self, h5file, group, name, chan=None):

    

        if self.acqstate.mode == 3:
            # raw save
            writeobj = self.data
        else:
            writeobj = self.data[chan]

        h5file.createArray(group, name, writeobj, name)
        a = h5file.leaves[group + "/" + name].attrs

        a.gains = str(self.acqstate.gains)
        a.hpfs = str(self.acqstate.hpfs)
        a.inchana = self.acqstate.inchana
        a.inchanb = self.acqstate.inchanb
        a.mode = self.acqstate.mode
        a.rawchan = self.acqstate.rawchan


        a.fmode = self.fstate.mode
        if self.fstate.mode == 4:
            a.famp = str(self.fstate.amp)
            a.ffreq = str(self.fstate.freq)
        else:
            a.famp = self.fstate.amp
            a.ffreq = self.fstate.freq

        a.foffset = self.fstate.offset
        
class Runs:
    """ This is a class where we keep often-used, often-needed runs.

    

    """

    def rawSineSet(self, chan, gain, h5file, group):
        """ coherent sampling, 128k samples, of multiple frequencies,
        multiple amplitudes. maxAmp is a float describing the maximum
        amplitude
        """

        # use N=[53, 141, 257, 1237, 2537]
        # M = 2**16
        freqs = [207.03125, 550.78125, 1003.90625, 4832.03125, 9910.15625]

        maxAmp = 4.000 / gain

        print "Beginning rawSineSet for channel %s, gain=%d, in group %s" \
              % (chan, gain, group)
        
        for freqi  in range(len(freqs)):
            for amp in [1.0, 0.20, 0.01]:
                print "starting test: freq=%f amp=%f" % (freqs[freqi], amp)

                
                f = FuncState()
                
                f.setmode("sine")
                f.freq = freqs[freqi]
                f.amp = maxAmp * amp
                

                
                a = AcqState()
                a.setmode("raw")
                a.rawchan = chan
                a.gains[chan] = gain

    
                r = Run()
                r.acqstate = a
                r.fstate = f
                r.run(128000)
                r.save(h5file, group, "rawSineSet_g%d_f%d_a%d" \
                       % (gain, freqi, amp*100))
                

    def rawSquareSet(self, chan, gain, h5file, group):
        """ 64k samples of square wave, of multiple amplitudes.
        maxAmp is a float describing the maximum amplitude.
        The frequency is 20 Hz, so at our 256 ksps we should see
        5 transitions, each roughly 12800 samples long. 
        """

        # use N=[53, 141, 257, 1237, 2537]
        # M = 2**16
        freq = 20 

        maxAmp = 4.000 / gain

        print "Beginning rawSquareSet for channel %s, gain=%d, in group %s" \
              % (chan, gain, group)
        
        for amp in [1.0, 0.20, 0.01]:
            
            
            
            f = FuncState()
            
            f.setmode("square")
            f.freq = 20.0
            f.amp = maxAmp * amp
                

                
            a = AcqState()
            a.setmode("raw")
            a.rawchan = chan
            a.gains[chan] = gain
            
            
            r = Run()
            r.acqstate = a
            r.fstate = f
            r.run(64000)
            r.save(h5file, group, "rawSquareSet_g%d_a%d" \
                   % (gain, amp*100))
                
    

    def noInputSet(self, chan, gain, h5file, group):
        """ Sampling of inputs shorted together. 
        """

        # use N=[53, 141, 257, 1237, 2537]
        # M = 2**16
        
        f = FuncState()
        
        f.setmode("sine")
        f.ffreq = 0
        f.famp = 0.00
        
        
        
        a = AcqState()
        a.setmode("raw")
        a.rawchan = chan
        a.gains[chan] = gain
        
    
        r = Run()
        r.acqstate = a
        r.fstate = f
        r.run(256000)
        r.save(h5file, group, "noinput_g%d" \
               % gain)
                
    



def simple_test():

    h5file = openFile("test.h5", mode = "w", title = "Test file")
    group = h5file.createGroup("/", 'raw', 'Raw outputs')


    
    f = FuncState()

    f.setmode("sine")
    f.freq = 964.84375
    f.amp = 0.038



    a = AcqState()
    a.setmode("raw")
    a.rawchan = 0
    a.gains = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    
    r = Run()
    r.acqstate = a
    r.fstate = f
    r.run(128000)
    r.save(h5file, "/raw", "testrun")
    
    
    h5file.close()
    
def rawsintest():
    
    h5file = openFile("sin.test.h5", mode = "w", title = "Test file")
    cgroup = h5file.createGroup("/", 'A1', 'Channel A1')
    tgroup = h5file.createGroup("/A1", "sine", 'sine inputs')
    
    r = Runs()
    r.rawSineSet("A1", 100, h5file, '/A1/sine')
    
    h5file.close()


        
if __name__ == "__main__":
    f = FuncState()
    #rawsintest()
