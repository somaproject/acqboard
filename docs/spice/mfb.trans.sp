*SPICE test.sp transient analysis of MFB lpf per TI App note SLOA049B fig 15

.tran 10ms 5s 0s 


vin 1 0 sin (0V 1V 10Hz)
R1 1 2 15.5k
C1 2 0 0.047u
R2 2 4 15.5k
R3 2 3 3.48k
C2 3 4 0.01u
eopamp 4 0 opamp 0 3 

.options post

.end
