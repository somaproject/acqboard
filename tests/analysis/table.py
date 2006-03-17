
import sys
import scipy
from scipy import *
import tables
#import sinleqsq
import pylab
import sinleqsq as pysinlesq
sys.path.append("../sinlesq/")
import sinlesq as csinlesq
from matplotlib.ticker import FormatStrFormatter


def FreqRes(table, volts):
    """
    computes the frequency response from a standard table using the
    specified voltage
    """
    pass


def THDnFromSineRow(sinrow, fs, segnum = 32):

    f = sinrow['frequency']
    x = sinrow['data']


    xr = x/2.0**15

    meanxr = mean(xr)
    xr = xr - meanxr

    #xo = pysinlesq.lpf(xr, 201, 13000., fs)
    xo = xr

    thdlist = []
    xlen = len(xo)/segnum
    #pylab.plot(xo[:200000])
    #pylab.show()

    for j in range(segnum):
        xrange = array(xo[xlen*j:xlen*(j+1)])
        thdn = 0.0
        enob = 0.0
        #y = scipy.round_(32768*xrange)/32768.0
        (thdn, A, B, C, w)  = csinlesq.computeTHDN(xrange, int(fs))
        m1 = max(xrange)
        m2 = min(xrange), 
        print thdn, fs, f, m1, m2 
        if thdn > -20:
            print "POOR THDN", thdn, fs, f, m1, m2, j
        else:
            thdlist.append(thdn)


    if len(thdlist) == 0:
        thdns = 0.
        thdnstd = 0.
    else:
        thdns = mean(thdlist)
        thdlist.sort()
        thdnstd = abs(max(thdlist) - min(thdlist))


    return (thdns, thdnstd)
    
def THDn(table, volt, filter=True, segnum = 100):


    freqs = []
    thdns = []
    thdnstd = []

    try:
        fs = table.attrs.fs
    except:
        fs = 192000
    for row in table.where(table.cols.sourcevpp == volt):
        print row
        freqs.append(row['frequency'])
        (th, ts) = THDnFromSineRow(row, fs, segnum)
        thdns.append( th)
        thdnstd.append( ts)

    return (freqs, array(thdns), array(thdnstd))

def freqResp(table, volt, gain):
    row = table

    result = [ (row['frequency'], row['data'])  for row in
               table.where(table.cols.sourcevpp == volt/gain)]

    freqs = zeros(len(result), Float64)
    logamps = zeros(len(result), Float64)
    

    print "the total number to read is", len(result)
    for i in range(len(result)):

        (f, x) =  result[i]
        
        xr = x/2.0**15
        meanxr = mean(xr)
        xr = xr - meanxr
        
        #xo = pysinlesq.lpf(xr, 201, 13000, fs)

        peak = max(xr)
        trough = min(xr)

        amplitude = (peak - trough)/2.0

        maxpeak = volt*gain/4.096
        logamp = 20*log10(amplitude/maxpeak)
        
        freqs[i] = f
        logamps[i] = logamp
    return (freqs, logamps)
        


def plotTHDnAllGains(filename, chan, hpfs, segnum = 32):
    """
    Create a plot of all gains in this particular
    point in the filespace.

    """

    f = tables.openFile(filename)
    changroup = f.groups["/%s" % chan]

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
    
                  
    allgains = changroup._f_listNodes()

    # sort by gain:
    allgains.sort(lambda x, y : x._v_attrs.gain- y._v_attrs.gain)

    maxfreq = 0
    for hpf in hpfs:
        for gg in allgains:
            gain = gg._v_attrs.gain
            print "THE GAIN IS",gain
            if hpf:
                st = gg._v_children["hpf1"].sine
            else:
                st = gg._v_children["hpf0"].sine


            # find the maximum voltage
            v = 0.0
            for r in st.iterrows():
                if v < r["sourcevpp"]:
                    v = r["sourcevpp"]

            
            (freqs, thdns, thdnstd) = THDn(st, v, filter=True, segnum=segnum)

            c = colorlist.pop(0)
            for i in freqs:
                if i > maxfreq:
                    maxfreq = i

            labelstr = "gain = %d, %3.2f dBFS " % (gain,
                                                   20*log10(v*gain/4.096))
            
            if hpf:
                labelstr += " hpf on"
            else:
                labelstr += " hpf off"

                
            pylab.plot(freqs, thdns,
                           color = c,
                           linewidth=1.5,
                           label = labelstr)

            thdnsp = thdns + thdnstd
            thdnsn = thdns - thdnstd
            x = concatenate( (freqs, freqs[::-1]) )
            y = concatenate( (thdnsn, thdnsp[::-1]) )
            pylab.fill(x, y, facecolor = c, 
                       edgecolor = (1.0, 1.0, 1.0),
                       alpha=0.1, label = "_nolegend_")


            #pylab.plot(freqs, thdns + thdnstd, 'r', label = "_nolegend_")
            #pylab.plot(freqs, thdns - thdnstd, 'r', label = "_nolegend_")



    pylab.legend()
    leg = pylab.gca().get_legend()
    ltext  = leg.get_texts()  # all the text.Text instance in the legend

    pylab.setp(ltext, fontsize='xx-small')    # the legend text fontsize


    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('THD+N (dB)')


    #pylab.title('root.AC.gain1.hpf0.sine')
    pylab.grid(1)
    pylab.axis((1, maxfreq, -95, -20))

    #ax.xaxis.set_major_locator(majorLocator)
    majorFormatter = FormatStrFormatter('%d')
    #ax.xaxis.set_major_formatter(majorFormatter)

    pylab.title("%s : %s" % (filename, chan))


def test(filename):
    f = tables.openFile(filename)
    table = f.root.A4.gain50.hpf0.sine

    #majorLocator = MultipleLocator(20)
    majorFormatter = FormatStrFormatter('%d')
    #minorLocator = MultipleLocator(5)

    ax = pylab.subplot(1,1,1)
    x
    for v in [(0.064, 'b')]:
        (freqs, thdns, thdnstd) = THDn(table, v[0])

        print "DONE WITH COMPUTATION"
        #(freqsunfilter, thdnsunfilter, thdnstdunfilter) = THDn(table, v[0],
        #                                                       False)
        
        pylab.plot(freqs, thdns, v[1], label = "%f Vpp" % v[0])
        pylab.plot(freqs, thdns + thdnstd, 'r', label = "_nolegend_")
        pylab.plot(freqs, thdns - thdnstd, 'r', label = "_nolegend_")
        
        #pylab.plot(freqs, thdnsunfilter)
        #pylab.plot(freqs, thdnsunfilter + thdnstdunfilter, 'r')
        #pylab.plot(freqs, thdnsunfilter - thdnstdunfilter, 'r')

    pylab.legend()
    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('THD+N (dB)')
    pylab.title('root.AC.gain1.hpf0.sine')
    pylab.grid(1)
    pylab.axis((0, 10000, -95, -50))

    #ax.xaxis.set_major_locator(majorLocator)
    ax.xaxis.set_major_formatter(majorFormatter)
    
    print "DONE"
    
    #

def plotFreqRespVsHPF(hpfenTable, hpfnotenTable, volt, gain):
    """
    Plot the freqresp of the same channel/source-voltage/gain from
    hpfenTable and Hpfnotentable
    """

    (f1, a1) = freqResp(hpfenTable, volt, gain)
    (f2, a2) = freqResp(hpfnotenTable, volt, gain)

    ax = pylab.subplot(1,1,1)

    pylab.semilogx(f1, a1, label = 'HPF Enabled',
                   linewidth = 2)
    pylab.semilogx(f2, a2, label = 'HPF Disabled',
                   linewidth = 2)
    
    pylab.legend()
    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('Magnitude (dB)')
    
    pylab.grid(1)
    
    

def plotBothFreqResp(filename):
    f = tables.openFile(filename)

    t1 = f.root.AC.gain100.hpf0.sine
    t2 = f.root.AC.gain100.hpf1.sine

    print "both" 
    plotFreqRespVsHPF(t1, t2, 3.9, 100.0)

def plotWave(filename):
    f = tables.openFile(filename)

    num = 10
    table = f.root.A1.gain1.hpf0.sine
    result = [ (row['frequency'], row['data'])  for row in
               table.where(table.cols.sourcevpp > 0 )]

    pylab.plot(result[num][1])
    print THDnFromSineRow(table[num], 32000) 
    print result[num][0]

def compWave(filename):
    f = tables.openFile(filename)

    num = 2
    t1 = f.root.A1.gain100.hpf1.sine
    r1 = [ (row['frequency'], row['data'])  for row in
               t1.where(t1.cols.sourcevpp > 0 )]

    x1= r1[num][1][:]


    fs = 32000
    N = len(x1)
    t =  r_[0.0:N]/ fs;

    (thdn, A1, B1, C1, w1) =  csinlesq.computeTHDN(x1, fs)
    x1m = (A1*cos(t*w1) + B1 * sin(t*w1) + C1)
    print "x1 thdn = ", thdn

    
    pylab.figure(1)
    pylab.plot(x1-x1m, label = "g=1")
    pylab.legend()
    pylab.grid()

    pylab.figure(2)
    pylab.plot(x1, 'r')
    pylab.plot(x1m, 'g')
    pylab.legend()
    pylab.grid()


    pylab.grid()

    test = []
    for i in range(100):
        test.append(mean(x1[(i*1000):((i+1)*1000)]))
    #pylab.plot(r_[0:100]*1000, test, 'r')
        

    #print result[num][0]
    

def noiseHist(filename):
    f = tables.openFile(filename)

    t1 = f.root.A1.noise.hpf0
    t2 = f.root.A1.noise.hpf1
    print "la = ", len(t1), len(t2)

    pos = 1
    bins = r_[-300:300]
    for r in t1.iterrows():
        pylab.figure(pos)
        x = r['data'].astype(Float64)
        #pylab.hist(x-mean(x), bins=bins)
        pylab.plot(x*4.096/2**16/r['gain']*1e6)
        pos += 1
        
        
def getNoise(table):
    # takes in a table of noise data and returns a tuple of
    # (gains, noisebits, noiserangeuv) 

    gains = []
    noisebitrange = []
    noiserangeuv = []
    bitvar = []
    rmsnoise = []

    for r in table.iterrows():
        x = array(r['data'], Float64)
        xv = x * 4.096/2**16/r['gain']
        rms = sqrt(mean(xv**2))
        rmsnoise.append(rms)
        a = max(r['data'])
        b = min(r['data'])
        gains.append(r['gain'])
        noisebitrange.append(a-b)
        bitvar.append(std(x))
        noiserangeuv.append(max(xv) - min(xv))

    return (gains, array(noisebitrange),
            array(noiserangeuv), array(rmsnoise), array(bitvar))
            

def measureNoise(filename):
    f = tables.openFile(filename)

    (g1, nb1, nv1, rv1, bstd1) = getNoise(f.root.A1.noise.hpf0)
    (g2, nb2, nv2, rv2, bstd2) = getNoise(f.root.A1.noise.hpf1)
    
    print g1, nv1
    
    pylab.scatter(g1, rv1*1e6, c='r')
    pylab.plot(g1, rv1*1e6, c='r')
    
    pylab.scatter(g2, rv2*1e6, c='b')
    pylab.plot(g2, rv2*1e6, c='b')

    
    pylab.xlabel('gain')
    pylab.ylabel('uV RMS')

    pylab.figure(2)
    pylab.scatter(g1, bstd1, c='r')
    pylab.plot(g1, bstd1, c='r')


    pylab.scatter(g2, bstd2, c='b')
    pylab.plot(g2, bstd2, c='b')

    
    pylab.xlabel('gain')
    pylab.ylabel('bit std dev')
    
    
    
    

def plotCMRR(filename):
    f = tables.openFile(filename)


    t= f.root.A1.gain10000.hpf1.sine

    freqs = []
    cmrrdB = []
    for (freq, dat, v) in  [ (row['frequency'], row['data'], row['sourcevpp'])  for row in t] :
        delta =  max(dat) - min(dat)
        vpp = float(delta) / 2**16 * 4.096 / 10000
        freqs.append(freq)
        cmrrdB.append( 20*log10(v / vpp))
        
    pylab.semilogx(freqs, cmrrdB)

    
    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('CMRR (dB)')
 
    pylab.axis([10., 10000., 0., 120.])
    pylab.grid(1)
    
    

def plotFreqResponse(filename):
    f = tables.openFile(filename)


    table = f.root.A2.gain10000.hpf1.sine
    ax = pylab.subplot(1,1,1)
    (freqs, amps) = freqResp(table, 4.05, 1)

    pylab.semilogx(freqs, amps)
    pylab.legend()
    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('Magnitude (dB)')
    pylab.title('root.AC.gain1.hpf0.sine')
    pylab.grid(1)
    #pylab.axis((0, 10000, -95, -70))

    #ax.xaxis.set_major_locator(majorLocator)
    #ax.xaxis.set_major_formatter(majorFormatter)
    
    print "DONE"
    
def thdnloop():

    trodes = ['A', 'B']
    chans = [1, 2, 3, 4]
    fname =  sys.argv[1]

    pylab.figure(1)
    for i, t in enumerate(trodes) :
        for j, cn in enumerate(chans):
            pylab.subplot(len(trodes), len(chans), i*len(chans)+j + 1)

            c = t + str(cn)
            
            plotTHDnAllGains(fname, c, [True, False])


    
if __name__ == "__main__":
    plotTHDnAllGains(sys.argv[1], 'B1', [False, True], 32)
    #thdnloop()
    #plotFreqResponse(sys.argv[1])
    #plotBothFreqResp(sys.argv[1])
    
    #compWave(sys.argv[1] )
    #measureNoise(sys.argv[1])
    #noiseHist(sys.argv[1])
    #plotCMRR(sys.argv[1])
    
    pylab.show()
