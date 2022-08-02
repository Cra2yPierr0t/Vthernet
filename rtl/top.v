`default_nettype none
module top(
    input   wire        rst,

    // GMII interface
    output  reg         GTX_CLK,
    output  reg         TX_EN,
    output  reg [7:0]   TXD,
    output  reg         TX_ER,

    input   wire        RX_CLK,
    input   wire        RX_DV,
    input   wire [7:0]  RXD,
    input   wire        RX_ER,

    output  reg         MDC,
    inout   reg         MDIO
    // PicoRV interface
    // どうしよっか
);
    parameter PRE = 8'b10101010;
    parameter SFD = 8'b10101011;

    parameter RX_IDLE       = 2'b00;
    parameter RX_WAIT_SFD   = 2'b01;
    parameter RX_READ_DATA  = 2'b11;
    parameter RX_IRQ        = 2'b10;

    reg [7:0] rx_state;

    always @(posedge RX_CLK) begin
        if(rst) begin
            rx_state    <= RX_IDLE;
        end else begin
            case(rx_state)
                RX_IDLE : begin
                    if(RX_DV) begin
                        rx_state    <= RX_WAIT_SFD;
                    end else begin
                        rx_state    <= RX_IDLE;
                    end
                end
                RX_WAIT_SFD : begin
                    if(RXD == SFD) begin
                        rx_state    <= RX_GET_DATA;
                    end else begin
                        rx_state    <= RX_WAIT_SFD;
                    end
                end
                RX_READ_DATA : begin
                    // READ FRAME HEADER
                    // IP
                        // UDP
                        // TCP?
                    // ARP
                end
                RX_IRQ : begin
                    // assert irq
                end
                default : begin
                    rx_state    <= RX_IDLE;
                end
            endcase
        end
    end

endmodule
`default_nettype wire
