% now also takes in an h

[bbut, abut] = butter(2, 38000, 's');
[bbes, abes] = besself(4, 15250); % 15300 is 10kHz -3dB
bb = conv(bbut, bbes);
ab = conv(abut, abes);

fstart = 1000;
fstop = 250000;

f = logspace(log10(fstart), log10(fstop), 10000);

s = f*j; 

hbbut = polyval(bbut, s);
habut = polyval(abut, s);
hbbes = polyval(bbes, s);
habes = polyval(abes, s);
hbb = polyval(bb, s);
hab = polyval(ab, s);



hbut=(hbbut./habut);
hbes=(hbbes./habes);
hb=(hbb./hab);

magbut = abs(hbut);
magbes = abs(hbes);
magb = abs(hb);

phasebut = unwrap(angle(hbut))*180/pi;
phasebes = unwrap(angle(hbes))*180/pi;
phaseb = unwrap(angle(hb))*180/pi;


figure;

semilogx(f, log10(magbut)*20, 'r');
hold;
semilogx(f, log10(magbes)*20, 'b');
semilogx(f, log10(magb)*20, 'gr');

besselres = log10(magbes)*20; 
pos = find(besselres < -3);
besselFc = besselres(pos(1)); 
fprintf('The bessel filter has a -3 db at %3.2f Hz\n', f(pos(1)));
butres = log10(magbut)*20; 
pos = find(butres < -3);
fprintf('The butterworth filter has a -3 db at %3.2f Hz\n', f(pos(1)));
bres = log10(magb)*20; 
pos = find(bres < -3);
fprintf('The combined (both) filter has a -3 db at %3.2f Hz\n', f(pos(1)));
bres = log10(magb)*20; 
pos = find(bres < -96);
fprintf('The combined (both) filter has a -96 db at %3.2f Hz\n', f(pos(1)));




line([128000 128000], [0, -110]);

axis([fstart, fstop, -110, 0]); 
ylabel('Magnitude (dB)'); 
xlabel('Frequency (Hz)'); 
grid; 




grdbut = -phasebut./f/360*1e6;
grdbes = -phasebes./f/360*1e6;
grdb = -phaseb./f/360*1e6;

figure; 
semilogx(f, grdbut, 'r');
hold; 
semilogx(f, grdbes, 'b');
semilogx(f, grdb, 'g');

ylabel('Group Delay (\mus)'); 
xlabel('Frequency (Hz)'); 
grid;


% here's where we unite analog and digital. Thank you, Alan
% Oppenheim!


w = linspace(0, pi, 10000);
flin = w/pi*128000;
slin = flin*j; 
hanalogb = polyval(bb, slin);
hanaloga = polyval(ab, slin);
hanalog=(hanalogb./hanaloga);


H = freqz(h, 1, w);
figure;

plot(flin/1000, 20*log10(abs(H)), 'g');
hold;
plot(flin/1000, 20*log10(abs(hanalog)), 'r'); 

plot(flin/1000, 20*log10(abs(H).*abs(hanalog)), 'b'); 
axis([0 32 -120 10]);
 
grid; 
line([10, 10], [-120,10], 'Color', 'k', 'LineStyle', '--');
line([16, 16], [-120,10], 'Color', 'k', 'LineStyle', '--');
ylabel('Magnitude (dB)'); 
xlabel('Frequency (kHz)'); 
