#!/usr/bin/python
"""

How do we plot and measure our THD+N?

-- existing framework for measurement


"""

import sys
import scipy
from numpy import * 
from scipy import *
import tables

import pylab
sys.path.append("../sinlesq/")
import sinlesq as csinlesq
import pysinlesq
from matplotlib.ticker import FormatStrFormatter
import sets


def THDns(x, fs):
    """
    We take in rows of data and return a column of THDN measurements. 
    """

    # first, zero-mean
    print "thdns shape =", x.shape
    rowcnt = len(x)
    meanxr = x.mean(1)
    meanxr.shape = (rowcnt, 1)
    xr = x - meanxr

    out = empty(len(x), Float)
    thdlist = []
    for i, xrow in enumerate(xr):
        
        thdn = 0.0
        enob = 0.0

        (thdn, A, B, C, w)  = csinlesq.computeTHDN(xrow, int(fs))

        out[i] = thdn

    return out

def THDnsFromTable(table, volt, segnum = 100):
    """
    Takes in a table of sine samples and returns a five-number summary


    """
    
    outrec = empty((len(table), 6), Float)

    try:
        fs = table.attrs.fs
    except:
        fs = 192000

    pos = 0
    for row in table.where(table.cols.sourcevpp == volt):


        x = array(row['data'], Float)
        xn = x / 2.0**15

        xn.shape = (segnum, -1)
        
        ts = THDns(xn, fs)

        ts.sort()
        
        minval = ts[0]
        maxval = ts[-1]
        med = ts[len(ts)/2]
        ql = ts[len(ts)/4]
        qu = ts[len(ts)*3/4]
        
        outrec[pos] = (row['frequency'], minval, ql, med, qu, maxval)

        pos += 1 
        

    return outrec

def fileTHDN(filename, chan, segnum = 4):

    """

    generates a list of five-number summaries for each table in the THDn

    

    """

    f = tables.openFile(filename)
    changroup = f.groups["/%s" % chan]

    allgains = changroup._f_listNodes()

    # sort by gain:
    allgains.sort(lambda x, y : x._v_attrs.gain- y._v_attrs.gain)

    maxfreq = 0
    res = []
    for hpf in ['hpf0', 'hpf1']:
        for gg in allgains:
            gain = gg._v_attrs.gain
            try:
                st = gg._v_children[hpf].sine
            except:
                print "HPF ", hpf, " not implemented"
                
                
            # find the maximum voltage
            v = 0.0
            for r in st.iterrows():
                if v < r["sourcevpp"]:
                    v = r["sourcevpp"]

            
            thdntablenums = THDnsFromTable(st, v, segnum=segnum)

            res.append((gain, hpf, v, thdntablenums))

    return res


def plotTHDNs(ms):
    """
    Create a plot of all gains in this particular
    point in the filespace.

    """

    
    colorlist = [(1.0, 0., 0.),
                 (0., 1., 0.),
                 (0., 0., 1.),
                 (1., 0., 1.),
                 (0., 1., 1.),
                 (1., .5, .5),
                 (.5, .5, 1.),
                 (1., 1., 0), (1.0, 0., 0.),
                 (0., 1., 0.),
                 (0., 0., 1.),
                 (1., 0., 1.),
                 (0., 1., 1.),
                 (1., .5, .5),
                 (.5, .5, 1.),
                 (1., 1., 0)]
    
                  


    for (gain, hpf, v, thdns)  in ms: 

        c = colorlist.pop(0)

        labelstr = "gain = %d, %3.2f dBFS " % (gain,
                                               20*log10(v*gain/4.096))
        
        if hpf == "hpf1" :
            labelstr += " hpf on"
        else:
            labelstr += " hpf off"

        freqs = thdns[:, 0]
        thdnmeds = thdns[:, 3]
        thdnq1 = thdns[:, 1]
        thdnq3 = thdns[:, 5]
        print thdnmeds
        pylab.plot(freqs, thdnmeds, 
                   color = c,
                   linewidth=1.5,
                   label = labelstr)
        
        x = concatenate( (freqs, freqs[::-1]) )
        y = concatenate( (thdnq1, thdnq3[::-1]) )
        pylab.fill(x, y, facecolor = c, 
                   edgecolor = (1.0, 1.0, 1.0),
                   alpha=0.1, label = "_nolegend_")
        

    pylab.legend()
    leg = pylab.gca().get_legend()
    ltext  = leg.get_texts()  # all the text.Text instance in the legend

    pylab.setp(ltext, fontsize='xx-small')    # the legend text fontsize


    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('THD+N (dB)')


    #pylab.title('root.AC.gain1.hpf0.sine')
    pylab.grid(1)
    pylab.axis((1, 10050, -95, -30))

    #ax.xaxis.set_major_locator(majorLocator)
    majorFormatter = FormatStrFormatter('%d')
    #ax.xaxis.set_major_formatter(majorFormatter)


def getSineError(x, A, B, C, w, fs):
    """
    


    """
    t = arange(len(x), dtype=Float64)/fs

    y = A * sin(w*t) + B * cos(w*t) + C 

    err = y - x

    return err
    
if __name__ == "__main__":
    x = fileTHDN('/tmp/test.02.h5', 'B1')

    plotTHDNs(x)
    pylab.show()


    
