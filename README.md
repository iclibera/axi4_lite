# AXI4-Lite Module and Testbench
## Example simulation on Questa/ModelSim
### On Windows Command Prompt
```
git clone https://github.com/iclibera/axi4_lite.git
cd axi4_lite/
vsim -c -do sim/questa/questa.do
```
### Explanation
There is an RTL and a testbench file: \
\
RTL = `hdl/axi4_lite_sub.sv` \
Testbench = `sim/tb01_unit_test.sv` \
\
`questa.do` file is run on Questa/ModelSim to create and run a simulation. \
\
Testbench wrapps RTL files under it. \
\
The simulation scripts assumes common_rtl repository lives on the same directory as axi4_lite does.
In order to change the random set of clock periods, apply different seed values to the simulator (via -sv_seed = $random or such).
## Usage on Verilator
Not supported yet.
## Usage on Vivado Simulator (XSim)
Not supported yet.
## HDL and Simulation folders
### hdl
AXI4-Lite Subordinate module lives under hdl/
### sim
Testbench and other files regarding simulation live under sim/ folder