*SPICE test.sp AC analysis of MFB lpf per TI App not e SLOA049B fig 15

.ac dec 10 100 1000k

.print ac input=vdb(1) output=vdb(4)
.plot ac input=vdb(1) output=vdb(4)

vin 1 0 ac 1
R1 1 2 15.5k
C1 2 0 0.047u
R2 2 4 15.5k
R3 2 3 3.48k
C2 3 4 0.01u
eopamp 4 0 opamp 0 3 

.options post

.end
