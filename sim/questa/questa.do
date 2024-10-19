# Sets up the directory
vlib work

vlog -work xilinx_vip -incr -mfcu -sv -L axi_vip_v1_1_15 -L xilinx_vip \
"+incdir+../../common_rtl/axi_vip/hdl/xil_common_vip_macros.svh" \
"../../common_rtl/axi_vip/hdl/xil_common_vip_pkg.sv" \
"../../common_rtl/axi_vip/hdl/axi_vip_pkg.sv" \
"../../common_rtl/axi_vip/hdl/axi_vip_axi4pc.sv" \
"../../common_rtl/axi_vip/hdl/axi_vip_if.sv" \
vlog -sv ../../common_rtl/axi_vip/hdl/axi_vip_v1_1_vl_rfs.sv
vlog -sv ../../common_rtl/axi_vip/hdl/vip_axi_vip_0_pkg.sv
vlog -sv ../../common_rtl/axi_vip/hdl/vip_axi_vip_0.sv
vlog -sv ../hdl/axi4_lite_sub.sv
vlog -sv testbench.sv

# Runs the simulation
vsim -voptargs="+acc" -onfinish stop -gui work.example_tb
run -all