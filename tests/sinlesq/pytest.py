import sinlesq
from Numeric import *
from scipy import *

fs = 31250
x = io.read_array('/home/jonas/adtest.dat')
y = array(x, Float64); 


print sinlesq.computeTHDN(y[:2**14], fs)
