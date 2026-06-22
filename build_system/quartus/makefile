SHELL := /bin/bash
LAUNCH_PYTHON := $(shell ./build_system/utils/collect_lists.py)

TOPLEVEL ?= toplevel

QUARTUS_BUILD_PATH ?= $(CURDIR)/build_system/quartus

CACHE_DIR ?= $(CURDIR)/.cache
LIST_DIR ?= $(CACHE_DIR)/lists

VARS_TCL_PATH ?= $(CURDIR)/.cache/quartus/$(TOPLEVEL)
VARS_TCL ?= $(VARS_TCL_PATH)/vars.tcl

FILES_RTL_PATH ?= $(LIST_DIR)/files_rtl.lst
FILES_HEX_PATH ?= $(LIST_DIR)/files_hex.lst
INCDIRS_PATH ?= $(LIST_DIR)/incdirs.lst
NAMES_QSYS_PATH ?= $(LIST_DIR)/names_qsys.lst
CUSTOM_IP_PATH ?= $(LIST_DIR)/ip_paths.lst

FILES_SDC_PATH ?= $(CURDIR)/sdc/lists/files_sdc.lst

NAMES_QSYS := $(foreach name,$(shell cat $(NAMES_QSYS_PATH) | tr '\n' ' '), $(VARS_TCL_PATH)/$(shell basename $(name)).qsys)
CUSTOM_IP := $(shell cat $(NAMES_QSYS_PATH) | tr '\n' ',')

CUSTOM_ASSIGNMENTS ?= custom_assignments.tcl

RELEASE_DIR 	?= $(CURDIR)/release
RELEASE_DIRS  	?= $(wildcard $(RELEASE_DIR)/*/) 
RELEASE_FILES	?= $(foreach directory,$(RELEASE_DIRS), $(directory)$(shell basename $(directory)).qar)

RELEASE_VARS_TCL_PATH ?= $(CURDIR)/.cache/quartus
RELEASE_VARS_TCL ?= $(RELEASE_VARS_TCL_PATH)/vars.tcl

DEVICE_FAMILY ?= Cyclone V
DEVICE_PART ?= "5CGTFD9D5F27C7"

CABLE_NAME ?= C5P
JTAG_CHAIN_DEVNUM ?= 1

VERILOG_SOURCES := $(shell cat $(FILES_RTL_PATH) | tr '\n' ' ')
HEX_SOURCES := $(shell cat $(FILES_HEX_PATH) | tr '\n' ' ')
QSYS_SOURCES := $(shell cat $(NAMES_QSYS_PATH) | tr '\n' ' ')
IP_SOURCES := $(shell cat $(CUSTOM_IP_PATH) | tr '\n' ' ')

.PHONY: all compile program create_releases clean_releases clean

all: compile

compile: $(VARS_TCL_PATH)/output_files/$(TOPLEVEL).sof

$(VARS_TCL_PATH)/output_files/$(TOPLEVEL).sof: $(VERILOG_SOURCES) $(HEX_SOURCES) $(IP_SOURCES) $(NAMES_QSYS)
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
	
	@echo set DEVICE_FAMILY {$(DEVICE_FAMILY)} >> $(VARS_TCL)
	@echo set DEVICE_PART $(DEVICE_PART) >> $(VARS_TCL)

	@cd $(VARS_TCL_PATH);\
	quartus_sh -t setup_sh.tcl

$(NAMES_QSYS):
	@mkdir -p $(VARS_TCL_PATH)
	
	@cd $(VARS_TCL_PATH);\
	for name in $$(cat $(NAMES_QSYS_PATH)); do\
		$$QSYS_ROOTDIR/qsys-script --script=$(CURDIR)/$$name.tcl --search-path=$(CUSTOM_IP),$$;\
	done;\
	for name in $$(cat $(NAMES_QSYS_PATH)); do\
		$$QSYS_ROOTDIR/qsys-generate --synthesis=VERILOG $$(basename "$$name.qsys") --search-path=$(CUSTOM_IP),$$;\
	done;\

program: $(VARS_TCL_PATH)/output_files/$(TOPLEVEL).sof
	cd $(VARS_TCL_PATH)/output_files ;\
	quartus_pgm -c $(CABLE_NAME) -m jtag -o p\;$(TOPLEVEL).sof@$(JTAG_CHAIN_DEVNUM)

clean:
	rm -rf $(VARS_TCL_PATH)

create_releases: $(RELEASE_FILES)

$(RELEASE_FILES):\
		$(foreach file,$(shell cat $(wildcard $(RELEASE_DIR)/*/sources.lst) | grep -v "#"),$(CURDIR)/$(file))\
		$(foreach file,$(shell cat $(wildcard $(RELEASE_DIR)/*/incfiles.lst) | grep -v "#"),$(CURDIR)/$(file))\
		$(wildcard $(RELEASE_DIR)/*/sources.lst)\
		$(wildcard $(RELEASE_DIR)/*/incfiles.lst)
	@mkdir -p $(dir $@)package
	@rm -r $(dir $@)package
	@mkdir -p $(dir $@)package $(dir $@)package/src $(dir $@)package/inc
	@$(foreach file,$(shell cat $(abspath $(dir $@)sources.lst) | grep -v "#") , cp $(CURDIR)/$(file) $(dir $@)package/src;)
	@$(foreach file,$(shell cat $(abspath $(dir $@)incfiles.lst) | grep -v "#"), cp $(CURDIR)/$(file) $(dir $@)package/inc;)

	@mkdir -p $(RELEASE_VARS_TCL_PATH)
	@echo set TOPLEVEL $(notdir $(basename $@)) > $(RELEASE_VARS_TCL)
	@echo set RTL_FILES {$(foreach file,$(shell cat $(abspath $(dir $@)sources.lst) | grep -v "#"), src/$(notdir $(file))) } >> $(RELEASE_VARS_TCL)
	@echo set INCDIR inc >> $(RELEASE_VARS_TCL)
	@echo set DEVICE_FAMILY $(DEVICE_FAMILY) >> $(RELEASE_VARS_TCL)
	@echo set DEVICE_PART $(DEVICE_PART) >> $(RELEASE_VARS_TCL)

	@cd $(dir $@)package;\
		quartus_sh -t $(QUARTUS_BUILD_PATH)/package.tcl
	
	@mv $(dir $@)package/$(notdir $(basename $@)).qar $(dir $@)
	
	@rm -rf $(dir $@)package

clean_releases:
	@rm -f $(wildcard $(RELEASE_DIR)/*/*.qar)
