#!/usr/bin/python

import vhdltest
import unittest
import sys


suite = unittest.TestSuite()


if len(sys.argv) > 1 :
    # run those from the command line
    for i in sys.argv[1:]:
        suite.addTest(vhdltest.VhdlSimTestCase(i))
        
else:
    suite.addTest(vhdltest.VhdlSimTestCase("input"))

runner = unittest.TextTestRunner()
runner.run(suite)
