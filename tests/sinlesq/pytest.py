import sinlesq
from Numeric import *
from scipy import *

fs = 192000
t = r_[0.0, 0.1, 0.2]

t = array(t, Float64)
print type(t)

sinlesq.computeTHDN(t, 192000)
