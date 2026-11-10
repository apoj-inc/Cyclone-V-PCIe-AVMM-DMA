#============================================================
# CLOCK
#============================================================
set_instance_assignment -name IO_STANDARD "1.5 V" -to CLOCK_50_B3B
set_instance_assignment -name IO_STANDARD "1.5 V" -to CLOCK_50_B4A
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50_B5B
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50_B6A
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50_B7A
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50_B8A
set_location_assignment PIN_T13 -to CLOCK_50_B3B
set_location_assignment PIN_U12 -to CLOCK_50_B4A
set_location_assignment PIN_R20 -to CLOCK_50_B5B
set_location_assignment PIN_N20 -to CLOCK_50_B6A
set_location_assignment PIN_H12 -to CLOCK_50_B7A
set_location_assignment PIN_N9 -to CLOCK_50_B8A

#============================================================
# Buttons
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CPU_RESET_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[3]
set_location_assignment PIN_AB24 -to CPU_RESET_n
set_location_assignment PIN_M21 -to KEY[0]
set_location_assignment PIN_K25 -to KEY[1]
set_location_assignment PIN_K26 -to KEY[2]
set_location_assignment PIN_G26 -to KEY[3]

#============================================================
# Swtiches
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
set_location_assignment PIN_G20 -to SW[0]
set_location_assignment PIN_F21 -to SW[1]
set_location_assignment PIN_E21 -to SW[2]
set_location_assignment PIN_H19 -to SW[3]

#============================================================
# LED
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[3]
set_location_assignment PIN_U20 -to LED[0]
set_location_assignment PIN_T19 -to LED[1]
set_location_assignment PIN_Y24 -to LED[2]
set_location_assignment PIN_Y23 -to LED[3]

#============================================================
# HEX0
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0_DP
set_location_assignment PIN_T8 -to HEX0[0]
set_location_assignment PIN_P26 -to HEX0[1]
set_location_assignment PIN_V8 -to HEX0[2]
set_location_assignment PIN_U7 -to HEX0[3]
set_location_assignment PIN_U25 -to HEX0[4]
set_location_assignment PIN_W8 -to HEX0[5]
set_location_assignment PIN_U26 -to HEX0[6]
set_location_assignment PIN_AA6 -to HEX0_DP

#============================================================
# HEX1
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1_DP
set_location_assignment PIN_T7 -to HEX1[0]
set_location_assignment PIN_W20 -to HEX1[1]
set_location_assignment PIN_AB6 -to HEX1[2]
set_location_assignment PIN_AC22 -to HEX1[3]
set_location_assignment PIN_Y9 -to HEX1[4]
set_location_assignment PIN_W21 -to HEX1[5]
set_location_assignment PIN_N25 -to HEX1[6]
set_location_assignment PIN_V25 -to HEX1_DP

#============================================================
# FAN
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FAN_CTRL
set_location_assignment PIN_AD7 -to FAN_CTRL

#============================================================
# SDRAM
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_ADDR[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_BA[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_BA[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CAS_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CKE
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_CS_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_DQ[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_LDQM
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_RAS_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_UDQM
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to DRAM_WE_n
set_location_assignment PIN_D26 -to DRAM_ADDR[0]
set_location_assignment PIN_H20 -to DRAM_ADDR[1]
set_location_assignment PIN_F23 -to DRAM_ADDR[2]
set_location_assignment PIN_G22 -to DRAM_ADDR[3]
set_location_assignment PIN_B25 -to DRAM_ADDR[4]
set_location_assignment PIN_D22 -to DRAM_ADDR[5]
set_location_assignment PIN_C25 -to DRAM_ADDR[6]
set_location_assignment PIN_E23 -to DRAM_ADDR[7]
set_location_assignment PIN_B26 -to DRAM_ADDR[8]
set_location_assignment PIN_E24 -to DRAM_ADDR[9]
set_location_assignment PIN_D25 -to DRAM_ADDR[10]
set_location_assignment PIN_M26 -to DRAM_ADDR[11]
set_location_assignment PIN_M25 -to DRAM_ADDR[12]
set_location_assignment PIN_J20 -to DRAM_BA[0]
set_location_assignment PIN_H22 -to DRAM_BA[1]
set_location_assignment PIN_J26 -to DRAM_CAS_n
set_location_assignment PIN_E25 -to DRAM_CKE
set_location_assignment PIN_F26 -to DRAM_CLK
set_location_assignment PIN_F22 -to DRAM_CS_n
set_location_assignment PIN_L24 -to DRAM_DQ[0]
set_location_assignment PIN_M24 -to DRAM_DQ[1]
set_location_assignment PIN_N23 -to DRAM_DQ[2]
set_location_assignment PIN_K23 -to DRAM_DQ[3]
set_location_assignment PIN_H24 -to DRAM_DQ[4]
set_location_assignment PIN_J23 -to DRAM_DQ[5]
set_location_assignment PIN_K24 -to DRAM_DQ[6]
set_location_assignment PIN_L22 -to DRAM_DQ[7]
set_location_assignment PIN_G25 -to DRAM_DQ[8]
set_location_assignment PIN_G24 -to DRAM_DQ[9]
set_location_assignment PIN_H25 -to DRAM_DQ[10]
set_location_assignment PIN_J21 -to DRAM_DQ[11]
set_location_assignment PIN_L23 -to DRAM_DQ[12]
set_location_assignment PIN_K21 -to DRAM_DQ[13]
set_location_assignment PIN_N24 -to DRAM_DQ[14]
set_location_assignment PIN_M22 -to DRAM_DQ[15]
set_location_assignment PIN_H23 -to DRAM_LDQM
set_location_assignment PIN_E26 -to DRAM_RAS_n
set_location_assignment PIN_F24 -to DRAM_UDQM
set_location_assignment PIN_J25 -to DRAM_WE_n

#============================================================
# Uart to Usb
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_CTS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_RTS
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_RX
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_TX
set_location_assignment PIN_W25 -to UART_CTS
set_location_assignment PIN_W26 -to UART_RTS
set_location_assignment PIN_P22 -to UART_RX
set_location_assignment PIN_P21 -to UART_TX

#============================================================
# Arduino Interface
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_CONVST
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SCK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SDI
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SDO
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARD_IO[15]
set_location_assignment PIN_T26 -to ADC_CONVST
set_location_assignment PIN_R26 -to ADC_SCK
set_location_assignment PIN_AA26 -to ADC_SDI
set_location_assignment PIN_AB26 -to ADC_SDO
set_location_assignment PIN_Y26 -to ARD_IO[0]
set_location_assignment PIN_V23 -to ARD_IO[1]
set_location_assignment PIN_V24 -to ARD_IO[2]
set_location_assignment PIN_U24 -to ARD_IO[3]
set_location_assignment PIN_T24 -to ARD_IO[4]
set_location_assignment PIN_T23 -to ARD_IO[5]
set_location_assignment PIN_T22 -to ARD_IO[6]
set_location_assignment PIN_R24 -to ARD_IO[7]
set_location_assignment PIN_P20 -to ARD_IO[8]
set_location_assignment PIN_R23 -to ARD_IO[9]
set_location_assignment PIN_R25 -to ARD_IO[10]
set_location_assignment PIN_P23 -to ARD_IO[11]
set_location_assignment PIN_AC25 -to ARD_IO[12]
set_location_assignment PIN_AD25 -to ARD_IO[13]
set_location_assignment PIN_AB25 -to ARD_IO[14]
set_location_assignment PIN_AA24 -to ARD_IO[15]

#============================================================
# PCIE
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PCIE_PERST_n
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_RX_p[0]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_RX_p[1]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_RX_p[2]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_RX_p[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PCIE_SMBCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PCIE_SMBDAT
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_TX_p[0]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_TX_p[1]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_TX_p[2]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to PCIE_TX_p[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to PCIE_WAKE_n
set_location_assignment PIN_U22 -to PCIE_PERST_n
set_location_assignment PIN_V6 -to PCIE_REFCLK_p
set_location_assignment PIN_AD2 -to PCIE_RX_p[0]
set_location_assignment PIN_AB2 -to PCIE_RX_p[1]
set_location_assignment PIN_Y2 -to PCIE_RX_p[2]
set_location_assignment PIN_V2 -to PCIE_RX_p[3]
set_location_assignment PIN_R10 -to PCIE_SMBCLK
set_location_assignment PIN_AA7 -to PCIE_SMBDAT
set_location_assignment PIN_AE4 -to PCIE_TX_p[0]
set_location_assignment PIN_AC4 -to PCIE_TX_p[1]
set_location_assignment PIN_AA4 -to PCIE_TX_p[2]
set_location_assignment PIN_W4 -to PCIE_TX_p[3]
set_location_assignment PIN_Y8 -to PCIE_WAKE_n

#============================================================
# SMA
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SMA_CLKIN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SMA_CLKOUT
set_location_assignment PIN_T21 -to SMA_CLKIN
set_location_assignment PIN_Y25 -to SMA_CLKOUT

# rest
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files