#**************************************************************
# Create Clock
#**************************************************************
create_clock -name pll_50mhz -period 20.000 [get_pins {u_my_pcie|pll_0|altera_pll_i|outclk_wire[0]~CLKENA0|outclk}]
create_clock -period 20 -name CLOCK_50_B3B [get_ports {CLOCK_50_B3B}]
create_clock -period 20 -name CLOCK_50_B4A [get_ports {CLOCK_50_B4A}]
create_clock -period 20 -name CLOCK_50_B5B [get_ports {CLOCK_50_B5B}]
create_clock -period 20 -name CLOCK_50_B6A [get_ports {CLOCK_50_B6A}]
create_clock -period 20 -name CLOCK_50_B7A [get_ports {CLOCK_50_B7A}]
create_clock -period 20 -name CLOCK_50_B8A [get_ports {CLOCK_50_B8A}]
create_clock -period 10 -name PCIE_REFCLK_p [get_ports {PCIE_REFCLK_p}]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {PCIE_PERST_n}]
set_false_path -from [get_ports {CPU_RESET_n}]
set_false_path -from [get_ports {KEY[*]}]
set_false_path -to   [get_ports {LED[*]}]

set_false_path -from {clock_50_rstn_rr}
set_false_path -from {clock_125_rstn_rr}
set_false_path -from [get_cells {*u_avmm_dma_top|u_avmm_dma_csr|dma_resetn_o}]
set_false_path -from [get_clocks {*arriav_hd_altpe2_hip_top|coreclkout}] -to [get_clocks pll_50mhz]
set_false_path -from [get_clocks pll_50mhz] -to [get_clocks {*arriav_hd_altpe2_hip_top|coreclkout}]
