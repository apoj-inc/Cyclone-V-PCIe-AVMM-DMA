if {[lsearch -exact $WildcardFilter Memory] >= 0} {
    set WildcardFilter [lsearch -not -all -inline $WildcardFilter Memory]
}
