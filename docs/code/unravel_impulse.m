function impulseout = unravel_impulse(impres); 
% function impulseout = unravel_impulse(impres) 
%
% unravels the output from the impulse data. 
% 
% since our filter decimates by 8, to view the impulse response we
% need to send in 8 separate impulses with delays ranging from
% 0-7. Then we need to reassemble the 8 data streams we get out. 
%
% using the testvectors acqboard.test_ADC.impulse.n.dat, we can use
% this to actually see our impulse response. 

impresr = fliplr(impres); 
[x,y] = size(impres); 

impulseout = reshape(flipud(rot90(impresr)), 1, x*y);
