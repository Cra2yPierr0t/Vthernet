#include <iostream>
#include <vector>
#include <cstdint>
#include <string>
#include <fstream>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

unsigned int main_time = 0;

int main(int argc, char **argv){

    const char *filename = "./data/test_udp_packet.txt";
    std::string str_buf;
    std::ifstream ifs(filename);
    if(!ifs) {
        std::cout << "cannot open file" << std::endl;
        return 1;
    }

    std::vector<uint8_t> frame;

    while(ifs >> str_buf) {
        std::cout << str_buf << std::endl;
        frame.push_back(std::stoi(str_buf, nullptr, 16));
    }

    Verilated::commandArgs(argc, argv);
    Vtop *top = new Vtop();

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    const uint8_t PRE = 0b10101010;
    const uint8_t SFD = 0b10101011;

    top->rst = 0;
    top->RX_CLK = 0;

    for(int i = 0; i < 5; i++) {
        top->RX_CLK = 0;
        top->RXD    = PRE;
        top->RX_DV  = 1;

        top->eval();
        tfp->dump(main_time++);

        top->RX_CLK = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    top->RX_CLK = 0;
    top->RXD    = SFD;
    top->RX_DV  = 1;

    top->eval();
    tfp->dump(main_time++);

    top->RX_CLK = 1;

    top->eval();
    tfp->dump(main_time++);
    
    for(int i = 0; i < frame.size(); i++) {
        top->RX_CLK = 0;
        top->RXD    = frame[i];
        top->RX_DV  = 1;

        top->eval();
        tfp->dump(main_time++);

        top->RX_CLK = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    tfp->close();
    top->final();
}
