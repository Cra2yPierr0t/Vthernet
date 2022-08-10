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

    ifs >> str_buf;
    for(int i = 0; i < str_buf.size(); i += 2) {
        frame.push_back(std::stoi(str_buf.substr(i, 2), nullptr, 16));
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

    // CSR init
    top->wb_clk_i   = 0;
    top->wbs_stb_i  = 1;
    top->wbs_cyc_i  = 1;
    top->wbs_we_i   = 0;

    {
        // set offload func
        top->wb_clk_i   = 0;
        top->wbs_we_i   = 1;
        top->wbs_adr_i  = 0x30000024;
        top->wbs_dat_i  = 0x00000003;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);

        // set MAC
        top->wb_clk_i   = 0;
        top->wbs_we_i   = 1;
        top->wbs_adr_i  = 0x30000000;
        top->wbs_dat_i  = 0x5e0000fb;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);

        // set MAC
        top->wb_clk_i   = 0;
        top->wbs_we_i   = 1;
        top->wbs_adr_i  = 0x30000004;
        top->wbs_dat_i  = 0x00000100;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);

        // set IP
        top->wb_clk_i   = 0;
        top->wbs_we_i   = 1;
        top->wbs_adr_i  = 0x30000008;
        top->wbs_dat_i  = 0xe00000fb;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);
    }
    for(int i = 0; i < 10; i++) {
        top->wb_clk_i   = 0;
        top->wbs_stb_i  = 0;
        top->wbs_cyc_i  = 0;
        top->wbs_we_i   = 0;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    for(int i = 0; i < 10; i++) {
        top->RX_CLK = 0;
        top->RXD    = 0;
        top->RX_DV  = 0;

        top->eval();
        tfp->dump(main_time++);

        top->RX_CLK = 1;

        top->eval();
        tfp->dump(main_time++);
    }

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

    for(int i = 0; i < 10; i++) {
        top->RX_CLK = 0;
        top->RXD    = 0;
        top->RX_DV  = 0;

        top->eval();
        tfp->dump(main_time++);

        top->RX_CLK = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    top->wb_clk_i   = 0;
    top->wbs_stb_i  = 1;
    top->wbs_cyc_i  = 1;
    top->wbs_we_i   = 0;

    for(uint32_t i = 0; i < 30; i++) {
        top->wb_clk_i   = 0;
        top->wbs_adr_i  = 0x40000000 + i;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;
        top->wbs_adr_i  = 0x40000000 + i;

        top->eval();
        tfp->dump(main_time++);
    }

    for(int i = 0; i < 10; i++) {
        top->wb_clk_i   = 0;
        top->wbs_stb_i  = 0;
        top->wbs_cyc_i  = 0;
        top->wbs_we_i   = 0;

        top->eval();
        tfp->dump(main_time++);

        top->wb_clk_i   = 1;

        top->eval();
        tfp->dump(main_time++);
    }

    tfp->close();
    top->final();
}
