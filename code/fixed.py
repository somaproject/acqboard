#!/usr/bin/python

"""
Python fixed-point class. Supports addition, subtraction, and multiplication
"""




class fixed:
    def __init__(self, val, base):
        self.val = val
        self.base = base
        # base is the number of bits to the right of the
        # point

    def __add__(self, x):
        # the sum of two fixed point numbers should align their 
        # points, and return a result with the point at the same location
        # as the larger one

        r = min(self.base, x.base)
        if self.base < x.base:
            p = x.base - self.base
            return fixed(self.val*(2**p)+x.val, x.base)
        elif self.base > x.base:
            p = self.base - x.base
            return fixed(self.val + x.val*2**p, self.base)
        else:
            return fixed(self.val + x.val, self.base)

    def __mul__(self, x):
        v = self.val * x.val
        b = self.base + x.base
        return fixed(v, b)

    
    def __repr__(self):
        str = "%f" % (float(self.val) / (2**self.base))
        return str

    def trunc(self, val):
        # truncate this number to only have val bits after the point
        if val < self.base :
            v = self.val / 2**(self.base-val)
            b = val
        else:
            v = self.val
            b = self.base
        return fixed(v, b)
        
    def convrnd(self, point):
        # performs convergent rounding of a value
        # for a result with the point at point

        pow = 2**(self.base-point)
        q = (self.val % pow)
        
        if q > (pow / 2):
            v = self.val / pow + 1
            b = point
        elif q < (pow / 2):

            v  = self.val /pow
            b = point
        else:
            if ( (self.val / pow) % 2) == 0:
                # even
                v = self.val / pow 
                b = point
            else:
                v = self.val / pow + 1
                b = point
        return fixed(v, b)
    
    def overf(self, a):
        # returns a value which is equal to the present value if
        # the present value can be expressed as an a.b number, otherwise
        # (i.e. overflow) returns the max or min value in a.base
        
        if self.val >= 2**(a+self.base - 1):
            return(fixed(2**(a+self.base-1)-1, self.base))
        elif self.val < -2**(a+self.base -1):
            return(fixed(-2**(a+self.base -1), self.base))
        else:
            return self
        
        
        
if __name__ == '__main__':
    a = fixed(1, 1)
    b = fixed(2, 0)
    c = a + b

    x = fixed(9,2) # 2.25
    y = fixed(25, 3) # 3.125
    
    print c.val, c.base
    print c
    print x*y

    r = x * y
    r.trunc(1)
    print r

    x = fixed(3, 1)
    y = fixed(1,1)
    r = x * y
    print r
    r.trunc(1)
    print r

    # convergent rounding stuff

    a = fixed(14, 3)
    a.convrnd(1)
    print a
    
    # overflow stuff
    a=fixed(4, 2)
    print a, a.overf(1)
    
