VERILATOR = verilator
VERILATOR_FLAGS = -Wall --cc --trace --timing --exe --top-module sim/testbench

# Source and testbench files
VFILES = ../common_rtl/axi_vip/hdl/xil_common_vip_macros.svh ../common_rtl/axi_vip/hdl/xil_common_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_pkg.sv ../common_rtl/axi_vip/hdl/axi_vip_axi4pc.sv ../common_rtl/axi_vip/hdl/axi_vip_if.sv ../common_rtl/axi_vip/hdl/axi_vip_v1_1_vl_rfs.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0_pkg.sv ../common_rtl/axi_vip/hdl/vip_axi_vip_0.sv sim/testbench.sv hdl/axi4_lite_sub.sv

# Target executable
EXE = sim

# C++ driver source
CPP_SOURCE = sim_main.cpp

# Additional configurations
CXX = g++
CXX = g++-11  # Adjust the version number as necessary
CXXFLAGS += -Wall -std=c++20 -O2  # Common flags suitable for both GCC and Clang
LDFLAGS += -L/usr/local/lib  # Linker flags if needed

# Build target
all: $(EXE)

$(EXE): $(VFILES) $(CPP_SOURCE)
	$(VERILATOR) $(VERILATOR_FLAGS) --build -o $(EXE) testbench.sv $(CPP_SOURCE)
	./$(EXE)

clean:
	rm -rf obj_dir
	rm -f $(EXE)

.PHONY: all clean
