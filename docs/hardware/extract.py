#!/usr/bin/python
"""
Extract out the pages of the PDF so we can use them
"""

import os
from subprocess import Popen

srcfile = "../../pcb/acqboard.pdf"

pagedict = { 1 : "aafilter.pdf",
             2 : "adc.pdf",
             3 : "fpgapower.pdf",
             4 : "fpga.pdf",
             5 : "inmux.pdf",
             6 : "input.pdf",
             7 : "isolation.pdf",
             8 : "overview.pdf",
             9 : "shiftreg.pdf",
             10 : "pga.pdf",
             11 : "power.pdf"}

outdir = "schematicdir"
try:
    os.makedirs(outdir)
except:
    pass

for pgnum, filename in pagedict.iteritems():
    print "generating %s from page %d"  % (filename, pgnum)
    outpdf = os.path.join(outdir, filename)
    cmd = "pdftk %s cat %d output %s" % (srcfile, pgnum, outpdf)
    p = Popen(cmd, shell=True)
    sts = os.waitpid(p.pid, 0)

    filebase, pdfext = os.path.splitext(filename)
    # now convert to png
    
    outpng = os.path.join(outdir, filebase + ".png")
    cmd = "convert %s %s" % (outpdf, outpng)
    p = Popen(cmd, shell=True)
    sts = os.waitpid(p.pid, 0)
    
    
