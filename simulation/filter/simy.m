load output.dat;
load adcin.0.dat;
xlen = length(adcin);

x = zeros(10, xlen); 
x(1:2, :) = adcin'./2^15-1;

load adcin.1.dat;
x(3:4, :) = adcin'./2^15-1;
load adcin.2.dat;
x(5:6, :) = adcin'./2^15-1;
load adcin.3.dat;
x(7:8, :) = adcin'./2^15-1;
load adcin.4.dat;
x(9:10, :) = adcin'./2^15-1;

yact = output'./2^15; 
load filter.dat
h = filter/2^21; 

%first, we genetrate the ysim vecotrs which are our floating point
%simulated outputs

ylen = length(conv(h, x(1, :))); 
ysim = zeros(10, ylen); 
yout   = zeros(10, ylen); 


for i = 1:10 
  ysim(i, :) = conv(h, x(i, :));
end  

% we operate under the assumption that we have the initial impulse

for i = 1:10
  % downsample first 320 samples of simulated output
  
  % identify the max of both yact(1:40) and the downsampled ysim
  % align them
  shifts = zeros(1,8);
  vals = zeros(1,8); 
  
  for j = 0:7
    ydown = downsample(ysim(i, 1:320), 8, j); 
    [r, pldown] = max(ydown); 
    [r, plact] = max(yact(i, 1:40)); 
    yrot = circshift(ydown, pldown-plact); 
    shifts(j+1) = pldown -plact;
    vals(j+1) = sum((yrot-yact(i, 1:40)).^2);
  end
 
  [r, loc] = min(vals);
  dlen = length(downsample(ysim(i, :), 8, loc-1)); 
  yout(i, (1+shifts(loc)):((shifts(loc)+dlen))) = downsample(ysim(i,:), ...
						  8, loc-1); 
  
  figure
   plot(yact(i,:))
  hold
  plot(yout(i,1:200), 'g')
end
