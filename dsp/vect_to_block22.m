function  vect_to_block22(input, init)
% vect_to_block takes a vector of type double with between -1 and 1, 
% quantizes the values to acceptable 22-bit twos-complement fixed
% point values, and then writes out the values in hex in a format
% optimized for copying and pasting into the BlockSelect+ RAM vhdl
% declarations. 
%
% keep in mind that this needs the blocks to be configured as
% 256x16, and the format is standard hex, except that (somewhat
% confusingly) the first word (location zero) is furthest to the
% right. 

% first, we quantize
h_quant = fxquant(input, 22, 'round', 'sat');
h = h_quant * 2^21;
h(h<0) = h(h<0)+2^22; 

% then we create a 256x32 matrix of the bits
values = zeros(128, 32); 


for i = 1:length(input)
  tempbin = zeros(1,32); 
  x = dec2bin(h(i)); % convert to a string, note that x(1) is MSB
  x = x > '0';  %create actual binary vector
  
  if(length(x) == 22) % if the vector is 22 long it must be negative
    tempbin(1:10) = 1;
  end;
  tempbin = tempbin + ( [zeros(1, 32-length(x)) x]); 
  
  values(i, :) = tempbin;
end ; 


% create two empty vectors to later partition into lines
fprintf(' Lower Word Block Arrays: \n\n'); 

for i = 1:8 
  if (init == 1) 
    fprintf('INIT_0%d => X"', i-1); 
  end 
  for j = (i*16):-1:((i-1)*16+1)
    fprintf('%0.4X', bin2dec(sprintf('%d', values(j, 17:32))))
  end
  if (init == 1) 
    fprintf('",'); 
  end 
  fprintf('\n'); 
end 
    
fprintf(' Upper Word Block Arrays: \n\n'); 

for i = 1:8 
  if (init == 1) 
    fprintf('INIT_0%d => X"', i-1); 
  end 
  for j = (i*16):-1:((i-1)*16+1)
    fprintf('%0.4X', bin2dec(sprintf('%d', values(j, 1:16))))
  end
  if (init == 1) 
    fprintf('",'); 
  end 
  fprintf('\n'); 
end 







