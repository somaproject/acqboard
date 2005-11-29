VHDLC=vhdlp
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/multiplier/_behavioral.var: ../../vhdl/multiplier.vhd
	$(VHDLC) ../../vhdl/multiplier.vhd

$(WORKDIR)/accumulator/_behavioral.var: ../../vhdl/accumulator.vhd
	$(VHDLC) ../../vhdl/accumulator.vhd

$(WORKDIR)/rounding/_behavioral.var: ../../vhdl/rounding.vhd
	$(VHDLC) ../../vhdl/rounding.vhd

$(WORKDIR)/overflow/_behavioral.var: ../../vhdl/overflow.vhd
	$(VHDLC) ../../vhdl/overflow.vhd

hw: $(WORKDIR)/multiplier/_behavioral.var $(WORKDIR)/accumulator/_behavioral.var $(WORKDIR)/rounding/_behavioral.var $(WORKDIR)/overflow/_behavioral.var 

comp: 

$(WORKDIR)/mactest/_behavior.var: mactest.vhd
	$(VHDLC) mactest.vhd

sim: $(WORKDIR)/mactest/_behavior.var 
clean:
	rm -Rf $(WORKDIR)$