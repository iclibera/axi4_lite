vlib work

vlog -work xilinx_vip -incr -mfcu -sv -L axi_vip_v1_1_15 -L xilinx_vip \
"+incdir+../axi_vip/hdl/xil_common_vip_macros.svh" \
"../axi_vip/hdl/xil_common_vip_pkg.sv" \
"../axi_vip/hdl/axi_vip_pkg.sv" \
"../axi_vip/hdl/axi_vip_axi4pc.sv" \
"../axi_vip/hdl/axi_vip_if.sv" \
vlog -sv ../axi_vip/hdl/axi_vip_v1_1_vl_rfs.sv
vlog -sv ../axi_vip/hdl/vip_axi_vip_0_pkg.sv
vlog -sv ../axi_vip/hdl/vip_axi_vip_0.sv
vlog -sv ../hdl/axi4_lite_sub.sv
vlog -sv tb01_unit_test.sv

vsim -voptargs="+acc" -onfinish stop -gui work.example_tb
run -all