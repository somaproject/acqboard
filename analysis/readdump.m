function result = readdump(filename, col); 
% function result = readdump(filename); 
% designed to read n x 32-byte records from filename and turn
% them into n x 16 shorts


fid = fopen(filename, 'r'); 

a = fread(fid, inf, 'uint16'); 
fclose(fid); 

result = flipud(rot90(reshape(a,16, length(a)/16)));
