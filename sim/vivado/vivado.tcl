# Set up the directory and compile the design
xvlog -sv sim/testbench.sv hdl/axi4_lite_sub.sv
echo "Compilation Complete"

# Elaborate the design
xelab -debug typical work.testbench -s sim_snapshot

# Run the simulation with the elaborated design
xsim sim_snapshot -R -gui

# Load and run the simulation
open_waveform setup.wcfg
run all
echo "Simulation run complete"