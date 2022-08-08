module delay_test(
    input   wire        clk,
    input   wire        en,
    input   wire [3:0]  in,
    output  reg  [3:0]  out,
    output  reg  [3:0]  out2
);
    reg       en_r;
    reg [3:0] in_r;

    always @(posedge clk) begin
        en_r <= en;
        in_r <= in;
    end

    reg [3:0] delay_buf;
    always @(negedge clk) begin
        if(en_r) begin
            out <= #(3) in_r;
        end
    end
    always @(posedge clk) begin
        if(en_r) begin
            delay_buf <= in_r;
        end
        out2 <= delay_buf;
    end
endmodule
