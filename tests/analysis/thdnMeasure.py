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

import numpy as n

def THDns(x, fs):
    """
    We take in rows of data and return a column of THDN measurements. 
    """

    # first, zero-mean

    rowcnt = len(x)
    meanxr = x.mean(1)
    meanxr.shape = (rowcnt, 1)
    xr = x - meanxr

    out = empty(len(x), Float)
    thdlist = []
    for i, xrow in enumerate(xr):
        
        thdn = 0.0
        enob = 0.0

        (thdnpy, A, B, C, w)  = pysinlesq.computeTHDN(xrow, int(fs))
        (thdnc, A, B, C, w)  = csinlesq.computeTHDN(xrow, int(fs))

        if thdnc < thdnpy:
            out[i] = thdnc
        else:
            out[i] = thdnpy

    return out

def THDnsFromTable(table, volt, segnum = 100, frequency= None):
    """
    Takes in a table of sine samples and returns a five-number summary


    """
    
    outrec = empty((len(table), 6), Float)

    try:
        fs = table.attrs.fs
    except:
        fs = 192000

    pos = 0

    if frequency == None:
        titerator = table.where(table.cols.sourcevpp == volt)
    else:
        titerator = [row for row in table.iterrows() if row['sourcevpp'] == volt  and row['frequency'] == frequency]
        
        
    for row in titerator:
        
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

def thdnSummary(filename, freq, gains, hpfs):
    """
    Takes in a filename and for that HDF5 file, generates
    a table of THD+N values across all channels, gains, for that frequency


    """

    volt = 3.9
    
    h5file = tables.openFile(filename)
    chanresults = []

    for name, chan in h5file.root._v_children.iteritems():
        results = []
        for g in gains:
            gaingroup = chan._v_children['gain%d' % g]

            for h in hpfs: 
                if h:
                    hpfgroup = gaingroup.hpf0
                else:
                    hpfgroup = gaingroup.hpf1

                table = hpfgroup.sine
                
                thdns = THDnsFromTable(table, volt/g, segnum = 64,
                                       frequency = freq)


                thdn = thdns[0][1]
                results.append(thdn)
        chanresults.append((name, results))
    return chanresults

def formatResults(filename, chanresults, gains, hpfs):

    fid = file(filename, 'w')

    fid.write("<html><body>\n")
    fid.write("<table>\n")

    # headers
    fid.write("<tr>\n")
    fid.write("<td>Channel </td>")
    for g in gains:
        for h in hpfs:
            fid.write("<TD><b> g=%d, hpf=%d</b> </TD>" % (g, h))
    fid.write("</tr>\n")

    for c in chanresults:
        fid.write("<tr>\n")
        fid.write("<td> %s </td>"  % c[0])
        for cr in c[1]:
            fid.write("<td> %3.1f </td>" % cr)
        fid.write('</tr>\n')
    
    fid.write("</table>")

    fid.write("</body><html>\n")

    fid.close()

def doSummary():
    gains = n.array([100, 200, 500, 1000, 2000, 5000, 10000])
    hpfs = [True, False]

    file = sys.argv[1]
    chanresults = thdnSummary(file, 1000.0, gains, hpfs)
    formatResults('/tmp/dummy.html', chanresults, gains, hpfs)
    
if __name__ == "__main__":

    doSummary()
    
#    chan = sys.argv[2]
#    x = fileTHDN(file, chan)

#    plotTHDNs(x)
#    pylab.show()
  
