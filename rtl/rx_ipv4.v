`default_nettype none
module rx_ipv4 #(
    parameter   OCT = 8,
    parameter   UDP = 8'h11
)(
    input   wire                rst,
    input   wire    [OCT*4-1:0] ip_addr,

    input   wire                RX_CLK,
    input   wire                rx_payload_ipv4,
    input   wire    [OCT-1:0]   rx_payload,
    output  reg                 rx_irq_ipv4,

    input   wire                rx_irq_udp,
    output  reg                 rx_data_udp,
    output  reg     [OCT-1:0]   rx_data
);

    reg [OCT-1:0]   rx_state;

    reg [3:0]       rx_version;
    reg [3:0]       rx_header_len;
    reg [OCT-1:0]   rx_tos;
    reg [OCT*2-1:0] rx_total_len;
    reg [OCT-1:0]   rx_id;
    reg [OCT*2-1:0] rx_flag_fragment;
    reg [OCT-1:0]   rx_ttl;
    reg [OCT-1:0]   rx_protocol;
    reg [OCT-1:0]   rx_checksum;
    reg [OCT*4-1:0] rx_src_ip;
    reg [OCT*4-1:0] rx_dst_ip;
    //reg [OCT*36-1:0] rx_option;
    
    reg [OCT-1:0]   data_cnt;

    always @(posedge RX_CLK) begin 
        if(rst) begin
            rx_state    <= RX_IHL_VER;
            data_cnt    <= 16'h0000;
        end else begin
            if(rx_data_ipv4) begin
                case(rx_state)
                    RX_IHL_VER  : begin
                        rx_state    <= RX_TOS;
                        {rx_head_len, rx_version} <= RXD;
                    end
                    RX_TOS      : begin
                        rx_state    <= RX_TOTAL_LEN;
                        rx_tos      <= RXD;
                    end
                    RX_TOTAL_LEN: begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= RX_ID;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= RX_TOTAL_LEN;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_total_len <= {rx_total_len[OCT-1:0], RXD};
                    end
                    RX_ID       : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= RX_FLAG_FRAG;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= RX_ID;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_id <= {rx_id[OCT-1:0], RXD};
                    end
                    RX_FLAG_FRAG: begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= RX_TTL;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= RX_FLAG_FRAG;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_flag_frag <= {rx_flag_frag[OCT-1:0], RXD};
                    end
                    RX_TTL      : begin
                        rx_state    <= RX_PROTOCOL;
                        rx_ttl      <= RXD;
                    end
                    RX_PROTOCOL : begin
                        rx_state    <= RX_CHECKSUM;
                        rx_protocol <= RXD;
                    end
                    RX_CHECKSUM : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= RX_SRC_IP;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= RX_CHECKSUM;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_checksum <= {rx_checksum[OCT-1:0], RXD};
                    end
                    RX_SRC_IP   : begin
                        if(data_cnt == 16'h0003) begin
                            rx_state    <= RX_DST_IP;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= RX_SRC_IP;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_src_ip <= {rx_src_ip[OCT*3-1:0], RXD};
                    end
                    RX_DST_IP   : begin
                        if(data_cnt == 16'h0003) begin
                            rx_state    <= RX_DATA;
                            // for total len cnt
                            data_cnt    <= {10'b00_0000_0000, rx_header_len, 2'b00};
                        end else begin
                            rx_state    <= RX_DST_IP;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_dst_ip <= {rx_dst_ip[OCT*3-1:0], RXD};
                    end
                    RX_DATA     : begin
                        rx_data <= RXD;
                        // count data lenght
                        if(data_cnt == rx_total_len) begin
                            rx_state    <= RX_IRQ;
                            data_cnt    <= 16'h0000;
                        end else begin
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        case(rx_protocol)
                            UDP : begin
                                rx_data_udp <= 1'b1;
                            end
                            default : begin
                                rx_data_udp <= 1'b0;
                            end
                        endcase
                    end
                    RX_IRQ      : begin
                        rx_state    <= RX_IHL_VER;
                        rx_irq_ipv4 <= 1'b1;
                    end
                    default : begin
                    end
                endcase
            end else begin
                rx_data_udp <= 1'b0;
            end
        end
    end
endmodule
`default_nettype wire
