
from scipy import * 
from numpy import * 

import tables
import sys
sys.path.append("../sinlesq/")
import sinlesq as csinlesq

import pylab

import thdnMeasure



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
    

def manysegTHDNs(xorig, ns, fs):
    """
    Given a vector x and a list of segement lengths, where
    len(x) is an integer multiple of each n in ns, returns
    a list of arrays of THDN measurements

    """

    outputs = []
    N = len(xorig)
    x = array(xorig)
    for n in ns:
        print N, n,  N/n, 
        x.shape = (N/n, -1)
        print x.shape
        outputs.append(thdnMeasure.THDns(x, fs))

    return outputs

        

def plotmanysegns(ns, thdns):
    cl = list(colorlist)
        
    for pnum, thdn in enumerate(thdns):
        n = ns[pnum]
        q = len(thdn)
        pylab.plot(arange(q, dtype=float)/(q-1), thdn,
                   color = cl[0], label = "segment length = %d  " % n)
        
        pylab.axhline(mean(thdn), color = cl[0], linestyle = '--', 
                      label = "_nolegend_")
        cl.pop(0)
        pylab.grid()
        pylab.legend()
        leg = pylab.gca().get_legend()
        ltext  = leg.get_texts()  # all the text.Text instance the legend
        pylab.ylabel('THD + n')
        pylab.setp(ltext, fontsize='xx-small')    # the legendfontsize


def plotmanyTHDns():
    f = tables.openFile(sys.argv[1])

    h = io.read_array(file('HPF-as-fir.dat'))


    ns = [2**13, 2**11,  2**9]
    plots = [2, 10, 19]

    for pnum, i in enumerate(plots):
        pylab.subplot( len(plots), 1, pnum+1)
        cl = list(colorlist)

        for n in ns:
            t = f.root.A3.gain10000.hpf0.sine
            x = array(t[i][0], dtype=Float64)

            y = (x - mean(x)) /2**15

            fs = 32000

            #print  "before", t[i][1], max(y), min(y),
            #y = signal.convolve(h, y, mode='same')
            #print  "after", max(y), min(y)

            N = len(y)  / n
            y.shape = (N, -1)

            
            errs = empty_like(y)
            thdns = []
            params = []
            for j, yrow in enumerate(y):

                thdn = 0.0
                enob = 0.0

                (thdn, A, B, C, w)  = csinlesq.computeTHDN(yrow, fs)
                errs[j] = thdnMeasure.getSineError(yrow, A, B, C, w, fs)

                thdns.append(thdn)
                params.append((A, B, C, w))

            worst = argmax(array(thdns))
            best = argmin(array(thdns))



            b = errs[best]
            w = errs[worst]
            print n, len(thdns)
            
            pylab.plot(arange(N, dtype=float)/(N-1), thdns,
                       color = cl[0], label = "length %d segments " % n)
            pylab.axhline(mean(thdns), color = cl[0], linestyle = '--', 
                       label = "_nolegend_")
            cl.pop(0)
            pylab.grid()
            pylab.title("Freq = %d " % t[i][1])
            pylab.legend()
            leg = pylab.gca().get_legend()
            ltext  = leg.get_texts()  # all the text.Text instance the legend
            pylab.ylabel('THD + n')
            pylab.setp(ltext, fontsize='xx-small')    # the legendfontsize


    pylab.show()


plotmanyTHDns()
