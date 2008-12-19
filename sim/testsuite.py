#!/usr/bin/python

from vhdltest import vhdltest
import unittest
import sys


suite = unittest.TestSuite()


if len(sys.argv) > 1 :
    # run those from the command line
    for i in sys.argv[1:]:
        suite.addTest(vhdltest.VhdlSimTestCase(i))
        
else:
    suite.addTest(vhdltest.VhdlSimTestCase("acqcmd"))
    suite.addTest(vhdltest.VhdlSimTestCase("fibertx"))

    suite.addTest(vhdltest.VhdlSimTestCase("filter"))
    # we need to do some post-processing for filter
    
    suite.addTest(vhdltest.VhdlSimTestCase("input"))
    suite.addTest(vhdltest.VhdlSimTestCase("mac"))
    suite.addTest(vhdltest.VhdlSimTestCase("pgaload"))
    suite.addTest(vhdltest.VhdlSimTestCase("raw"))
    suite.addTest(vhdltest.VhdlSimTestCase("rmac"))


runner = unittest.TextTestRunner()
runner.run(suite)
