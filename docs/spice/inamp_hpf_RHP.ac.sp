* SPICE model of instrumentation amplifier, with ac-coupling, to determine effect of johnson noise in R0 on total output noise

.options post

.ac dec 100 0.0001 250k


Vin e1 vout ac 50u

R0 Vin- 0 0
R1 Vin+ Vin- 0 

X1 Vin+ Vin- Vout ref inamp
Rac e1 e0 1000000
Cac e0 ref 0.47u
eopamp ref gnd opamp gnd e0 



.subckt inamp Vin+ Vin- Vout  ref     
*basic inamp model, trying to measure / duplicate CMRR properties
Eopamp1 e0 gnd opamp Vin+ e1 
Eopamp2 e4 gnd opamp Vin- e3 
Eopamp3 Vout gnd opamp  e5 e2 

R1 e0 e2 40k
R2 e4 e5 40.015k
R3 e1 e3 505
R4 e1 e0 25k
R5 e2 Vout 40k
R6 e5 ref 40.02k
R7 e3 e4 25k
.ends



.end
