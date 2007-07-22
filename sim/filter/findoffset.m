% try and find the offset
% we have an input vector y, which is the post-filtered downsampeld
% version of the data
% we have x, the original data, and h, the filter
%


% conv x with h, to get resulting filter

len = length(downsample(h, 8)); 
hm = zeros(8, len); 
for i = 0:7
  hm(i+1, :) = downsample(h, 8, i)'; 
end 


yd = output(1:40,1)'/2^15; 


% for each subregion, line up peak, then take difference

os = zeros(1,8);
shift = zeros(1,8); 

for q = 0 : 7
  [r, i] = max(yd);
  [r, j] = max(hm(q+1, :));
  hshift = [zeros(1, i-j), hm(q+1,:), zeros(1, length(yd)-length(hm(q+1,:))-(i-j))];
  hshift = hshift * 2; 
  os(q+1) = sum((yd-hshift).^2);
  shift(q+1) = i-j; 
  figure;
  plot(hshift);
  hold
  plot(yd, 'r'); 
  
end

[r, s] = min(os); 
s
