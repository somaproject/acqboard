VHDLC=vhdlp
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/input/_behavioral.var: ../../vhdl/input.vhd
	$(VHDLC) ../../vhdl/input.vhd

$(WORKDIR)/distram_dualport/_behavioral.var: ../../vhdl/distRAM_dualport.vhd
	$(VHDLC) ../../vhdl/distRAM_dualport.vhd

hw: $(WORKDIR)/input/_behavioral.var $(WORKDIR)/distram_dualport/_behavioral.var 

$(WORKDIR)/ad7685/_behavioral.var: ../components/ADC/AD7685.vhd
	$(VHDLC) ../components/ADC/AD7685.vhd

comp: $(WORKDIR)/ad7685/_behavioral.var 

$(WORKDIR)/inputtest/_behavior.var: inputtest.vhd
	$(VHDLC) inputtest.vhd

sim: $(WORKDIR)/inputtest/_behavior.var 
clean:
	rm -Rf $(WORKDIR)$