% now also takes in an h

[bf2, af2] = besself(2, 38000);
%[bf2, af2] = butter(2, 38000, 's');
[bf1, af1] = besself(4, 15250); % 15300 is 10kHz -3dB
bb = conv(bf2, bf1);
ab = conv(af2, af1);

fstart = 1000;
fstop = 250000;

f = logspace(log10(fstart), log10(fstop), 10000);

s = f*j; 

hbf2 = polyval(bf2, s);
haf2 = polyval(af2, s);
hbf1 = polyval(bf1, s);
haf1 = polyval(af1, s);
hbb = polyval(bb, s);
hab = polyval(ab, s);



hf2=(hbf2./haf2);
hf1=(hbf1./haf1);
hb=(hbb./hab);

magf2 = abs(hf2);
magf1 = abs(hf1);
magb = abs(hb);

phasef2 = unwrap(angle(hf2))*180/pi;
phasef1 = unwrap(angle(hf1))*180/pi;
phaseb = unwrap(angle(hb))*180/pi;


figure;

semilogx(f, log10(magf2)*20, 'r');
hold;
semilogx(f, log10(magf1)*20, 'b');
semilogx(f, log10(magb)*20, 'gr');

f1res = log10(magf1)*20; 
pos = find(f1res < -3);
f1Fc = f1res(pos(1)); 
fprintf('The first filter has a -3 db at %3.2f Hz\n', f(pos(1)));
f2res = log10(magf2)*20; 
pos = find(f2res < -3);
fprintf('The second filter has a -3 db at %3.2f Hz\n', f(pos(1)));
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




grdf2 = -phasef2./f/360*1e6;
grdf1 = -phasef1./f/360*1e6;
grdb = -phaseb./f/360*1e6;

figure; 
semilogx(f, grdf2, 'r');
hold; 
semilogx(f, grdf1, 'b');
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
