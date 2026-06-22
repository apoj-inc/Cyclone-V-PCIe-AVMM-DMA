SHELL := /bin/bash
LAUNCH_PYTHON := $(shell ./build_system/utils/collect_lists.py)


TOPLEVEL_LANG ?= verilog

CACHE_DIR ?= $(CURDIR)/.cache

COCOTB_TOPLEVEL ?= tb_uart_loop
COCOTB_TEST_MODULES ?= $(COCOTB_TOPLEVEL)
TB_DIR ?= $(CURDIR)/tb
TB_EXT ?= sv
TB_FILES ?=  $(foreach file,$(shell find tb/tb_* -type f -name '*.sv'),$(CURDIR)/$(file))

LIST_DIR ?= $(CACHE_DIR)/lists
LIST_RTL ?= $(LIST_DIR)/files_rtl.lst

INCDIRS_PATH ?= $(LIST_DIR)/incdirs.lst
INCLUDE_DIRS ?= $(foreach file,$(shell cat $(INCDIRS_PATH) | grep -v "#"),$(CURDIR)/$(file))

SIM ?= questa-compat

ifndef COMPILE_ARGS
COMPILE_ARGS := -suppress 13314 -suppress 14408
endif

ifndef SIM_ARGS
SIM_ARGS :=
SIM_ARGS += -suppress 12110 -autofindloop -suppress 12130
SIM_ARGS += -do $(CURDIR)/build_system/cctb/questa_after_vsim.do
endif

CCTB_DIR ?= $(CACHE_DIR)/cctb
SIM_BUILD ?= $(CCTB_DIR)/$(COCOTB_TEST_MODULES)

VENV_DIR ?= $(CACHE_DIR)/.venv

WAVES ?= 1

VERILOG_SOURCES ?= $(foreach file,$(shell cat $(LIST_RTL) | grep -v "#"),$(CURDIR)/$(file))

TOPLEVEL_LIBRARY ?= work

.PHONY: run wave clean_module

run: $(VENV_DIR)/bin/activate $(VERILOG_SOURCES)
	@mkdir -p $(SIM_BUILD)
	@rm -f $(CCTB_DIR)/runsim.do
	@cp -r $(TB_DIR)/$(COCOTB_TEST_MODULES) $(SIM_BUILD)/..
	source $(VENV_DIR)/bin/activate; \
	cd $(SIM_BUILD); \
	make -f $(shell $(VENV_DIR)/bin/cocotb-config --makefiles)/Makefile.sim TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
	COCOTB_TOPLEVEL=$(COCOTB_TOPLEVEL) COCOTB_TEST_MODULES=$(COCOTB_TEST_MODULES) SIM=$(SIM) SIM_BUILD=$(CCTB_DIR) \
	COMPILE_ARGS='$(COMPILE_ARGS)' SIM_ARGS='$(SIM_ARGS)' WAVES=$(WAVES) VERILOG_INCLUDE_DIRS="$(INCLUDE_DIRS)" TOPLEVEL_LIBRARY=$(TOPLEVEL_LIBRARY) \
	VERILOG_SOURCES="$(VERILOG_SOURCES) $(TB_FILES)"

wave:
	vsim -view $(SIM_BUILD)/vsim.wlf

$(VENV_DIR)/bin/activate: build_system/cctb/user_requirements.txt build_system/cctb/requirements.txt
	python3 -m venv $(VENV_DIR)
	source $(VENV_DIR)/bin/activate; \
	pip install -r build_system/cctb/requirements.txt; \
	pip install -r build_system/cctb/user_requirements.txt


clean_module:
	@rm -rf $(SIM_BUILD)
