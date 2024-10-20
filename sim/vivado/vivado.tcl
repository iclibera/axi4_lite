# Set up the directory and compile the design
xvlog -sv ../common_rtl/axi_vip/hdl/xil_common_vip_macros.svh ../common_rtl/axi_vip/hdl/xil_common_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_axi4pc.sv ../common_rtl/axi_vip/hdl/axi_vip_if.sv ../common_rtl/axi_vip/hdl/axi_vip_v1_1_vl_rfs.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0_pkg.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0.sv ../common_rtl/intf/axi4_if.sv sim/testbench.sv hdl/axi4_lite_sub.sv
echo "Compilation Complete"

# Elaborate the design
xelab -debug typical work.testbench -s sim_snapshot

# Run the simulation with the elaborated design
xsim sim_snapshot -R -gui

# Load and run the simulation
open_waveform setup.wcfg
run all
echo "Simulation run complete"