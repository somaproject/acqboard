#!/usr/bin/python
"""
   Analysis of all system filter parameters

   Generates necessary plots, as well. 





"""

class filters:
    def __init__(self):
       
        """
        The anti-aliasing filter is composed of a cascade of a
        4th-order and a 2nd-order bessel
        """
        self.f1 = signal.bessel(4, 15250, analog=1)
        self.f2 = signal.bessel(2, 38000, analog=1)
        self.Fs = 256000
        self.dsN = 8
        
        self.h = signal.remez(143, [0, 10,  16, 127.99], [1,  0 ], [0.5,  1000], Hz=self.Fs/1000.0);

        
    def plotanalog(self):
        
        totalaf = (convolve(self.f1[0], self.f2[0]), convolve(self.f1[1], self.f2[1]))
        fstart = 1000
        fstop = 250000
        f = logspace(log10(fstart), log10(fstop), 10000)
        s = f*1j

        hf1 = polyval(self.f1[0], s)/polyval(self.f1[1], s)
        hf2 = polyval(self.f2[0], s)/polyval(self.f2[1], s)
        hftotal = polyval(totalaf[0], s)/polyval(totalaf[1], s)

        magf1 = abs(hf1)
        magf2 = abs(hf2)
        magtotal = abs(hftotal)

        phasef1 = unwrap(angle(hf1))*180/pi;
        phasef2 = unwrap(angle(hf2))*180/pi;
        phasetotal = unwrap(angle(hftotal))*180/pi;

        figure(1)
        semilogx(f, log10(magf1)*20, 'r')
        semilogx(f, log10(magf2)*20, 'b')
        semilogx(f, log10(magtotal)*20, 'g')

        plot([128000, 128000], [0, -110])
        axis([fstart, fstop, -110, 0])
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
        title('Frequency Response of analog filters')
        legend(('4-pole bessel', '2-pole bessel', 'Total'))

        grid(1)

        # calculate group delay in us
        grdf1 = -phasef1/f/360*1e6
        grdf2 = -phasef2/f/360*1e6
        grdtotal = -phasetotal/f/360*1e6
        
        figure(2)
        semilogx(f, grdf1, 'r');
        semilogx(f, grdf2, 'b');
        semilogx(f, grdtotal, 'g');

        ylabel(r'Group Delay ($\mu s$)') 
        xlabel('Frequency (Hz)') 
        grid(1)
        title('Group delay of analog filters')
        legend(('4-pole bessel', '2-pole bessel', 'Total'))

        show()
    def plotdigital(self):
        # uniting analog and digital
        # first, we convert the analog response into the corresponding digital
        # frequency response

        w = linspace(0, pi, 32768);
        flin = w/pi*128000;
        slin = flin*1j; 
        totalaf = (convolve(self.f1[0], self.f2[0]), convolve(self.f1[1], self.f2[1]))

        hanalog = polyval(totalaf[0], slin)/polyval(totalaf[1], slin)

        H = signal.freqz(self.h, [1.0], w)
        
        figure(1)
        plot(flin/1000, 20*log10(abs(H[1])), 'g')
        plot(flin/1000, 20*log10(abs(hanalog)), 'r')
        Y = abs(H[1])*abs(hanalog)
        plot(flin/1000, 20*log10(Y), 'b')

        grid(1)
        plot([10, 10], [-200,10], 'k--');
        plot([16, 16], [-200,10], 'k--');
        ylabel('Magnitude (dB)'); 
        xlabel('Frequency (kHz)'); 
        title(r'$\rm{Aggregate Spectra}Y(e^{j\omega})$')
        axis([0, 128, -180, 10])
        show()

        # now plot the downsampled total spectra
        figure(2)
        P = abs(H[1])
        P.shape = (self.dsN, size(Y)/self.dsN)
        flin.shape = (self.dsN, size(flin)/self.dsN)
        plot(flin[0, :]/1000, 20*log10(P[0, :]), 'b')
        grid(1)
        plot(flin[0, :]/1000, 20*log10(sum(P[1:8, ::-1])), 'r')
        

        
from scipy import *


from matplotlib.matlab import *

def main():
    x = filters()
    #x.plotanalog()
    x.plotdigital()
    
    

if __name__ == "__main__":
    main()
    
