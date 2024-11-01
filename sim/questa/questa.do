# Sets up the directory / add all the files to be compiled here
vlog -work work -sv ../common_rtl/axi_vip/hdl/xil_common_vip_macros.svh ../common_rtl/axi_vip/hdl/xil_common_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_axi4pc.sv ../common_rtl/axi_vip/hdl/axi_vip_if.sv ../common_rtl/axi_vip/hdl/axi_vip_v1_1_vl_rfs.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0_pkg.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0.sv ../common_rtl/intf/axi4_if.sv ../common_rtl/intf/axi4_reg_if.sv sim/testbench.sv hdl/axi4_lite.sv
echo "Compilation Complete"

# Loads the simulation
vopt work.testbench -o optimized_tb +acc
echo "Simulation loaded"

# Sets simulation library
vlib work

# Runs the simulation
vsim -vopt optimized_tb

# Applies simulation runtime options
## add wave -position end -radix unsigned /testbench/
## add wave -position end -radix unsigned /testbench/*
# Leaf toggle
config wave -signalnamewidth 1

run -all
echo "Simulation run complete"

# stop
# quit