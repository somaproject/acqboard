VHDLC=vhdlp
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/fibertx.vhd
	$(VHDLC) ../../vhdl/fibertx.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../../vhdl/decode8b10b.vhd
	$(VHDLC) ../../vhdl/decode8b10b.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../../vhdl/encode8b10b.vhd
	$(VHDLC) ../../vhdl/encode8b10b.vhd

hw: $(WORKDIR)/fibertx/_behavioral.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var 

comp: 

$(WORKDIR)/deserialize/_behavioral.var: ../components/deserialize/deserialize.vhd
	$(VHDLC) ../components/deserialize/deserialize.vhd

$(WORKDIR)/fibertxtest/_behavior.var: fibertxtest.vhd
	$(VHDLC) fibertxtest.vhd

sim: $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/fibertxtest/_behavior.var 
clean:
	rm -Rf $(WORKDIR)$