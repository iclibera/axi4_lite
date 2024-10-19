#include "Vtestbench.h" 
#include "verilated.h"            

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);

    Vtestbench *tb = new Vtestbench;

    // Initialize simulation main loop
    while (!Verilated::gotFinish())
    {
        // Execute simulation steps
        tb->eval();
    }

    // Clean up and exit simulation
    tb->final();
    delete tb;

    return 0;
}