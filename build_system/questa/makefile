LIST_TB := $(CURDIR)/rtl/lists/files_tb.lst
LIST_RTL := $(CURDIR)/rtl/lists/files_rtl.lst
LIST_HEX := $(CURDIR)/rtl/lists/files_hex.lst

QUESTA_PATH ?= $(CURDIR)/build_system/questa
QUESTA_BUILD_PATH ?= $(CURDIR)/.cache/build_system/questa
TOPLEVEL ?= tb

SIM_PATH ?= $(QUESTA_BUILD_PATH)

VARS_TCL_PATH := $(SIM_PATH)/vars.tcl

run:
	mkdir -p $(SIM_PATH)
	
	@echo set LIST_RTL $(LIST_RTL) > $(VARS_TCL_PATH)
	@echo set LIST_TB $(LIST_TB) >> $(VARS_TCL_PATH)
	@echo set LIST_HEX $(LIST_HEX) >> $(VARS_TCL_PATH)
	@echo set TOPLEVEL $(TOPLEVEL) >> $(VARS_TCL_PATH)
	@echo set SIM_PATH $(SIM_PATH) >> $(VARS_TCL_PATH)

	cp $(QUESTA_PATH)/questa_script.tcl $(QUESTA_BUILD_PATH)/questa_script.tcl; \
	cd $(CURDIR); \
	cd $(QUESTA_BUILD_PATH); \
	vsim -c -do questa_script.tcl

wave:
	vsim -view $(SIM_PATH)/vsim.wlf
