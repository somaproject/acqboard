*SPICE lpf_mfb_bias.ac.sp AC analysis of MFB lpf with 2.5V bias to 
* turn a +/- 2.5V signal into a 0-5 v signal and LPF with a single op-amp
*  This uses my values for R, C such that Fc = 34 kHz. It also uses a simulated
*  AD8021. 
.ac dec 10 100 1000k

.print ac input=vdb(1) output=vdb(4)
.plot ac input=vdb(1) output=vdb(4)


vin 1 0 ac 1
vb 5 0 1.25
R1 1 2 4640
C1 3 4 0.001u
R2 2 4 4640
R3 2 3 1000
C2 2 0 0.0047u
eopamp 4 0 opamp 5 3 

.options post

.end
