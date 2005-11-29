VHDLC=vhdlp
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/input/_behavioral.var: ../../vhdl/input.vhd
	$(VHDLC) ../../vhdl/input.vhd

$(WORKDIR)/samplebuffer/_behavioral.var: ../../vhdl/samplebuffer.vhd
	$(VHDLC) ../../vhdl/samplebuffer.vhd

$(WORKDIR)/rmaccontrol/_behavioral.var: ../../vhdl/rmaccontrol.vhd
	$(VHDLC) ../../vhdl/rmaccontrol.vhd

$(WORKDIR)/filterarray/_behavioral.var: ../../vhdl/filterarray.vhd
	$(VHDLC) ../../vhdl/filterarray.vhd

$(WORKDIR)/multiplier/_behavioral.var: ../../vhdl/multiplier.vhd
	$(VHDLC) ../../vhdl/multiplier.vhd

$(WORKDIR)/accumulator/_behavioral.var: ../../vhdl/accumulator.vhd
	$(VHDLC) ../../vhdl/accumulator.vhd

$(WORKDIR)/rounding/_behavioral.var: ../../vhdl/rounding.vhd
	$(VHDLC) ../../vhdl/rounding.vhd

$(WORKDIR)/overflow/_behavioral.var: ../../vhdl/overflow.vhd
	$(VHDLC) ../../vhdl/overflow.vhd

$(WORKDIR)/rmac/_behavioral.var: ../../vhdl/rmac.vhd
	$(VHDLC) ../../vhdl/rmac.vhd

hw: $(WORKDIR)/input/_behavioral.var $(WORKDIR)/samplebuffer/_behavioral.var $(WORKDIR)/rmaccontrol/_behavioral.var $(WORKDIR)/filterarray/_behavioral.var $(WORKDIR)/multiplier/_behavioral.var $(WORKDIR)/accumulator/_behavioral.var $(WORKDIR)/rounding/_behavioral.var $(WORKDIR)/overflow/_behavioral.var $(WORKDIR)/rmac/_behavioral.var 

$(WORKDIR)/ad7685/_behavioral.var: ../components/ADC/AD7685.vhd
	$(VHDLC) ../components/ADC/AD7685.vhd

$(WORKDIR)/filterload/_behavioral.var: ../components/FilterLoad/FilterLoad.vhdl
	$(VHDLC) ../components/FilterLoad/FilterLoad.vhdl

comp: $(WORKDIR)/ad7685/_behavioral.var $(WORKDIR)/filterload/_behavioral.var 

$(WORKDIR)/filtertest/_behavior.var: filtertest.vhd
	$(VHDLC) filtertest.vhd

sim: $(WORKDIR)/filtertest/_behavior.var 
clean:
	rm -Rf $(WORKDIR)$