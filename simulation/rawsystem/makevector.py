#!/usr/bin/python

#generates two columns of permutations of 0-(2^16-1)

import random


x = [0, 1, 2, 32765, 32766, 32767, 32768, 65534, 65535];
y = range(500)
d1 = []
d2 = []
for i in y :
    q1 = i*64 + random.randint(-100, 100)
   
    d1.append(min(65535, max(q1, 0)))

    q2 = i*64 + random.randint(-100, 100)
    
    d2.append(min(65535, max(q2, 0 )))


for i in x :
    d1.append(i)
    d2.append(i)
    
random.shuffle(d1)
random.shuffle(d2)

for i in range(len(d1)):
    print d1[i], d2[i]
