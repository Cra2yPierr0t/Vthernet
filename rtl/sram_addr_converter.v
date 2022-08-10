`default_nettype none
module sram_addr_converter(
    input   wire [31:0] addr_in,
    output  wire [3:0]  csb,
    output  wire [9:0]  addr_out
);
    
    assign csb = (addr_in[11:10] == 2'b11) ? 4'b0111 :
                 (addr_in[11:10] == 2'b10) ? 4'b1011 :
                 (addr_in[11:10] == 2'b01) ? 4'b1101 : 4'b1110;

    assign addr_out = addr_in[9:0];
    
endmodule
`default_nettype wire
