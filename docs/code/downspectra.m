function [w, Yo, Ya] = downspectra(h, n)
% downsamples the spectra of h by n, n even power
% Yo == original part of signal
% Ya == aliases; 

wtot = 32768;
Yall = abs(fft(h, wtot)); 
Yrng = wtot/2; 
Y = Yall(1:(Yrng));

% initial 
Yo = 1/n*Y(1:(Yrng/n));
Ya = zeros(1,(Yrng/n)); 

w = linspace(0, pi, Yrng/n);
for i = 1:(n-1)
  
  Ya = Ya + 1/n*fliplr(Y((Yrng/n*i+1):(Yrng/n*(i+1)))); 
end

  
