VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/distram_dualport/_behavioral.var: ../../vhdl/distram_dualport.vhd
	$(VHDLC) ../../vhdl/distram_dualport.vhd

$(WORKDIR)/input/_behavioral.var: ../../vhdl/input.vhd
	$(VHDLC) ../../vhdl/input.vhd

$(WORKDIR)/clocks/_behavioral.var: ../../vhdl/clocks.vhd
	$(VHDLC) ../../vhdl/clocks.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../../vhdl/encode8b10b.vhd
	$(VHDLC) ../../vhdl/encode8b10b.vhd

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/fibertx.vhd
	$(VHDLC) ../../vhdl/fibertx.vhd

$(WORKDIR)/raw/_behavioral.var: ../../vhdl/raw.vhd
	$(VHDLC) ../../vhdl/raw.vhd

hw: $(WORKDIR)/distram_dualport/_behavioral.var $(WORKDIR)/input/_behavioral.var $(WORKDIR)/clocks/_behavioral.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/fibertx/_behavioral.var $(WORKDIR)/raw/_behavioral.var 

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../../vhdl/decode8b10b.vhd
	$(VHDLC) ../../vhdl/decode8b10b.vhd

$(WORKDIR)/deserialize/_behavioral.var: ../components/deserialize/deserialize.vhd
	$(VHDLC) ../components/deserialize/deserialize.vhd

$(WORKDIR)/ad7685/_behavioral.var: ../components/ADC/AD7685.vhd
	$(VHDLC) ../components/ADC/AD7685.vhd

comp: $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/ad7685/_behavioral.var 

$(WORKDIR)/rawtest/_behavior.var: rawtest.vhd
	$(VHDLC) rawtest.vhd

sim: $(WORKDIR)/rawtest/_behavior.var 
runsim: all
	$(VHDLS) rawtest


clean:
	rm -Rf $(WORKDIR)$

