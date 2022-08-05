//
//  ethernet --- IP ---- UDP
//            |       |
//            -- ARP  -- TCP
//

`default_nettype none
module top(
    input   wire        rst,
    // Wishbone interface
    input   wire        wb_clk_i,
    input   wire        wb_rst_i,
    input   wire        wbs_stb_i,
    input   wire        wbs_cyc_i,
    input   wire        wbs_we_i,
    input   wire  [3:0] wbs_sel_i,
    input   wire [31:0] wbs_dat_i,
    input   wire [31:0] wbs_adr_i,
    output  reg         wbs_ack_o,
    output  reg  [31:0] wbs_dat_o,

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
    inout   reg         MDIO,

    // PicoRV interface
    output  wire        rx_irq,
    output  wire        rx_udp_data_v,
    output  wire [7:0]  rx_udp_data
);
    parameter OCT   = 8;
    parameter PRE   = 8'b10101010;
    parameter SFD   = 8'b10101011;
    parameter IPV4  = 16'h0800;

    // Vthernet CSR
    reg [OCT*6-1:0] mac_addr = 48'h01005e0000fb;
    reg [OCT*4-1:0] ip_addr  = 32'he00000fb;
    reg [OCT*2-1:0] port;

    wire [OCT*6-1:0] rx_mac_src;
    wire [OCT*4-1:0] rx_src_ip;
    wire [OCT*2-1:0] rx_src_port;

    // Wishbone logic
    parameter MY_MAC_ADDR_LOW   = 32'h3000_0000;
    parameter MY_MAC_ADDR_HIGH  = 32'h3000_0004;
    parameter MY_IP_ADDR        = 32'h3000_0008;
    parameter MY_PORT           = 32'h3000_000c;
    
    // wishbone signal
    parameter WB_IDLE   = 2'b00;
    parameter WB_WRITE  = 2'b01;
    parameter WB_READ   = 2'b11;

    reg [1:0]   wb_state;
    reg [31:0]  wb_addr;
    reg [31:0]  wb_w_data;

    always @(posedge wb_clk_i) begin
        if(wb_rst_i) begin
            wb_state    <= WB_IDLE;
            wbs_ack_o   <= 1'b0;
        end else begin
            case(wb_state)
                WB_IDLE : begin
                    if(wbs_stb_i && wbs_cyc_i) begin
                        if(wbs_we_i) begin
                            wb_state    <= WB_WRITE;
                            wb_w_data   <= wbs_dat_i;
                        end else begin
                            wb_state <= WB_READ;
                        end
                        wb_addr <= wb_adr_i;
                    end
                    wbs_ack_o   <= 1'b0;
                end
                WB_WRITE: begin
                    case(wb_addr)
                        MY_MAC_ADDR_LOW : begin
                            mac_addr[OCT*4-1:0] <= wb_w_data;
                        end
                        MY_MAC_ADDR_HIGH: begin
                            mac_addr[OCT*6-1:OCT*4] <= wb_w_data;
                        end
                        MY_IP_ADDR  : begin
                            ip_addr     <= wb_w_data;
                        end
                        MY_PORT     : begin
                            port        <= wb_w_data;
                        end
                        default     : begin
                        end
                    endcase
                    wbs_ack_o   <= 1'b1;
                    if(wbs_stb_i && wbs_cyc_i) begin
                        if(wbs_we_i) begin
                            wb_state    <= WB_WRITE;
                            wb_w_data   <= wbs_dat_i;
                        end else begin
                            wb_state <= WB_READ;
                        end
                        wb_addr <= wb_adr_i;
                    end else begin
                        wb_state <= WB_IDLE;
                    end
                end
                WB_READ : begin
                    case(wb_addr)
                        MY_MAC_ADDR_LOW : begin
                            wbs_dat_o   <= mac_addr[OCT*4-1:0];
                        end
                        MY_MAC_ADDR_HIGH: begin
                            wbs_dat_o   <= {16'h0000, mac_addr[OCT*6-1:OCT*4]};
                        end
                        MY_IP_ADDR  : begin
                            wbs_dat_o   <= ip_addr;
                        end
                        MY_PORT     : begin
                            wbs_dat_o   <= ip_addr;
                        end
                        default     : begin
                        end
                    endcase
                    wbs_ack_o   <= 1'b1;
                    if(wbs_stb_i && wbs_cyc_i) begin
                        if(wbs_we_i) begin
                            wb_state    <= WB_WRITE;
                            wb_w_data   <= wbs_dat_i;
                        end else begin
                            wb_state <= WB_READ;
                        end
                        wb_addr <= wb_adr_i;
                    end else begin
                        wb_state <= WB_IDLE;
                    end
                end
            endcase
        end
    end

    // SMI logic
    // transmit logic
    // receive logic
    wire                rx_payload_ipv4;
    wire    [OCT-1:0]   rx_payload;
    wire                rx_data_udp;
    wire    [OCT-1:0]   rx_data;

    // receive irq signal
    wire                rx_ethernet_irq;
    wire                rx_ipv4_irq;
    wire                rx_udp_irq;
    assign rx_irq = rx_udp_irq;

    rx_ethernet #(
        .OCT    (OCT    ),
        .PRE    (PRE    ),
        .SFD    (SFD    ),
        .IPV4   (IPV4   )
    ) rx_ethernet_inst(
        .rst            (rst        ),
        .mac_addr       (mac_addr   ),
        .rx_ethernet_irq(rx_ethernet_irq   ),
        .rx_mac_src     (rx_mac_src ),
        .RX_CLK         (RX_CLK     ),
        .RX_DV          (RX_DV      ),
        .RXD            (RXD        ),
        .RX_ER          (RX_ER      ),
        .rx_payload_ipv4(rx_payload_ipv4    ),
        .rx_payload     (rx_payload         )
    );

    // IPv4
    rx_ipv4     rx_ipv4_inst(
        .rst            (rst            ),
        .ip_addr        (ip_addr        ),
        .rx_src_ip      (rx_src_ip      ),
        .rx_ethernet_irq(rx_ethernet_irq),
        .rx_ipv4_irq    (rx_ipv4_irq    ),
        .RX_CLK         (RX_CLK         ),
        .rx_payload_ipv4(rx_payload_ipv4),
        .rx_payload     (rx_payload     ),
        .rx_data_udp    (rx_data_udp    ),
        .rx_data        (rx_data        )
    );

    // UDP
    rx_udp      rx_udp_inst(
        .rst            (rst            ),
        .port           (port           ),
        .rx_src_port    (rx_src_port    ),
        .rx_ipv4_irq    (rx_ipv4_irq    ),
        .rx_udp_irq     (rx_udp_irq     ),
        .RX_CLK         (RX_CLK         ),
        .rx_data_v      (rx_data_udp    ),
        .rx_data        (rx_data        ),
        .rx_udp_data_v  (rx_udp_data_v  ),
        .rx_udp_data    (rx_udp_data    )
    );

endmodule
`default_nettype wire
