* SPICE model of instrumentation amplifier

.options post

.ac dec 10 100 250k

Vin Vin+ gnd ac 1
R1 Vin+ Vin- 0
X1 Vin+ Vin- Vout Vdd Vss gnd inamp
Vpos Vdd 0 10
Vneg 0 Vss 10


.subckt inamp Vin+ Vin- Vout Vdd Vss ref     
*basic inamp model, trying to measure / duplicate CMRR properties
Eopamp1 e0 gnd opamp Vin+ e1 
Eopamp2 e4 gnd opamp Vin- e3 
Eopamp3 Vout gnd opamp  e5 e2 

R1 e0 e2 40k
R2 e4 e5 40.015k
R3 e1 e3 504
R4 e1 e0 25k
R5 e2 Vout 40k
R6 e5 ref 40.02k
R7 e3 e4 25k
.ends



.end
