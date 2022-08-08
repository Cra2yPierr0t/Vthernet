`default_nettype none
module beh_sram_8x1024 #(
    parameter DELAY = 3,
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 8
)(
    input   wire                    clk0,
    input   wire                    csb0,
    input   wire                    web0,
    input   wire                    wmask0,
    input   wire [ADDR_WIDTH-1:0]   addr0,
    input   wire [DATA_WIDTH-1:0]   din0,
    output  reg  [DATA_WIDTH-1:0]   dout0,
    input   wire                    clk1,
    input   wire                    csb1,
    input   wire [ADDR_WIDTH-1:0]   addr1,
    output  reg  [DATA_WIDTH-1:0]   dout1
);

    reg [DATA_WIDTH-1:0] mem [1023:0];

    reg csb0_r;
    reg web0_r;
    reg wmask0_r;
    reg [ADDR_WIDTH-1:0] addr0_r;
    reg [DATA_WIDTH-1:0] din0_r;

    reg csb1_r;
    reg [ADDR_WIDTH-1:0] addr1_r;

    always @(posedge clk0) begin
        csb0_r      <= csb0;
        web0_r      <= web0;
        wmask0_r    <= wmask0;
        addr0_r     <= addr0;
        din0_r      <= din0;
    end
    always @(posedge clk1) begin
        csb1_r      <= csb1;
        addr1_r     <= addr1;
    end

    // Write Block Port 0
    always @(negedge clk0) begin
        if( !csb0_r && !web0_r ) begin
            if(wmask0_r) begin
                mem[addr0_r] <= din0_r;
            end
        end
    end

    // Read Block Port 0
    reg [DATA_WIDTH-1:0] delay_buf0;
    /*
    always @(negedge clk0) begin
        if( !csb0_r ) begin
            dout0 <= mem[addr0_r];
        end
    end
    */
    // for delay statement
    always @(posedge clk0) begin
        if( !csb0_r && web0_r ) begin
            delay_buf0 <= mem[addr0_r];
        end
        dout0 <= delay_buf0;
    end

    // Read Block Port 1
    reg [DATA_WIDTH-1:0] delay_buf1;
    /*
    always @(negedge clk1) begin
        if( !csb1_r ) begin
            dout1 <= mem[addr1_r];
        end
    end
    */
    // for delay statement
    always @(posedge clk1) begin
        if( !csb1_r ) begin
            delay_buf1 <= mem[addr1_r];
        end
        dout1 <= delay_buf1;
    end
endmodule
`default_nettype wire
