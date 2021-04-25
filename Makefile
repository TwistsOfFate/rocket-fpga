# Please have a look at README.md first

CONFIG ?= DefaultKC705Config

### vivado source
defaultconfig_v = verilog/$(CONFIG).v 			# rocket-chip generated verilog
firmware_hex = verilog/firmware.hex 			# image of BRAM_64K

sdload_c = firmware/sdload.c

bootrom_img = rocket-chip/bootrom/bootrom.img 	# image of TLBootrom
bootrom_s = rocket-chip/bootrom/bootrom.S

vivado_source : bootrom_replace rocketconfig_replace $(defaultconfig_v) $(firmware_hex)

bootrom_replace :
	cp firmware/TLBootrom/* rocket-chip/bootrom 
	@echo "#################################"
	@echo "#####  TLBootroom replaced  #####"
	@echo "#################################"

rocketconfig_replace :
	mv rocket-chip/src/main/scala/system/Configs.scala rocket-chip/src/main/scala/system/Configs.scala.old
	cp rocketconfig/system.Configs.scala rocket-chip/src/main/scala/system/Configs.scala
	@echo "#################################"
	@echo "#### Configs.scala replaced #####"
	@echo "#################################"

$(defaultconfig_v) : $(bootrom_img)
	cd rocket-chip/vsim && $(MAKE) verilog CONFIG=freechips.rocketchip.system.$(CONFIG)
	cd rocket-chip/vsim && cp generated-src/freechips.rocketchip.system.$(CONFIG).v ../../verilog/DefaultConfig.v
	@echo "#################################"
	@echo "##### DefaultConfig.v built #####"
	@echo "#################################"

$(bootrom_img) : $(bootrom_s)
	cd rocket-chip/bootrom && $(MAKE)
	@echo "#################################"
	@echo "#####   Bootrom.img built   #####"
	@echo "#################################"

$(firmware_hex) : $(sdload_c)
	cd firmware && $(MAKE) all && cp firmware.hex ../verilog/firmware.hex
	@echo "#################################"
	@echo "#####  firmware.hex built   #####"
	@echo "#################################"

clean:
	cd rocket-chip/vsim && $(MAKE) clean
	cd firmware && $(MAKE) clean
	-rm verilog/DefaultConfig.v
	-rm $(firmware_hex)
	-mv rocket-chip/src/main/scala/system/Configs.scala.old rocket-chip/src/main/scala/system/Configs.scala
