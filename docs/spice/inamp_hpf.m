x=loadsig('inamp_hpf.ac.ac0'); 
f = evalsig(x, 'HERTZ');  
vin = abs(evalsig(x, 'vin_')); 
vout = abs(evalsig(x, 'vout'));

semilogx(f,20*log10(vout/100/vin));
