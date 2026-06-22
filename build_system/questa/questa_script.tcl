source vars.tcl

set fp [open $LIST_HEX r]
set file_data [read $fp]
close $fp

set FILES_HEX_LIST [split $file_data "\n"]
foreach hex $FILES_HEX_LIST {
    set hexfile_path [file tail $hex]
    if { [file exists $hexfile_path] != 1} {
        file link $hexfile_path ../../$hex
    }
}

set fp [open $LIST_RTL r]
set file_data [read $fp]
close $fp

set FILES_RTL_LIST [split $file_data "\n"]
for {set i 0} {$i < [llength $FILES_RTL_LIST]} {incr i} {
    set appended ../../[lindex $FILES_RTL_LIST $i]
    lset FILES_RTL_LIST $i $appended
}

set fp [open $LIST_TB r]
set file_data [read $fp]
close $fp

set FILES_TB_LIST [split $file_data "\n"]
for {set i 0} {$i < [llength $FILES_TB_LIST]} {incr i} {
    set appended ../../[lindex $FILES_TB_LIST $i]
    lset FILES_TB_LIST $i $appended
}

set fp [open $LIST_INC r]
set file_data [read $fp]
close $fp

set INCDIRS_LIST [split $file_data "\n"]
set INCDIRS_STRING {}
for {set i 0} {$i < [llength $INCDIRS_LIST]} {incr i} {
    set appended +../../[lindex $INCDIRS_LIST $i]
    append INCDIRS_STRING ${appended}
}

set fp [open "files_rtl.lst" w+]
foreach rtl $FILES_RTL_LIST {
    puts $fp $rtl
}
foreach rtl $FILES_TB_LIST {
    puts $fp $rtl
}
close $fp

vlib work
vlog -mfcu +incdir${INCDIRS_STRING} -f files_rtl.lst -suppress 13314

vsim -voptargs=+acc work.$TOPLEVEL +define+QUESTA
if {[lsearch -exact $WildcardFilter Memory] >= 0} {
    set WildcardFilter [lsearch -not -all -inline $WildcardFilter Memory]
}
log -r /*
run -all

foreach hex $FILES_HEX_LIST {
    file delete [file tail $hex]
}

exit
