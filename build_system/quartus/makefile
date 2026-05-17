TOPLEVEL ?= toplevel

QUARTUS_BUILD_PATH ?= $(CURDIR)/build_system/quartus

VARS_TCL_PATH ?= $(CURDIR)/.cache/quartus/$(TOPLEVEL)
VARS_TCL ?= $(VARS_TCL_PATH)/vars.tcl

FILES_RTL_PATH ?= $(CURDIR)/rtl/lists/files_rtl.lst
INCDIRS_PATH ?= $(CURDIR)/rtl/lists/incdirs.lst

FILES_SDC_PATH ?= $(CURDIR)/sdc/lists/files_sdc.lst

NAMES_QSYS_PATH ?= $(CURDIR)/fpga/quartus/qsys/lists/names_qsys.lst
NAMES_QSYS := $(foreach name,$(shell cat $(NAMES_QSYS_PATH) | tr '\n' ' '), $(VARS_TCL_PATH)/$(shell basename $(name)).qsys)

CUSTOM_IP_PATH ?= $(CURDIR)/fpga/quartus/custom_ip

CUSTOM_ASSIGNMENTS ?= custom_assignments.tcl

DEVICE_FAMILY ?= "\"Cyclone V\""
DEVICE_PART ?= "5CGTFD9D5F27C7"

RELEASE_DIR 	?= $(CURDIR)/release
RELEASE_DIRS 	?= $(wildcard $(RELEASE_DIR)/*/) 
RELEASE_FILES	?= $(foreach directory,$(RELEASE_DIRS), $(directory)$(shell basename $(directory)).qar)

.PHONY: all compile clean

all: compile

compile: $(VARS_TCL_PATH)/$(TOPLEVEL).qpf

$(VARS_TCL_PATH)/$(TOPLEVEL).qpf: $(shell find $(CURDIR)/rtl -type f | tr '\n' ' ') $(NAMES_QSYS)
	cp $(QUARTUS_BUILD_PATH)/$(CUSTOM_ASSIGNMENTS) $(VARS_TCL_PATH)/$(CUSTOM_ASSIGNMENTS)
	cp $(QUARTUS_BUILD_PATH)/setup_sh.tcl $(VARS_TCL_PATH)/setup_sh.tcl

	@echo set TOPLEVEL $(TOPLEVEL) > $(VARS_TCL)
	
	@echo set CUSTOM_ASSIGNMENTS $(CUSTOM_ASSIGNMENTS) >> $(VARS_TCL)
	
	@echo set CURDIR $(CURDIR) >> $(VARS_TCL)

	@echo set CUSTOM_IP_PATH $(CUSTOM_IP_PATH) >> $(VARS_TCL)

	@echo set FILES_RTL_PATH $(FILES_RTL_PATH) >> $(VARS_TCL)
	@echo set INCDIRS_PATH $(INCDIRS_PATH) >> $(VARS_TCL)
	
	@echo set FILES_SDC_PATH $(FILES_SDC_PATH) >> $(VARS_TCL)
	
	@echo set NAMES_QSYS_PATH $(NAMES_QSYS_PATH) >> $(VARS_TCL)
	
	@echo set DEVICE_FAMILY $(DEVICE_FAMILY) >> $(VARS_TCL)
	@echo set DEVICE_PART $(DEVICE_PART) >> $(VARS_TCL)

	@cd $(VARS_TCL_PATH);\
	quartus_sh -t setup_sh.tcl

$(NAMES_QSYS): $(shell find $(CURDIR)/fpga/quartus/qsys -type f | tr '\n' ' ')
	@mkdir -p $(VARS_TCL_PATH)
	
	@cd $(VARS_TCL_PATH);\
	for name in $$(cat $(NAMES_QSYS_PATH)); do\
		$$QSYS_ROOTDIR/qsys-script --script=$(CURDIR)/$$name.tcl --search-path=$(CUSTOM_IP_PATH),$$;\
	done;\
	for name in $$(cat $(NAMES_QSYS_PATH)); do\
		$$QSYS_ROOTDIR/qsys-generate --synthesis=VERILOG $$(basename "$$name.qsys") --search-path=$(CUSTOM_IP_PATH),$$;\
	done;\

clean:
	rm -rf $(VARS_TCL_PATH)
