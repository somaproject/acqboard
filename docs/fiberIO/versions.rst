Version information
======================

Challenges associated with keeping track of bitstream revisions have
prompted a desire to be able to query the acqboard for which particular
version of the firmware it is running. 

Due to the constrained bandwith on the fiber interface, we include
a version number as the last byte. This is a simple single-byte
where odd bytes indicate development releases and even bytes indicate
real releases. You can think of this like a "stepping" number, 
with loose ties to the tagged git releases. 

00 : initial development release. 
01 : added version information

