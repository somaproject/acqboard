VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/distram/_behavioral.var: ../../vhdl/distram.vhd
	$(VHDLC) ../../vhdl/distram.vhd

$(WORKDIR)/pgaload/_behavioral.var: ../../vhdl/pgaload.vhd
	$(VHDLC) ../../vhdl/pgaload.vhd

hw: $(WORKDIR)/distram/_behavioral.var $(WORKDIR)/pgaload/_behavioral.var 

$(WORKDIR)/pga/_behavioral.var: ../components/PGA/PGA.vhdl
	$(VHDLC) ../components/PGA/PGA.vhdl

comp: $(WORKDIR)/pga/_behavioral.var 

$(WORKDIR)/pgaloadtest/_behavior.var: pgaloadtest.vhd
	$(VHDLC) pgaloadtest.vhd

sim: $(WORKDIR)/pgaloadtest/_behavior.var 
runsim: all
	$(VHDLS) pgaloadtest


clean:
	rm -Rf $(WORKDIR)$

