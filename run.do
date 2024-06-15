vlib work

vlog -work xilinx_vip -incr -mfcu -sv -L axi_vip_v1_1_15 -L xilinx_vip "+incdir+C:/Xilinx/Vivado/2023.2/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2023.2/data/xilinx_vip/hdl/axi_vip_if.sv" \

vlog -sv axi_vip_v1_1_vl_rfs.sv
vlog -sv vip_axi_vip_0_pkg.sv
vlog -sv vip_axi_vip_0.sv
vlog -sv axi_sub.sv
vlog -sv example_tb.sv

vsim -voptargs="+acc" -onfinish stop -gui work.example_tb
run -all