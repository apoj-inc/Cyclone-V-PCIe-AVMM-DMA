source ../../../.cache/quartus/vars.tcl

project_new $TOPLEVEL -overwrite

set_global_assignment -name TOP_LEVEL_ENTITY $TOPLEVEL
set_global_assignment -name VERILOG_MACRO QUARTUS

foreach rtl $RTL_FILES {
    set_global_assignment -name SYSTEMVERILOG_FILE $rtl
}

set_global_assignment -name SEARCH_PATH $INCDIR

set_global_assignment -name FAMILY $DEVICE_FAMILY
set_global_assignment -name DEVICE $DEVICE_PART

load_package flow
execute_flow -analysis_and_elaboration

project_archive $TOPLEVEL.qar -overwrite -include_libraries

project_close
