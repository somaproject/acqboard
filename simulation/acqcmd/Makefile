VHDLC=vhdlp
VHDLS=vhdle
WORKDIR=work.sym
all: hw comp sim

$(WORKDIR)/control/_behavioral.var: ../../vhdl/control.vhd
	$(VHDLC) ../../vhdl/control.vhd

$(WORKDIR)/clocks/_behavioral.var: ../../vhdl/clocks.vhd
	$(VHDLC) ../../vhdl/clocks.vhd

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

$(WORKDIR)/distram/_behavioral.var: ../../vhdl/distram.vhd
	$(VHDLC) ../../vhdl/distram.vhd

$(WORKDIR)/pgaload/_behavioral.var: ../../vhdl/pgaload.vhd
	$(VHDLC) ../../vhdl/pgaload.vhd

$(WORKDIR)/encode8b10b/_encode8b10b_a.var: ../../vhdl/encode8b10b.vhd
	$(VHDLC) ../../vhdl/encode8b10b.vhd

$(WORKDIR)/decode8b10b/_decode8b10b_a.var: ../../vhdl/decode8b10b.vhd
	$(VHDLC) ../../vhdl/decode8b10b.vhd

$(WORKDIR)/raw/_behavioral.var: ../../vhdl/raw.vhd
	$(VHDLC) ../../vhdl/raw.vhd

$(WORKDIR)/distram_dualport/_behavioral.var: ../../vhdl/distram_dualport.vhd
	$(VHDLC) ../../vhdl/distram_dualport.vhd

$(WORKDIR)/fibertx/_behavioral.var: ../../vhdl/fibertx.vhd
	$(VHDLC) ../../vhdl/fibertx.vhd

$(WORKDIR)/decoder/_behavioral.var: ../../vhdl/decoder.vhd
	$(VHDLC) ../../vhdl/decoder.vhd

$(WORKDIR)/fiberrx/_behavioral.var: ../../vhdl/fiberrx.vhd
	$(VHDLC) ../../vhdl/fiberrx.vhd

$(WORKDIR)/loader/_behavioral.var: ../../vhdl/loader.vhd
	$(VHDLC) ../../vhdl/loader.vhd

$(WORKDIR)/eepromio/_behavioral.var: ../../vhdl/eepromio.vhd
	$(VHDLC) ../../vhdl/eepromio.vhd

$(WORKDIR)/control/_behavioral.var: ../../vhdl/control.vhd
	$(VHDLC) ../../vhdl/control.vhd

$(WORKDIR)/acqboard/_behavioral.var: ../../vhdl/acqboard.vhd
	$(VHDLC) ../../vhdl/acqboard.vhd

hw: $(WORKDIR)/control/_behavioral.var $(WORKDIR)/clocks/_behavioral.var $(WORKDIR)/input/_behavioral.var $(WORKDIR)/samplebuffer/_behavioral.var $(WORKDIR)/rmaccontrol/_behavioral.var $(WORKDIR)/filterarray/_behavioral.var $(WORKDIR)/multiplier/_behavioral.var $(WORKDIR)/accumulator/_behavioral.var $(WORKDIR)/rounding/_behavioral.var $(WORKDIR)/overflow/_behavioral.var $(WORKDIR)/rmac/_behavioral.var $(WORKDIR)/distram/_behavioral.var $(WORKDIR)/pgaload/_behavioral.var $(WORKDIR)/encode8b10b/_encode8b10b_a.var $(WORKDIR)/decode8b10b/_decode8b10b_a.var $(WORKDIR)/raw/_behavioral.var $(WORKDIR)/distram_dualport/_behavioral.var $(WORKDIR)/fibertx/_behavioral.var $(WORKDIR)/decoder/_behavioral.var $(WORKDIR)/fiberrx/_behavioral.var $(WORKDIR)/loader/_behavioral.var $(WORKDIR)/eepromio/_behavioral.var $(WORKDIR)/control/_behavioral.var $(WORKDIR)/acqboard/_behavioral.var 

$(WORKDIR)/pga/_behavioral.var: ../components/PGA/PGA.vhdl
	$(VHDLC) ../components/PGA/PGA.vhdl

$(WORKDIR)/sendcmd/_behavioral.var: ../components/SendCMD/SendCMD.vhd
	$(VHDLC) ../components/SendCMD/SendCMD.vhd

$(WORKDIR)/deserialize/_behavioral.var: ../components/deserialize/deserialize.vhd
	$(VHDLC) ../components/deserialize/deserialize.vhd

$(WORKDIR)/ad7685/_behavioral.var: ../components/ADC/AD7685.vhd
	$(VHDLC) ../components/ADC/AD7685.vhd

comp: $(WORKDIR)/pga/_behavioral.var $(WORKDIR)/sendcmd/_behavioral.var $(WORKDIR)/deserialize/_behavioral.var $(WORKDIR)/ad7685/_behavioral.var 

$(WORKDIR)/eeprom/_behavioral.var: EEPROM.vhdl
	$(VHDLC) EEPROM.vhdl

$(WORKDIR)/acqcmdtest/_behavior.var: acqcmdtest.vhd
	$(VHDLC) acqcmdtest.vhd

sim: $(WORKDIR)/eeprom/_behavioral.var $(WORKDIR)/acqcmdtest/_behavior.var 
runsim: all
	$(VHDLS) acqcmdtest


clean:
	rm -Rf $(WORKDIR)$

