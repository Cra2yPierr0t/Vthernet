`default_nettype none
module rx_ethernet #(
    parameter OCT   = 8,
    parameter PRE   = 8'b10101010,
    parameter SFD   = 8'b10101011,
    parameter IPV4  = 16'h0800
)(
    input   wire        rst,

    input   wire [OCT*6-1:0] mac_addr,

    // GMII Receive Interface
    input   wire            RX_CLK,
    input   wire            RX_DV,
    input   wire [OCT-1:0]  RXD,
    input   wire            RX_ER,

    // Interface for Next Layer Logic
    output  reg             rx_payload_ip,
    output  reg [OCT-1:0]   rx_payload
);

    parameter RX_IDLE       = 3'b000;
    parameter RX_WAIT_SFD   = 3'b001;
    parameter RX_MAC_DST    = 3'b011;
    parameter RX_MAC_SRC    = 3'b111;
    parameter RX_LEN_TYPE   = 3'b110;
    parameter RX_READ_DATA  = 3'b100;
    parameter RX_IRQ        = 3'b110;

    reg [OCT*2-1:0]     data_cnt;
    reg [OCT-1:0]       rx_state;
    reg [OCT*6-1:0]     rx_mac_dst;
    reg [OCT*6-1:0]     rx_mac_src;
    reg [OCT*2-1:0]     rx_len_type;

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
                RX_MAC_DST  : begin
                    if(data_cnt == 8'h05) begin
                        data_cnt    <= 16'h0000;
                        if({rx_mac_dst[OCT*5-1:0], RXD} == mac_addr) begin
                            rx_state    <= RX_MAC_SRC;
                        end else begin
                            rx_state    <= RX_IDLE; // dame
                        end
                    end else begin
                        rx_state    <= RX_MAC_DST;
                        data_cnt    <= data_cnt + 16'h0001;
                        rx_mac_dst  <= {rx_mac_dst[OCT*5-1:0], RXD};
                    end
                end
                RX_MAC_SRC  : begin
                    if(data_cnt == 8'h05) begin
                        rx_state    <= RX_LEN_TYPE;
                        data_cnt    <= 16'h0000;
                    end else begin
                        rx_state    <= RX_MAC_SRC;
                        data_cnt    <= data_cnt + 16'h0001;
                    end
                    rx_mac_dst  <= {rx_mac_dst[OCT*5-1:0], RXD};
                end
                RX_LEN_TYPE : begin
                    if(data_cnt == 8'h01) begin
                        rx_state    <= RX_READ_DATA;
                        data_cnt    <= 16'h0000;
                    end else begin
                        rx_state    <= RX_LEN_TYPE;
                        data_cnt    <= data_cnt + 16'h0001;
                    end
                    rx_len_type <= {rx_len_type[OCT-1:0], RXD};
                end
                RX_READ_DATA : begin
                    // READ FRAME HEADER
                    case(rx_len_type)
                        IPV4    : begin
                            rx_payload_ip   <= 1'b1;
                            rx_payload      <= RXD;
                        end
                        default : begin
                            if(rx_len_type <= 16'h05DC) begin   // RAW FRAME
                                rx_payload_ip   <= 1'b0;
                            end else begin                      // UNKNOWN TYPE
                                rx_payload_ip   <= 1'b0;
                            end
                        end
                    endcase
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
