try {
    if {[lsearch -exact $WildcardFilter Memory] >= 0} {
        set WildcardFilter [lsearch -not -all -inline $WildcardFilter Memory];
    }
    log -r /*;
    run -all;
    exit;
} on error {Error: Active logfile is not in simulation mode} {
}
