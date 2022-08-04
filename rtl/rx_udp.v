`default_nettype none
module rx_udp #(
    parameter   OCT = 8
)(
    input   wire                rst,
    input   wire    [OCT*2-1]   port,
    output  reg     [OCT*2-1:0] rx_src_port,

    input   wire                RX_CLK,
    input   wire                rx_data_v,
    input   wire    [OCT-1:0]   rx_data,

    output  reg                 rx_udp_data_v,
    output  reg     [OCT-1:0]   rx_udp_data
);

    reg [OCT*2-1:0] data_cnt;

    reg [OCT-1:0]   rx_state;

    reg [OCT*2-1:0] rx_dst_port;
    reg [OCT*2-1:0] rx_data_len;
    reg [OCT*2-1:0] rx_checksum;

    always @(posedge clk) begin
        if(rst) begin
            data_cnt    <= 16'h0000;
            rx_udp_data_v   <= 1'b0;
        end else begin
            if(rx_data_v) begin
                case(rx_state)
                    SRC_PORT : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= DST_PORT;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= SRC_PORT;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_src_port <= {rx_src_port[OCT-1:0], RXD};
                    end
                    DST_PORT : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= DATA_LEN;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= DST_PORT;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_dst_port <= {rx_dst_port[OCT-1:0], RXD};
                    end
                    DATA_LEN : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= CHECKSUM;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_state    <= DATA_LEN;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_data_len <= {rx_data_len[OCT-1:0], RXD};
                    end
                    CHECKSUM : begin
                        if(data_cnt == 16'h0001) begin
                            rx_state    <= UDP_DATA;
                            data_cnt    <= 16'h0008;
                        end else begin
                            rx_state    <= CHECKSUM;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_checksum <= {rx_checksum[OCT-1:0], RXD};
                    end
                    UDP_DATA : begin
                        if(data_cnt == rx_data_len) begin
                            rx_udp_data_v   <= 1'b0;
                            data_cnt    <= 16'h0000;
                        end else begin
                            rx_udp_data_v   <= 1'b1;
                            data_cnt    <= data_cnt + 16'h0001;
                        end
                        rx_udp_data     <= rx_data;
                    end
                endcase
            end else begin
                rx_state        <= SRC_PORT;
                rx_udp_data_v   <= 1'b0;
                data_cnt        <= 16'h0000;
            end
        end
    end
endmodule
`default_nettype wire
