# AXI4-Lite Manager/Subordinate and Testbench
The modules and testbench are all SystemVerilog. Working proven against AMD AXI-VIP. \
Read 4 clock cycles \ 
Write 5 clock cycles
## Simulation on Questa/ModelSim
```
git clone --recurse-submodules https://github.com/iclibera/common_rtl.git
git clone --recurse-submodules https://github.com/iclibera/axi4_lite.git
cd axi4_lite/
vsim -c -do sim/questa/questa.do
```
### Explanation
There is an RTL and a testbench file: \
\
RTL       = `hdl/axi4_lite_sub.sv` \
Testbench = `sim/testbench.sv` \
\
`questa.do` file is run on Questa/ModelSim to create and run a simulation. \
\
Testbench wraps RTL files. \
\
The simulation scripts assumes common_rtl repository lives on the same directory as axi4_lite does. \
Current version of AXI4-Lite testbench runs on 250MHz AXI clock \
\
NOT IN THIS VERSION: \
To randomize AXI clock frequency, apply different seed values to the simulator (via -sv_seed = $random or such).

## Simulation on Verilator / XSim (Vivado Simulator)
Not supported yet.