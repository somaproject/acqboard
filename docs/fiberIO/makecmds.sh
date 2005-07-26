#!/usr/bin/bash


cat cmd.svg | sed  "s/CMD/0x7/;s/DATA0/Mode/;s/DATA1/Chan/;s/DATA2/0x00/;s/DATA3/0x00/" > switchmode.cmd.svg

cat cmd.svg | sed  "s/CMD/0x1/;s/DATA0/Chan/;s/DATA1/Gain/;s/DATA2/0x00/;s/DATA3/0x00/" > setgain.cmd.svg

cat cmd.svg | sed  "s/CMD/0x2/;s/DATA0/Chan/;s/DATA1/Input/;s/DATA2/0x00/;s/DATA3/0x00/" > setinput.cmd.svg

cat cmd.svg | sed  "s/CMD/0x3/;s/DATA0/Chan/;s/DATA1/Filter/;s/DATA2/0x00/;s/DATA3/0x00/" > setfilter.cmd.svg

cat cmd.svg | sed  "s/CMD/0x4/;s/DATA0/Chan/;s/DATA1/Gain/;s/DATA2/V[15:8]/;s/DATA3/V[7:0]/" > writeos.cmd.svg


cat cmd.svg | sed  "s/CMD/0x5/;s/DATA0/Addr/;s/DATA1/V[21:16]/;s/DATA2/V[15:8]/;s/DATA3/V[7:0]/" > writefil.cmd.svg

cat cmd.svg | sed  "s/CMD/0x6/;s/DATA0/Addr/;s/DATA1/0x00/;s/DATA2/V[15:8]/;s/DATA3/V[7:0]/" > writesamp.cmd.svg


