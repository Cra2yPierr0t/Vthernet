module sky130_sram_1kbyte_1rw1r_8x1024_8_tb;

    reg clk0 = 1'b0;
    reg csb0;
    reg web0;
    reg wmask0;
    reg [9:0] addr0;
    reg [7:0] din0;
    wire [7:0] dout0;

    reg clk1 = 1'b0;
    reg csb1;
    reg [9:0] addr1;
    wire [7:0] dout1;

    always #100 begin
        clk0 = ~clk0;
    end

    sky130_sram_1kbyte_1rw1r_8x1024_8 inst(
        .clk0   (clk0   ),
        .csb0   (csb0   ),
        .web0   (web0   ),
        .wmask0 (wmask0 ),
        .addr0  (addr0  ),
        .din0   (din0   ),
        .dout0  (dout0  ),
        .clk1   (clk1   ),
        .csb1   (csb1   ),
        .addr1  (addr1  ),
        .dout1  (dout1  )
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sky130_sram_1kbyte_1rw1r_8x1024_8_tb);
    end

    initial begin
        #9
        csb0 = 1'b0;
        web0 = 1'b0;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1010;
        din0 = 8'h55;
        #200
        csb0 = 1'b0;
        web0 = 1'b0;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1011;
        din0 = 8'h44;
        #200
        csb0 = 1'b0;
        web0 = 1'b0;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1100;
        din0 = 8'h33;
        #200
        csb0 = 1'b0;
        web0 = 1'b1;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_0000;
        din0 = 8'h00;
        #800
        csb0 = 1'b0;
        web0 = 1'b1;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1010;
        din0 = 8'h00;
        #200
        csb0 = 1'b0;
        web0 = 1'b1;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1011;
        din0 = 8'h00;
        #200
        csb0 = 1'b0;
        web0 = 1'b1;
        wmask0 = 1'b1;
        addr0 = 10'b00_0000_1100;
        din0 = 8'h00;
        #1000
        $finish;
    end
endmodule
