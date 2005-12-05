#!/usr/bin/python
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


def THDnFromSineRow(sinrow, fs):

    f = sinrow['frequency']
    x = sinrow['data']


    xr = x/2.0**15

    meanxr = mean(xr)
    xr = xr - meanxr

    #xo = pysinlesq.lpf(xr, 201, 13000., fs)
    xo = xr

    thdlist = []
    segnum = 8
    xlen = len(xo)/segnum
    #pylab.plot(xo)
    #pylab.show()

    for j in range(0, segnum):
        xrange = array(xo[xlen*j:xlen*(j+1)])
        thdn = 0.0
        enob = 0.0

        thdn = csinlesq.computeTHDN(round(32768*xrange)/32768.0, int(fs))
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
        thdnstd = abs(max(thdlist) - min(thdlist))

    return (thdns, thdnstd)
    
def THDn(table, volt, filter=True):


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
        (th, ts) = THDnFromSineRow(row, fs)
        thdns.append( th)
        thdnstd.append( ts)

    return (freqs, array(thdns), array(thdnstd))

def freqResp(table, volt, gain):
    row = table

    row = table
    result = [ (row['frequency'], row['data'])  for row in
               table.where(table.cols.sourcevpp == volt)]

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
        


def plotTHDnAllGains(filename, chan, hpfs):
    """
    Create a plot of all gains in this particular
    point in the filespace.

    """

    f = tables.openFile(filename)
    changroup = f.groups["/%s" % chan]
    ax = pylab.subplot(1,1,1)
    colorlist = [(1.0, 0., 0.),
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


            (freqs, thdns, thdnstd) = THDn(st, v, filter=True)

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

                
            pylab.semilogx(freqs, thdns,
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
    pylab.xlabel('Frequency (Hz)')
    pylab.ylabel('THD+N (dB)')


    #pylab.title('root.AC.gain1.hpf0.sine')
    pylab.grid(1)
    pylab.axis((1, maxfreq, -95, -20))

    #ax.xaxis.set_major_locator(majorLocator)
    majorFormatter = FormatStrFormatter('%d')
    ax.xaxis.set_major_formatter(majorFormatter)

    pylab.show()


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
    
    #pylab.show()

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
    pylab.show()
    

def plotBothFreqResp(filename):
    f = tables.openFile(filename)

    t1 = f.root.A1.gain1.hpf0.sine
    t2 = f.root.A1.gain1.hpf1.sine

    plotFreqRespVsHPF(t1, t2, 4.05, 1.0)

def plotWave(filename):
    f = tables.openFile(filename)


    table = f.root.A1.gain1.hpf0.sine
    result = [ (row['frequency'], row['data'])  for row in
               table.where(table.cols.sourcevpp > 0 )]
    pylab.plot(result[0][1][:10000])
    
    pylab.show()

def measureNoise(filename):
    f = tables.openFile(filename)

    table = f.root.A1.noise.hpf1
    gains = []
    noisebitrange = []
    noiserangeuv = []
    
    for r in table.iterrows():
        a = max(r['data'])
        b = min(r['data'])
        gains.append(r['gain'])
        noisebitrange.append(a-b)
        noiserangeuv.append((a-b)*(4.096e6/2**16)/r['gain'])
    #pylab.plot(gains, noisebitrange)
    ax1 = pylab.subplot(111)
    pylab.plot(gains, noisebitrange)
    pylab.scatter(gains, noisebitrange)
    pylab.ylabel('bits')
    ax2 = pylab.twinx()
    
    pylab.plot(gains, noiserangeuv, 'r')
    pylab.scatter(gains, noiserangeuv, c='r')
    pylab.ylabel('uV')
    pylab.xlabel('gain')
    pylab.grid(1)

    
    pylab.show()

def plotFreqResponse(filename):
    f = tables.openFile(filename)


    table = f.root.A4.gain10.hpf0.sine
    ax = pylab.subplot(1,1,1)
    (freqs, amps) = freqResp(table, 0.37, 1)

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
    
    pylab.show()
    
if __name__ == "__main__":
    plotTHDnAllGains(sys.argv[1], 'A1', [False, True])

    #plotTHDnAllGains(sys.argv[1], 'AC', False)
    #plotFreqResponse(sys.argv[1])
    #plotBothFreqResp(sys.argv[1])
    
    #plotWave(sys.argv[1])
    #measureNoise(sys.argv[1])
    
