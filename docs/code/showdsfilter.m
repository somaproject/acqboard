function [] = showdsfilter(h)
% just plots our downsampled filter, and the noise floor created
% by the aliases, using 8x downsampling


[w, Yo, Ya] = downspectra(h, 8);
figure;  
plot(w/pi*16000, 20*log10(Yo*8));    
hold;
grid; 

plot(w/pi*16000, 20*log10(Ya*8), 'r');
plot(w/pi*16000, 20*log10(Ya*8+Yo*8), 'g'); 

xlabel('Frequency (Hz)'); 
ylabel('dB'); 

