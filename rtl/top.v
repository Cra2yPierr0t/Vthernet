`default_nettype none
module top (
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
    output  wire        wbs_ack_o,
    output  wire [31:0] wbs_dat_o,

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
    output  wire        rx_irq
);

    wire        rx_data_v;
    wire [7:0]  rx_data;
    wire [7:0]  rx_mem_out;
    wire [10:0] rx_addr;

    RX_Vthernet_MAC RX_Vthernet_MAC(
        .rst        (wb_rst_i   ),
        // Wishbone interface
        .wb_clk_i   (wb_clk_i   ),
        .wb_rst_i   (wb_rst_i   ),
        .wbs_stb_i  (wbs_stb_i  ),
        .wbs_cyc_i  (wbs_cyc_i  ),
        .wbs_we_i   (wbs_we_i   ),
        .wbs_sel_i  (wbs_sel_i  ),
        .wbs_dat_i  (wbs_dat_i  ),
        .wbs_adr_i  (wbs_adr_i  ),
        .wbs_ack_o  (wbs_ack_o  ),
        .wbs_dat_o  (wbs_dat_o  ),
        // GMII interface
        .GTX_CLK    (GTX_CLK    ),
        .TX_EN      (TX_EN      ),
        .TXD        (TXD        ),
        .TX_ER      (TX_ER      ),
        .RX_CLK     (RX_CLK     ),
        .RX_DV      (RX_DV      ),
        .RXD        (RXD        ),
        .RX_ER      (RX_ER      ),
        .MDC        (MDC        ),
        .MDIO       (MDIO       ),
        // PicoRV interface
        .rx_irq     (rx_irq     ),
        // Memory Interface
        .rx_data_v  (rx_data_v  ),
        .rx_data    (rx_data    ),
        .rx_mem_out (rx_mem_out ),
        .rx_addr    (rx_addr    )
    );

    beh_sram_8x1024 sram_inst0(
        // RW
        .clk0   (RX_CLK         ), // clock
        .csb0   (~rx_data_v     ), // active low chip select
        .web0   (~rx_data_v     ), // active low write control
        .wmask0 (1'b1           ), // write mask (1 bit)
        .addr0  (rx_addr        ), // addr (10 bit)
        .din0   (rx_data        ), // data in (8 bit)
        .dout0  (), // data out (8 bit)
        // R
        .clk1   (wb_clk_i       ), // clock
        .csb1   (1'b0           ), // active low chip select
        .addr1  (wbs_adr_i[9:0] ), // addr (10 bit)
        .dout1  (rx_mem_out     )  // data out (8 bit)
    );

endmodule
`default_nettype wire
