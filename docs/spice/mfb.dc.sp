*SPICE test.sp DC analysis of MFB lpf per TI App not e SLOA049B fig 15

.dc vin -2.5 2.5 .1



vin Va 0 dc 1
R1 Va 2 15.5k
C1 2 0 0.047u
R2 2 4 15.5k
R3 2 3 3.48k
C2 3 4 0.01u
eopamp 4 0 opamp 0  3 

.options post

.end
