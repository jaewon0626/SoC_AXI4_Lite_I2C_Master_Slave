vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/axi_lite_ipif_v3_0_4
vlib questa_lib/msim/lib_pkg_v1_0_2
vlib questa_lib/msim/lib_srl_fifo_v1_0_2
vlib questa_lib/msim/lib_cdc_v1_0_2
vlib questa_lib/msim/axi_uartlite_v2_0_26
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/microblaze_v11_0_4
vlib questa_lib/msim/lmb_v10_v3_0_11
vlib questa_lib/msim/lmb_bram_if_cntlr_v4_0_19
vlib questa_lib/msim/blk_mem_gen_v8_4_4
vlib questa_lib/msim/mdm_v3_2_19
vlib questa_lib/msim/proc_sys_reset_v5_0_13
vlib questa_lib/msim/generic_baseblocks_v2_1_0
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_register_slice_v2_1_22
vlib questa_lib/msim/fifo_generator_v13_2_5
vlib questa_lib/msim/axi_data_fifo_v2_1_21
vlib questa_lib/msim/axi_crossbar_v2_1_23

vmap xpm questa_lib/msim/xpm
vmap axi_lite_ipif_v3_0_4 questa_lib/msim/axi_lite_ipif_v3_0_4
vmap lib_pkg_v1_0_2 questa_lib/msim/lib_pkg_v1_0_2
vmap lib_srl_fifo_v1_0_2 questa_lib/msim/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 questa_lib/msim/lib_cdc_v1_0_2
vmap axi_uartlite_v2_0_26 questa_lib/msim/axi_uartlite_v2_0_26
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap microblaze_v11_0_4 questa_lib/msim/microblaze_v11_0_4
vmap lmb_v10_v3_0_11 questa_lib/msim/lmb_v10_v3_0_11
vmap lmb_bram_if_cntlr_v4_0_19 questa_lib/msim/lmb_bram_if_cntlr_v4_0_19
vmap blk_mem_gen_v8_4_4 questa_lib/msim/blk_mem_gen_v8_4_4
vmap mdm_v3_2_19 questa_lib/msim/mdm_v3_2_19
vmap proc_sys_reset_v5_0_13 questa_lib/msim/proc_sys_reset_v5_0_13
vmap generic_baseblocks_v2_1_0 questa_lib/msim/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_22 questa_lib/msim/axi_register_slice_v2_1_22
vmap fifo_generator_v13_2_5 questa_lib/msim/fifo_generator_v13_2_5
vmap axi_data_fifo_v2_1_21 questa_lib/msim/axi_data_fifo_v2_1_21
vmap axi_crossbar_v2_1_23 questa_lib/msim/axi_crossbar_v2_1_23

vlog -work xpm  -sv "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"C:/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work axi_lite_ipif_v3_0_4  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work lib_pkg_v1_0_2  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_uartlite_v2_0_26  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/5edb/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_axi_uartlite_0_0/sim/i2c_cpu_axi_uartlite_0_0.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ipshared/ea75/hdl/gpio_v1_0_S00_AXI.v" \
"../../../bd/i2c_cpu/ipshared/ea75/hdl/gpio_v1_0.v" \
"../../../bd/i2c_cpu/ip/i2c_cpu_gpio_0_0/sim/i2c_cpu_gpio_0_0.v" \
"../../../bd/i2c_cpu/ip/i2c_cpu_gpio_1_0/sim/i2c_cpu_gpio_1_0.v" \
"../../../bd/i2c_cpu/ip/i2c_cpu_gpio_2_0/sim/i2c_cpu_gpio_2_0.v" \
"../../../bd/i2c_cpu/ipshared/3fbf/hdl/i2c_master_v1_0_S00_AXI.v" \

vlog -work xil_defaultlib  -sv "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ipshared/3fbf/src/I2C_Master.sv" \

vlog -work xil_defaultlib  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ipshared/3fbf/hdl/i2c_master_v1_0.v" \
"../../../bd/i2c_cpu/ip/i2c_cpu_i2c_master_0_0/sim/i2c_cpu_i2c_master_0_0.v" \
"../../../bd/i2c_cpu/sim/i2c_cpu.v" \

vcom -work microblaze_v11_0_4  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/9285/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_microblaze_0_2/sim/i2c_cpu_microblaze_0_2.vhd" \

vcom -work lmb_v10_v3_0_11  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/c2ed/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_dlmb_v10_1/sim/i2c_cpu_dlmb_v10_1.vhd" \
"../../../bd/i2c_cpu/ip/i2c_cpu_ilmb_v10_1/sim/i2c_cpu_ilmb_v10_1.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_19  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/0b98/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_dlmb_bram_if_cntlr_1/sim/i2c_cpu_dlmb_bram_if_cntlr_1.vhd" \
"../../../bd/i2c_cpu/ip/i2c_cpu_ilmb_bram_if_cntlr_1/sim/i2c_cpu_ilmb_bram_if_cntlr_1.vhd" \

vlog -work blk_mem_gen_v8_4_4  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ip/i2c_cpu_lmb_bram_1/sim/i2c_cpu_lmb_bram_1.v" \

vcom -work mdm_v3_2_19  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/8715/hdl/mdm_v3_2_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_mdm_1_1/sim/i2c_cpu_mdm_1_1.vhd" \

vlog -work xil_defaultlib  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ip/i2c_cpu_clk_wiz_1_1/i2c_cpu_clk_wiz_1_1_clk_wiz.v" \
"../../../bd/i2c_cpu/ip/i2c_cpu_clk_wiz_1_1/i2c_cpu_clk_wiz_1_1.v" \

vcom -work proc_sys_reset_v5_0_13  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../bd/i2c_cpu/ip/i2c_cpu_rst_clk_wiz_1_100M_1/sim/i2c_cpu_rst_clk_wiz_1_100M_1.vhd" \

vlog -work generic_baseblocks_v2_1_0  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_22  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/af2c/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5  -93 \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vlog -work axi_data_fifo_v2_1_21  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/54c0/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_23  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/bc0a/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/d0f7" "+incdir+../../../../2025_11_14_I2C_IP_project.gen/sources_1/bd/i2c_cpu/ipshared/ec67/hdl" \
"../../../bd/i2c_cpu/ip/i2c_cpu_xbar_1/sim/i2c_cpu_xbar_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

