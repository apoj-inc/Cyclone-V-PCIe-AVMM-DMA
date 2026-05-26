# qsys scripting (.tcl) file for my_pcie
package require -exact qsys 16.0

create_system {my_pcie}

set_project_property DEVICE_FAMILY {Cyclone V}
set_project_property DEVICE {5CGTFD9D5F27C7}
set_project_property HIDE_FROM_IP_CATALOG {false}

# Instances and instance parameters
# (disabled instances are intentionally culled)
add_instance DMA_0 avmm_exporter 1.0
set_instance_parameter_value DMA_0 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_0 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_0 {AVMM_DATA_WIDTH} {128}

add_instance DMA_1 avmm_exporter 1.0
set_instance_parameter_value DMA_1 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_1 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_1 {AVMM_DATA_WIDTH} {128}

add_instance DMA_10 avmm_exporter 1.0
set_instance_parameter_value DMA_10 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_10 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_10 {AVMM_DATA_WIDTH} {128}

add_instance DMA_11 avmm_exporter 1.0
set_instance_parameter_value DMA_11 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_11 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_11 {AVMM_DATA_WIDTH} {128}

add_instance DMA_12 avmm_exporter 1.0
set_instance_parameter_value DMA_12 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_12 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_12 {AVMM_DATA_WIDTH} {128}

add_instance DMA_13 avmm_exporter 1.0
set_instance_parameter_value DMA_13 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_13 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_13 {AVMM_DATA_WIDTH} {128}

add_instance DMA_14 avmm_exporter 1.0
set_instance_parameter_value DMA_14 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_14 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_14 {AVMM_DATA_WIDTH} {128}

add_instance DMA_15 avmm_exporter 1.0
set_instance_parameter_value DMA_15 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_15 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_15 {AVMM_DATA_WIDTH} {128}

add_instance DMA_2 avmm_exporter 1.0
set_instance_parameter_value DMA_2 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_2 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_2 {AVMM_DATA_WIDTH} {128}

add_instance DMA_3 avmm_exporter 1.0
set_instance_parameter_value DMA_3 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_3 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_3 {AVMM_DATA_WIDTH} {128}

add_instance DMA_4 avmm_exporter 1.0
set_instance_parameter_value DMA_4 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_4 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_4 {AVMM_DATA_WIDTH} {128}

add_instance DMA_5 avmm_exporter 1.0
set_instance_parameter_value DMA_5 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_5 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_5 {AVMM_DATA_WIDTH} {128}

add_instance DMA_6 avmm_exporter 1.0
set_instance_parameter_value DMA_6 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_6 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_6 {AVMM_DATA_WIDTH} {128}

add_instance DMA_7 avmm_exporter 1.0
set_instance_parameter_value DMA_7 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_7 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_7 {AVMM_DATA_WIDTH} {128}

add_instance DMA_8 avmm_exporter 1.0
set_instance_parameter_value DMA_8 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_8 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_8 {AVMM_DATA_WIDTH} {128}

add_instance DMA_9 avmm_exporter 1.0
set_instance_parameter_value DMA_9 {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value DMA_9 {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value DMA_9 {AVMM_DATA_WIDTH} {128}

add_instance clk_0 clock_source 25.1
set_instance_parameter_value clk_0 {clockFrequency} {125000000.0}
set_instance_parameter_value clk_0 {clockFrequencyKnown} {1}
set_instance_parameter_value clk_0 {resetSynchronousEdges} {NONE}

add_instance csr avmm_exporter 1.0
set_instance_parameter_value csr {AVMM_ADDR_WIDTH} {12}
set_instance_parameter_value csr {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value csr {AVMM_DATA_WIDTH} {128}

add_instance decoder avmm_exporter 1.0
set_instance_parameter_value decoder {AVMM_ADDR_WIDTH} {12}
set_instance_parameter_value decoder {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value decoder {AVMM_DATA_WIDTH} {128}

add_instance env_csr avmm_exporter 1.0
set_instance_parameter_value env_csr {AVMM_ADDR_WIDTH} {12}
set_instance_parameter_value env_csr {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value env_csr {AVMM_DATA_WIDTH} {128}

add_instance msix avmm_exporter 1.0
set_instance_parameter_value msix {AVMM_ADDR_WIDTH} {12}
set_instance_parameter_value msix {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value msix {AVMM_DATA_WIDTH} {128}

add_instance pcie_cv_hip_avmm_0 altera_pcie_cv_hip_avmm 25.1
set_instance_parameter_value pcie_cv_hip_avmm_0 {AST_LITE} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {AVALON_ADDR_WIDTH} {64}
set_instance_parameter_value pcie_cv_hip_avmm_0 {AddressPage} {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
set_instance_parameter_value pcie_cv_hip_avmm_0 {BYPASSS_A2P_TRANSLATION} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_IS_FIXED} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_NUM_ENTRIES} {2}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_A2P_ADDR_MAP_PASS_THRU_BITS} {32}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B0} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B1} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B2} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B3} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B4} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_AVALON_ADDR_B5} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B0} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B1} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B2} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B3} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B4} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_P2A_FIXED_AVALON_ADDR_B5} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_PCIE_MODE} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_PCIE_RX_LITE} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CB_RP_S_ADDR_WIDTH} {32}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_COMMON_CLOCK_MODE} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_ENABLE_A2P_INTERRUPT} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_ENABLE_ADVANCED_INTERRUPT} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_ENABLE_HIP_STATUS} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_ENABLE_HIP_STATUS_EXTENSION} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_IMPL_CRA_AV_SLAVE_PORT} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {CG_RXM_IRQ_NUM} {16}
set_instance_parameter_value pcie_cv_hip_avmm_0 {NUM_PREFETCH_MASTERS} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {PCIeAddress31_0} {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
set_instance_parameter_value pcie_cv_hip_avmm_0 {PCIeAddress63_32} {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
set_instance_parameter_value pcie_cv_hip_avmm_0 {RXM_BEN_WIDTH} {8}
set_instance_parameter_value pcie_cv_hip_avmm_0 {RXM_DATA_WIDTH} {64}
set_instance_parameter_value pcie_cv_hip_avmm_0 {TX_S_ADDR_WIDTH} {64}
set_instance_parameter_value pcie_cv_hip_avmm_0 {advanced_default_parameter_override} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {altpcie_avmm_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {atomic_malformed_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {atomic_op_completer_32bit_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {atomic_op_completer_64bit_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {atomic_op_routing_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {avmm_width_hwtcl} {128}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar0_type_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar1_type_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar2_type_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar3_type_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar4_type_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bar5_type_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bridge_port_ssid_support_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bridge_port_vga_enable_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bypass_cdc_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {bypass_tl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {cas_completer_128bit_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {cdc_dummy_insert_limit_advanced_default_hwtcl} {11}
set_instance_parameter_value pcie_cv_hip_avmm_0 {class_code_hwtcl} {16711680}
set_instance_parameter_value pcie_cv_hip_avmm_0 {completion_timeout_hwtcl} {ABCD}
set_instance_parameter_value pcie_cv_hip_avmm_0 {coreclkout_hip_phaseshift_hwtcl} {0 ps}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d0_pme_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d1_pme_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d1_support_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d2_pme_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d2_support_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d3_cold_pme_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {d3_hot_pme_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {data_pack_rx_hwtcl} {disable}
set_instance_parameter_value pcie_cv_hip_avmm_0 {deemphasis_enable_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {deskew_comma_hwtcl} {skp_eieos_deskw}
set_instance_parameter_value pcie_cv_hip_avmm_0 {device_id_hwtcl} {55296}
set_instance_parameter_value pcie_cv_hip_avmm_0 {device_number_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {diffclock_nfts_count_advanced_default_hwtcl} {255}
set_instance_parameter_value pcie_cv_hip_avmm_0 {disable_link_x2_support_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {disable_snoop_packet_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {dll_active_report_support_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ecrc_check_capable_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ecrc_gen_capable_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ei_delay_powerdown_count_advanced_default_hwtcl} {10}
set_instance_parameter_value pcie_cv_hip_avmm_0 {eie_before_nfts_count_advanced_default_hwtcl} {4}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_completion_timeout_disable_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_function_msix_support_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_l0s_aspm_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_l1_aspm_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_rx_buffer_checking_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {enable_slot_register_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {endpoint_l0_latency_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {endpoint_l1_latency_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {expansion_base_address_register_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {extend_tag_field_hwtcl} {32}
set_instance_parameter_value pcie_cv_hip_avmm_0 {extended_format_field_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {extended_tag_reset_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {fc_init_timer_advanced_default_hwtcl} {1024}
set_instance_parameter_value pcie_cv_hip_avmm_0 {fixed_address_mode} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {flow_control_timeout_count_advanced_default_hwtcl} {200}
set_instance_parameter_value pcie_cv_hip_avmm_0 {flow_control_update_count_advanced_default_hwtcl} {30}
set_instance_parameter_value pcie_cv_hip_avmm_0 {flr_capability_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {force_hrc} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {force_src} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {gen123_lane_rate_mode_hwtcl} {Gen2 (5.0 Gbps)}
set_instance_parameter_value pcie_cv_hip_avmm_0 {gen2_diffclock_nfts_count_advanced_default_hwtcl} {255}
set_instance_parameter_value pcie_cv_hip_avmm_0 {gen2_sameclock_nfts_count_advanced_default_hwtcl} {255}
set_instance_parameter_value pcie_cv_hip_avmm_0 {gen3_rxfreqlock_counter_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {hip_reconfig_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {hot_plug_support_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {in_cvp_mode_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {indicator_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {interrupt_pin_hwtcl} {inta}
set_instance_parameter_value pcie_cv_hip_avmm_0 {io_window_addr_width_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l01_entry_latency_advanced_default_hwtcl} {31}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l0_exit_latency_diffclock_advanced_default_hwtcl} {6}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l0_exit_latency_sameclock_advanced_default_hwtcl} {6}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l1_exit_latency_diffclock_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l1_exit_latency_sameclock_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {l2_async_logic_advanced_default_hwtcl} {disable}
set_instance_parameter_value pcie_cv_hip_avmm_0 {lane_mask_hwtcl} {x4}
set_instance_parameter_value pcie_cv_hip_avmm_0 {low_priority_vc_advanced_default_hwtcl} {single_vc}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ltr_mechanism_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ltssm_1ms_timeout_hwtcl} {disable}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ltssm_freqlocked_check_hwtcl} {disable}
set_instance_parameter_value pcie_cv_hip_avmm_0 {max_payload_size_hwtcl} {256}
set_instance_parameter_value pcie_cv_hip_avmm_0 {maximum_current_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msi_64bit_addressing_capable_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msi_masking_capable_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msi_multi_message_capable_hwtcl} {16}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msi_support_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msix_pba_bir_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msix_pba_offset_hwtcl} {768.0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msix_table_bir_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msix_table_offset_hwtcl} {0.0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {msix_table_size_hwtcl} {32}
set_instance_parameter_value pcie_cv_hip_avmm_0 {no_command_completed_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {no_soft_reset_advanced_default_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {override_rxbuffer_cred_preset} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {override_tbpartner_driver_setting_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {pcie_qsys} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {pclk_out_sel_advanced_default_hwtcl} {pclk}
set_instance_parameter_value pcie_cv_hip_avmm_0 {pipex1_debug_sel_advanced_default_hwtcl} {disable}
set_instance_parameter_value pcie_cv_hip_avmm_0 {pldclk_hip_phase_shift_hwtcl} {0 ps}
set_instance_parameter_value pcie_cv_hip_avmm_0 {pll_refclk_freq_hwtcl} {100 MHz}
set_instance_parameter_value pcie_cv_hip_avmm_0 {port_link_number_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {port_type_hwtcl} {Native endpoint}
set_instance_parameter_value pcie_cv_hip_avmm_0 {prefetchable_mem_window_addr_width_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {register_pipe_signals_advanced_default_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {reserved_debug_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {retry_buffer_last_active_address_advanced_default_hwtcl} {255}
set_instance_parameter_value pcie_cv_hip_avmm_0 {revision_id_hwtcl} {5}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rpre_emph_a_val_hwtcl} {11}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rpre_emph_b_val_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rpre_emph_c_val_hwtcl} {22}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rpre_emph_d_val_hwtcl} {12}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rpre_emph_e_val_hwtcl} {21}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rvod_sel_a_val_hwtcl} {50}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rvod_sel_b_val_hwtcl} {34}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rvod_sel_c_val_hwtcl} {50}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rvod_sel_d_val_hwtcl} {50}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rvod_sel_e_val_hwtcl} {9}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rx_cdc_almost_full_advanced_default_hwtcl} {12}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rx_l0s_count_idl_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {rxbuffer_rxreq_hwtcl} {Low}
set_instance_parameter_value pcie_cv_hip_avmm_0 {sameclock_nfts_count_advanced_default_hwtcl} {255}
set_instance_parameter_value pcie_cv_hip_avmm_0 {serial_sim_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {set_pld_clk_x1_625MHz_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {skp_os_gen3_count_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {skp_os_schedule_count_advanced_default_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {slot_number_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {slot_power_limit_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {slot_power_scale_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {slotclkcfg_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ssid_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {ssvid_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {subsystem_device_id_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {subsystem_vendor_id_hwtcl} {4466}
set_instance_parameter_value pcie_cv_hip_avmm_0 {surprise_down_error_support_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {tph_completer_hwtcl} {false}
set_instance_parameter_value pcie_cv_hip_avmm_0 {tx_cdc_almost_empty_advanced_default_hwtcl} {5}
set_instance_parameter_value pcie_cv_hip_avmm_0 {tx_cdc_almost_full_advanced_default_hwtcl} {11}
set_instance_parameter_value pcie_cv_hip_avmm_0 {use_aer_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {use_ast_parity} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {use_crc_forwarding_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {use_rx_st_be_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {use_tl_cfg_sync_advanced_default_hwtcl} {1}
set_instance_parameter_value pcie_cv_hip_avmm_0 {user_id_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {vc0_clk_enable_advanced_default_hwtcl} {true}
set_instance_parameter_value pcie_cv_hip_avmm_0 {vendor_id_hwtcl} {4466}
set_instance_parameter_value pcie_cv_hip_avmm_0 {vsec_id_hwtcl} {4466}
set_instance_parameter_value pcie_cv_hip_avmm_0 {vsec_rev_hwtcl} {0}
set_instance_parameter_value pcie_cv_hip_avmm_0 {wrong_device_id_hwtcl} {disable}

add_instance pll_0 altera_pll 25.1
set_instance_parameter_value pll_0 {debug_print_output} {0}
set_instance_parameter_value pll_0 {debug_use_rbc_taf_method} {0}
set_instance_parameter_value pll_0 {gui_active_clk} {0}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency0} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency1} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency10} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency11} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency12} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency13} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency14} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency15} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency16} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency17} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency2} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency3} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency4} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency5} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency6} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency7} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency8} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_output_clock_frequency9} {0 MHz}
set_instance_parameter_value pll_0 {gui_actual_phase_shift0} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift1} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift10} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift11} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift12} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift13} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift14} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift15} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift16} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift17} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift2} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift3} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift4} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift5} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift6} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift7} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift8} {0}
set_instance_parameter_value pll_0 {gui_actual_phase_shift9} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter0} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter1} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter10} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter11} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter12} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter13} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter14} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter15} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter16} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter17} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter2} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter3} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter4} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter5} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter6} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter7} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter8} {0}
set_instance_parameter_value pll_0 {gui_cascade_counter9} {0}
set_instance_parameter_value pll_0 {gui_cascade_outclk_index} {0}
set_instance_parameter_value pll_0 {gui_channel_spacing} {0.0}
set_instance_parameter_value pll_0 {gui_clk_bad} {0}
set_instance_parameter_value pll_0 {gui_device_speed_grade} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c0} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c1} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c10} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c11} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c12} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c13} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c14} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c15} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c16} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c17} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c2} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c3} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c4} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c5} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c6} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c7} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c8} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_c9} {1}
set_instance_parameter_value pll_0 {gui_divide_factor_n} {1}
set_instance_parameter_value pll_0 {gui_dps_cntr} {C0}
set_instance_parameter_value pll_0 {gui_dps_dir} {Positive}
set_instance_parameter_value pll_0 {gui_dps_num} {1}
set_instance_parameter_value pll_0 {gui_dsm_out_sel} {1st_order}
set_instance_parameter_value pll_0 {gui_duty_cycle0} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle1} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle10} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle11} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle12} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle13} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle14} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle15} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle16} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle17} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle2} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle3} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle4} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle5} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle6} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle7} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle8} {50}
set_instance_parameter_value pll_0 {gui_duty_cycle9} {50}
set_instance_parameter_value pll_0 {gui_en_adv_params} {0}
set_instance_parameter_value pll_0 {gui_en_dps_ports} {0}
set_instance_parameter_value pll_0 {gui_en_phout_ports} {0}
set_instance_parameter_value pll_0 {gui_en_reconf} {0}
set_instance_parameter_value pll_0 {gui_enable_cascade_in} {0}
set_instance_parameter_value pll_0 {gui_enable_cascade_out} {0}
set_instance_parameter_value pll_0 {gui_enable_mif_dps} {0}
set_instance_parameter_value pll_0 {gui_feedback_clock} {Global Clock}
set_instance_parameter_value pll_0 {gui_frac_multiply_factor} {1.0}
set_instance_parameter_value pll_0 {gui_fractional_cout} {32}
set_instance_parameter_value pll_0 {gui_mif_generate} {0}
set_instance_parameter_value pll_0 {gui_multiply_factor} {1}
set_instance_parameter_value pll_0 {gui_number_of_clocks} {1}
set_instance_parameter_value pll_0 {gui_operation_mode} {direct}
set_instance_parameter_value pll_0 {gui_output_clock_frequency0} {50.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency1} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency10} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency11} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency12} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency13} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency14} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency15} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency16} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency17} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency2} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency3} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency4} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency5} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency6} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency7} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency8} {100.0}
set_instance_parameter_value pll_0 {gui_output_clock_frequency9} {100.0}
set_instance_parameter_value pll_0 {gui_phase_shift0} {0}
set_instance_parameter_value pll_0 {gui_phase_shift1} {0}
set_instance_parameter_value pll_0 {gui_phase_shift10} {0}
set_instance_parameter_value pll_0 {gui_phase_shift11} {0}
set_instance_parameter_value pll_0 {gui_phase_shift12} {0}
set_instance_parameter_value pll_0 {gui_phase_shift13} {0}
set_instance_parameter_value pll_0 {gui_phase_shift14} {0}
set_instance_parameter_value pll_0 {gui_phase_shift15} {0}
set_instance_parameter_value pll_0 {gui_phase_shift16} {0}
set_instance_parameter_value pll_0 {gui_phase_shift17} {0}
set_instance_parameter_value pll_0 {gui_phase_shift2} {0}
set_instance_parameter_value pll_0 {gui_phase_shift3} {0}
set_instance_parameter_value pll_0 {gui_phase_shift4} {0}
set_instance_parameter_value pll_0 {gui_phase_shift5} {0}
set_instance_parameter_value pll_0 {gui_phase_shift6} {0}
set_instance_parameter_value pll_0 {gui_phase_shift7} {0}
set_instance_parameter_value pll_0 {gui_phase_shift8} {0}
set_instance_parameter_value pll_0 {gui_phase_shift9} {0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg0} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg1} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg10} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg11} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg12} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg13} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg14} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg15} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg16} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg17} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg2} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg3} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg4} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg5} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg6} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg7} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg8} {0.0}
set_instance_parameter_value pll_0 {gui_phase_shift_deg9} {0.0}
set_instance_parameter_value pll_0 {gui_phout_division} {1}
set_instance_parameter_value pll_0 {gui_pll_auto_reset} {Off}
set_instance_parameter_value pll_0 {gui_pll_bandwidth_preset} {Auto}
set_instance_parameter_value pll_0 {gui_pll_cascading_mode} {Create an adjpllin signal to connect with an upstream PLL}
set_instance_parameter_value pll_0 {gui_pll_mode} {Integer-N PLL}
set_instance_parameter_value pll_0 {gui_ps_units0} {ps}
set_instance_parameter_value pll_0 {gui_ps_units1} {ps}
set_instance_parameter_value pll_0 {gui_ps_units10} {ps}
set_instance_parameter_value pll_0 {gui_ps_units11} {ps}
set_instance_parameter_value pll_0 {gui_ps_units12} {ps}
set_instance_parameter_value pll_0 {gui_ps_units13} {ps}
set_instance_parameter_value pll_0 {gui_ps_units14} {ps}
set_instance_parameter_value pll_0 {gui_ps_units15} {ps}
set_instance_parameter_value pll_0 {gui_ps_units16} {ps}
set_instance_parameter_value pll_0 {gui_ps_units17} {ps}
set_instance_parameter_value pll_0 {gui_ps_units2} {ps}
set_instance_parameter_value pll_0 {gui_ps_units3} {ps}
set_instance_parameter_value pll_0 {gui_ps_units4} {ps}
set_instance_parameter_value pll_0 {gui_ps_units5} {ps}
set_instance_parameter_value pll_0 {gui_ps_units6} {ps}
set_instance_parameter_value pll_0 {gui_ps_units7} {ps}
set_instance_parameter_value pll_0 {gui_ps_units8} {ps}
set_instance_parameter_value pll_0 {gui_ps_units9} {ps}
set_instance_parameter_value pll_0 {gui_refclk1_frequency} {100.0}
set_instance_parameter_value pll_0 {gui_refclk_switch} {0}
set_instance_parameter_value pll_0 {gui_reference_clock_frequency} {125.0}
set_instance_parameter_value pll_0 {gui_switchover_delay} {0}
set_instance_parameter_value pll_0 {gui_switchover_mode} {Automatic Switchover}
set_instance_parameter_value pll_0 {gui_use_locked} {0}

add_instance user_msi avmm_exporter 1.0
set_instance_parameter_value user_msi {AVMM_ADDR_WIDTH} {64}
set_instance_parameter_value user_msi {AVMM_BURST_WIDTH} {6}
set_instance_parameter_value user_msi {AVMM_DATA_WIDTH} {128}

# exported interfaces
add_interface core_clk clock source
set_interface_property core_clk EXPORT_OF clk_0.clk
add_interface core_reset reset source
set_interface_property core_reset EXPORT_OF clk_0.clk_reset
add_interface csr_avmm_m avalon master
set_interface_property csr_avmm_m EXPORT_OF csr.avmm_m
add_interface decoder_avmm_m avalon master
set_interface_property decoder_avmm_m EXPORT_OF decoder.avmm_m
add_interface dma_0_avmm_s avalon slave
set_interface_property dma_0_avmm_s EXPORT_OF DMA_0.avmm_s
add_interface dma_10_avmm_s avalon slave
set_interface_property dma_10_avmm_s EXPORT_OF DMA_10.avmm_s
add_interface dma_11_avmm_s avalon slave
set_interface_property dma_11_avmm_s EXPORT_OF DMA_11.avmm_s
add_interface dma_12_avmm_s avalon slave
set_interface_property dma_12_avmm_s EXPORT_OF DMA_12.avmm_s
add_interface dma_13_avmm_s avalon slave
set_interface_property dma_13_avmm_s EXPORT_OF DMA_13.avmm_s
add_interface dma_14_avmm_s avalon slave
set_interface_property dma_14_avmm_s EXPORT_OF DMA_14.avmm_s
add_interface dma_15_avmm_s avalon slave
set_interface_property dma_15_avmm_s EXPORT_OF DMA_15.avmm_s
add_interface dma_1_avmm_s avalon slave
set_interface_property dma_1_avmm_s EXPORT_OF DMA_1.avmm_s
add_interface dma_2_avmm_s avalon slave
set_interface_property dma_2_avmm_s EXPORT_OF DMA_2.avmm_s
add_interface dma_3_avmm_s avalon slave
set_interface_property dma_3_avmm_s EXPORT_OF DMA_3.avmm_s
add_interface dma_4_avmm_s avalon slave
set_interface_property dma_4_avmm_s EXPORT_OF DMA_4.avmm_s
add_interface dma_5_avmm_s avalon slave
set_interface_property dma_5_avmm_s EXPORT_OF DMA_5.avmm_s
add_interface dma_6_avmm_s avalon slave
set_interface_property dma_6_avmm_s EXPORT_OF DMA_6.avmm_s
add_interface dma_7_avmm_s avalon slave
set_interface_property dma_7_avmm_s EXPORT_OF DMA_7.avmm_s
add_interface dma_8_avmm_s avalon slave
set_interface_property dma_8_avmm_s EXPORT_OF DMA_8.avmm_s
add_interface dma_9_avmm_s avalon slave
set_interface_property dma_9_avmm_s EXPORT_OF DMA_9.avmm_s
add_interface env_csr_avmm_m avalon master
set_interface_property env_csr_avmm_m EXPORT_OF env_csr.avmm_m
add_interface msix_avmm_m avalon master
set_interface_property msix_avmm_m EXPORT_OF msix.avmm_m
add_interface pcie_cv_hip_avmm_0_hip_ctrl conduit end
set_interface_property pcie_cv_hip_avmm_0_hip_ctrl EXPORT_OF pcie_cv_hip_avmm_0.hip_ctrl
add_interface pcie_cv_hip_avmm_0_hip_pipe conduit end
set_interface_property pcie_cv_hip_avmm_0_hip_pipe EXPORT_OF pcie_cv_hip_avmm_0.hip_pipe
add_interface pcie_cv_hip_avmm_0_hip_serial conduit end
set_interface_property pcie_cv_hip_avmm_0_hip_serial EXPORT_OF pcie_cv_hip_avmm_0.hip_serial
add_interface pcie_cv_hip_avmm_0_intx_interface conduit end
set_interface_property pcie_cv_hip_avmm_0_intx_interface EXPORT_OF pcie_cv_hip_avmm_0.INTX_Interface
add_interface pcie_cv_hip_avmm_0_msi_control conduit end
set_interface_property pcie_cv_hip_avmm_0_msi_control EXPORT_OF pcie_cv_hip_avmm_0.MSI_Control
add_interface pcie_cv_hip_avmm_0_msi_interface conduit end
set_interface_property pcie_cv_hip_avmm_0_msi_interface EXPORT_OF pcie_cv_hip_avmm_0.MSI_Interface
add_interface pcie_cv_hip_avmm_0_msix_interface conduit end
set_interface_property pcie_cv_hip_avmm_0_msix_interface EXPORT_OF pcie_cv_hip_avmm_0.MSIX_Interface
add_interface pcie_cv_hip_avmm_0_npor conduit end
set_interface_property pcie_cv_hip_avmm_0_npor EXPORT_OF pcie_cv_hip_avmm_0.npor
add_interface pcie_cv_hip_avmm_0_reconfig_busy conduit end
set_interface_property pcie_cv_hip_avmm_0_reconfig_busy EXPORT_OF pcie_cv_hip_avmm_0.reconfig_busy
add_interface pcie_cv_hip_avmm_0_reconfig_clk_locked conduit end
set_interface_property pcie_cv_hip_avmm_0_reconfig_clk_locked EXPORT_OF pcie_cv_hip_avmm_0.reconfig_clk_locked
add_interface pcie_cv_hip_avmm_0_reconfig_from_xcvr conduit end
set_interface_property pcie_cv_hip_avmm_0_reconfig_from_xcvr EXPORT_OF pcie_cv_hip_avmm_0.reconfig_from_xcvr
add_interface pcie_cv_hip_avmm_0_reconfig_to_xcvr conduit end
set_interface_property pcie_cv_hip_avmm_0_reconfig_to_xcvr EXPORT_OF pcie_cv_hip_avmm_0.reconfig_to_xcvr
add_interface pcie_cv_hip_avmm_0_refclk clock sink
set_interface_property pcie_cv_hip_avmm_0_refclk EXPORT_OF pcie_cv_hip_avmm_0.refclk
add_interface pll_50mhz clock source
set_interface_property pll_50mhz EXPORT_OF pll_0.outclk0
add_interface user_msi_avmm_s avalon slave
set_interface_property user_msi_avmm_s EXPORT_OF user_msi.avmm_s

# connections and connection parameters
add_connection DMA_0.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_0.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_0.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_0.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_1.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_1.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_1.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_1.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_10.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_10.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_10.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_10.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_11.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_11.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_11.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_11.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_12.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_12.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_12.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_12.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_13.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_13.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_13.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_13.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_14.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_14.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_14.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_14.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_15.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_15.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_15.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_15.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_2.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_2.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_2.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_2.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_3.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_3.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_3.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_3.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_4.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_4.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_4.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_4.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_5.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_5.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_5.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_5.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_6.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_6.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_6.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_6.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_7.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_7.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_7.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_7.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_8.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_8.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_8.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_8.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection DMA_9.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value DMA_9.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value DMA_9.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value DMA_9.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

add_connection pcie_cv_hip_avmm_0.Rxm_BAR0 msix.avmm_s
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR0/msix.avmm_s arbitrationPriority {1}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR0/msix.avmm_s baseAddress {0x0000}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR0/msix.avmm_s defaultConnection {0}

add_connection pcie_cv_hip_avmm_0.Rxm_BAR2 csr.avmm_s
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/csr.avmm_s arbitrationPriority {1}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/csr.avmm_s baseAddress {0x0000}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/csr.avmm_s defaultConnection {0}

add_connection pcie_cv_hip_avmm_0.Rxm_BAR2 decoder.avmm_s
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/decoder.avmm_s arbitrationPriority {1}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/decoder.avmm_s baseAddress {0x1000}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/decoder.avmm_s defaultConnection {0}

add_connection pcie_cv_hip_avmm_0.Rxm_BAR2 env_csr.avmm_s
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/env_csr.avmm_s arbitrationPriority {1}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/env_csr.avmm_s baseAddress {0x2000}
set_connection_parameter_value pcie_cv_hip_avmm_0.Rxm_BAR2/env_csr.avmm_s defaultConnection {0}

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_0.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_1.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_10.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_11.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_12.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_13.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_14.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_15.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_2.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_3.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_4.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_5.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_6.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_7.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_8.clock

add_connection pcie_cv_hip_avmm_0.coreclkout DMA_9.clock

add_connection pcie_cv_hip_avmm_0.coreclkout clk_0.clk_in

add_connection pcie_cv_hip_avmm_0.coreclkout csr.clock

add_connection pcie_cv_hip_avmm_0.coreclkout decoder.clock

add_connection pcie_cv_hip_avmm_0.coreclkout env_csr.clock

add_connection pcie_cv_hip_avmm_0.coreclkout msix.clock

add_connection pcie_cv_hip_avmm_0.coreclkout pll_0.refclk

add_connection pcie_cv_hip_avmm_0.coreclkout user_msi.clock

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_0.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_1.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_10.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_11.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_12.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_13.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_14.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_15.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_2.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_3.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_4.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_5.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_6.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_7.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_8.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status DMA_9.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status clk_0.clk_in_reset

add_connection pcie_cv_hip_avmm_0.nreset_status csr.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status decoder.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status env_csr.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status msix.reset_sink

add_connection pcie_cv_hip_avmm_0.nreset_status pll_0.reset

add_connection pcie_cv_hip_avmm_0.nreset_status user_msi.reset_sink

add_connection user_msi.avmm_m pcie_cv_hip_avmm_0.Txs
set_connection_parameter_value user_msi.avmm_m/pcie_cv_hip_avmm_0.Txs arbitrationPriority {1}
set_connection_parameter_value user_msi.avmm_m/pcie_cv_hip_avmm_0.Txs baseAddress {0x0000}
set_connection_parameter_value user_msi.avmm_m/pcie_cv_hip_avmm_0.Txs defaultConnection {0}

# interconnect requirements
set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {3}

save_system {my_pcie.qsys}
