#!/usr/bin/python
"""

This is where we create the code for the various runs


"""


import sys
sys.path.append("../analysis")
import run
from test import *
import os
import tempfile
import tables

def getnotes():
    """ pops up an editor to get the metadata notes for a file,
    based on $EDITOR

    """
    tf = tempfile.NamedTemporaryFile()
    
    editor = "emacs"
    if os.environ.has_key('EDITOR'):
        editor = os.environ['EDITOR']
    os.system("%s %s" % (editor, tf.name))
    
    fid = file(tf.name, 'r')
    
    text = fid.read()
    
    fid.close
    return text

class data:

    allchans = ['A1', 'A2', 'A3', 'A4', 'AC',
                'B1', 'B2', 'B3', 'B4', 'BC']
    allgains = [0, 100, 200, 500, 1000, 2000, 5000, 10000]
    

    def __init__(self, filename, message=None):
        
        self.filename = filename

        if not message:
            self.setnotes()
        else:
            self.notes = message

    def setnotes(self):
        self.notes = getnotes()
        
    def basicrawsine(self, gains, channels):
        """
        Runs a basic raw sine and saves the data in filename, for the
        channels in channels
        
        """
        
        h5file = tables.openFile(self.filename, mode = "w", title = "Test file")

        for c in channels:

                cgroup = h5file.createGroup("/", c, 'Channel %s' % c)
                tgroup = h5file.createGroup("/%s" % c, "sine", 'sine inputs')

                for g in gains:
                    r = run.Runs()
                    r.rawSineSet(c, g,  h5file, '/%s/sine' % c)
    
        h5file.close()


    def inputnoise(self, gains, channels):
        """
        Runs a basic raw sine and saves the data in filename, for the
        channels in channels
        
        """
        
        h5file = tables.openFile(self.filename, mode = "w", title = "Test file")

        for c in channels:

                cgroup = h5file.createGroup("/", c, 'Channel %s' % c)
                tgroup = h5file.createGroup("/%s" % c, "noinput", 'Noise with no input"')

                for g in gains:
                    r = run.Runs()
                    r.noInputSet(c, g,  h5file, '/%s/noinput' % c)
    
        h5file.close()


    def basicrawsquare(self, gains, channels):
        """
        Runs a basic raw sine and saves the data in filename, for the
        channels in channels
        
        """
        
        h5file = tables.openFile(self.filename, mode = "w", title = "Test file")

        for c in channels:

                cgroup = h5file.createGroup("/", c, 'Channel %s' % c)
                tgroup = h5file.createGroup("/%s" % c, "square", \
                                            'squre inputs')

                for g in gains:
                    r = run.Runs()
                    r.rawSquareSet(c, g,  h5file, '/%s/square' % c)
    
        h5file.close()







if __name__ == "__main__":
    d = data("test.h5", "test data")
    d.inputnoise([100, 200], ['A1'])


