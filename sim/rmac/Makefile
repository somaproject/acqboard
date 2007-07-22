VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/accumulator/_behavioral.var: ../../vhdl/accumulator.vhd
	$(VHDLC) ../../vhdl/accumulator.vhd

$(WORKDIR)/multiplier/_behavioral.var: ../../vhdl/multiplier.vhd
	$(VHDLC) ../../vhdl/multiplier.vhd

$(WORKDIR)/overflow/_behavioral.var: ../../vhdl/overflow.vhd
	$(VHDLC) ../../vhdl/overflow.vhd

$(WORKDIR)/rounding/_behavioral.var: ../../vhdl/rounding.vhd
	$(VHDLC) ../../vhdl/rounding.vhd

$(WORKDIR)/rmac/_behavioral.var: ../../vhdl/rmac.vhd
	$(VHDLC) ../../vhdl/rmac.vhd

hw: $(WORKDIR)/accumulator/_behavioral.var $(WORKDIR)/multiplier/_behavioral.var $(WORKDIR)/overflow/_behavioral.var $(WORKDIR)/rounding/_behavioral.var $(WORKDIR)/rmac/_behavioral.var 

comp: 

$(WORKDIR)/rmactest/_behavior.var: rmactest.vhd
	$(VHDLC) rmactest.vhd

sim: $(WORKDIR)/rmactest/_behavior.var 
runsim: all
	$(VHDLS) rmactest


clean:
	rm -Rf $(WORKDIR)$

