module delay_test_tb;

    reg clk = 1'b0;

    always #1 begin
        clk = ~clk;
    end

    reg           en = 1'b0;
    reg     [3:0] in = 4'h0;
    wire    [3:0] out;
    wire    [3:0] out2;
    delay_test inst(
        .clk    (clk),
        .en     (en ),
        .in     (in ),
        .out    (out),
        .out2   (out2)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, delay_test_tb);
    end

    initial begin
        #9
        en = 1'b1;
        in = 4'b1010;
        #2
        en = 1'b0;
        in = 4'b0101;
        #2
        en = 1'b1;
        in = 4'b0011;
        #10
        $finish;
    end
endmodule
