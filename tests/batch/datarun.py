#!/usr/bin/python

"""
Storage format for data run, in HDF5

"""

import tables
from numeric import *



# Open a new empty HDF5 file
filename = "testarray.h5"
fileh = openFile(filename, mode = "w")
# Get the root group
root = fileh.root

