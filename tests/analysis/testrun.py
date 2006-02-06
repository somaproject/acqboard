import raw
import raw.runs

from scipy import *


rawh5file = raw.H5File("testing.h5", "My File")
sr = raw.runs.SineRun(rawh5file)
sr.name = "La2"
sr.gain = 100
sr.vpp = 4.08
sr.notes = "The notes"
sr.hpf = False
sr.channel = 'A1'
#sr.range =  logspace(log10(20), log10(40000), 10)
n = 30
r = zeros(n, Float);
#x = logspace(log10(997), log10(10000), n)
#for i in range(n):
#    print len(r), len(x), i
#    r[i] = raw.runs.intcycles(x[i], 2**16, 256000)
sr.range =  r_[3894.53125]
sr.run()

