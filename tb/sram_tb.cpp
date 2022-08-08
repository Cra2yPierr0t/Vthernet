#include <iostream>
#include <vector>
#include <cstdint>
#include <string>
#include <fstream>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vbeh_sram_8x1024.h"

unsigned int main_time = 0;

int main(int argc, char **argv){

    Verilated::commandArgs(argc, argv);
    Vbeh_sram_8x1024 *top = new Vbeh_sram_8x1024();

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    top->clk0 = 0;

    for(int i = 0; i < 10; i++) {
        top->clk0 = 0;

        top->eval();
        tfp->dump(main_time++);

        top->clk0 = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    // write
    top->clk0 = 0;
    top->csb0 = 0;
    top->web0 = 0;
    top->wmask0 = 1;
    top->addr0 = 4;
    top->din0 = 0x55;

    top->eval();
    tfp->dump(main_time++);

    top->clk0 = 1;

    top->eval();
    tfp->dump(main_time++);

    top->csb0 = 1;
    top->addr0 = 0;
    for(int i = 0; i < 5; i++) {
        top->clk0 = 0;

        top->eval();
        tfp->dump(main_time++);

        top->clk0 = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    // read
    top->clk0 = 0;
    top->csb0 = 0;
    top->web0 = 1;
    top->addr0 = 4;

    top->eval();
    tfp->dump(main_time++);

    top->clk0 = 1;

    top->eval();
    tfp->dump(main_time++);

    top->addr0 = 0;
    for(int i = 0; i < 10; i++) {
        top->clk0 = 0;

        top->eval();
        tfp->dump(main_time++);

        top->clk0 = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    tfp->close();
    top->final();
}
