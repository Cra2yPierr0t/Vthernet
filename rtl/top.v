//
//  ethernet --- IP ---- UDP
//            |       |
//            -- ARP  -- TCP
//

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
    parameter OCT   = 8;
    parameter PRE   = 8'b10101010;
    parameter SFD   = 8'b10101011;
    parameter IPV4  = 16'h0800;

    // Vthernet CSR
    reg [OCT*6-1:0] mac_addr;

    // SMI logic
    // transmit logic
    // receive logic
    rx_ethernet #(
        .OCT    (OCT    ),
        .PRE    (PRE    ),
        .SFD    (SFD    ),
        .IPV4   (IPV4   )
    ) rx_ethernet_inst(
        .rst            (rst        ),
        .mac_addr       (mac_addr   ),
        .RX_CLK         (RX_CLK     ),
        .RX_DV          (RX_DV      ),
        .RXD            (RXD        ),
        .RX_ER          (RX_ER      ),

        .rx_payload_ip  (),
        .rx_payload     ()
    );

    // IP
    rx_ip       rx_ip_inst(
        .RX_CLK         (),
        .rx_payload_ip  (),
        .rx_payload     (),

        .rx_data_udp    (),
        .rx_data_tcp    (),
        .rx_data        ()
    );

    // UDP
    rx_udp      rx_udp_inst(
        .RX_CLK         (),
        .rx_data_udp    (),
        .rx_data        (),

        .rx_udp_irq     (),
        .rx_udp_data    ()
    );

    // ARP
    /*
    rx_arp      rx_arp_inst(
        .RX_CLK         (),
        .rx_payload_arp (),
        .rx_payload     (),
    );
    */

    // TCP?
    /*
    rx_udp      rx_udp_inst(
        .RX_CLK         (),
        .rx_data_tcp    (),
        .rx_data        (),

        .rx_tcp_irq     (),
        .rx_tcp_data    ()
    );
    */

endmodule
`default_nettype wire
