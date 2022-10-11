module wb_interface #(
    parameter TEST_CSR0 = 32'h3000_0000,
    parameter TEST_CSR1 = 32'h3000_0004,
    parameter TEST_CSR2 = 32'h3000_0008
)(
    // wishbone signals
    input   wire        wb_clk_i,
    input   wire        wb_rst_i,
    input   wire        wbs_stb_i,
    input   wire        wbs_cyc_i,
    input   wire        wbs_we_i,
    input   wire [3:0]  wbs_sel_i,
    input   wire [31:0] wbs_dat_i,
    input   wire [31:0] wbs_adr_i,
    output  reg         wbs_ack_o,
    output  reg  [31:0] wbs_dat_o,
    // CSRs
    output  reg  [31:0] test_csr0,
    output  reg  [31:0] test_csr1,
    output  reg  [31:0] test_csr2
);

    localparam WB_IDLE  = 2'b00;
    localparam WB_READ  = 2'b01;
    localparam WB_WRITE = 2'b10;

    reg [1:0] wb_state;

    always @(posedge wb_clk_i) begin
        if(wb_rst_i) begin
            wb_state    <= WB_IDLE;
            wbs_ack_o   <= 1'b0;
        end else begin
            case(wb_state)
                WB_IDLE : begin
                    wbs_ack_o   <= 1'b0;
                    if(wbs_stb_i && wbs_cyc_i) begin
                        if(wbs_we_i) begin
                            wb_state <= WB_WRITE;
                        end else begin
                            wb_state <= WB_READ;
                        end
                    end
                end
                WB_READ : begin
                    wb_state    <= WB_IDLE;
                    wbs_ack_o   <= 1'b1;
                    case(wbs_adr_i)
                        TEST_CSR0 : begin
                            wbs_dat_o[7:0]   <= wbs_sel_i[0] ? test_csr0[7:0] : 8'h00;
                            wbs_dat_o[15:8]  <= wbs_sel_i[1] ? test_csr0[15:0] : 8'h00;
                            wbs_dat_o[23:16] <= wbs_sel_i[2] ? test_csr0[23:16] : 8'h00;
                            wbs_dat_o[31:24] <= wbs_sel_i[3] ? test_csr0[31:24] : 8'h00;
                        end
                        TEST_CSR1 : begin
                            wbs_dat_o[7:0]   <= wbs_sel_i[0] ? test_csr1[7:0] : 8'h00;
                            wbs_dat_o[15:8]  <= wbs_sel_i[1] ? test_csr1[15:0] : 8'h00;
                            wbs_dat_o[23:16] <= wbs_sel_i[2] ? test_csr1[23:16] : 8'h00;
                            wbs_dat_o[31:24] <= wbs_sel_i[3] ? test_csr1[31:24] : 8'h00;
                        end
                        TEST_CSR2 : begin
                            wbs_dat_o[7:0]   <= wbs_sel_i[0] ? test_csr2[7:0] : 8'h00;
                            wbs_dat_o[15:8]  <= wbs_sel_i[1] ? test_csr2[15:0] : 8'h00;
                            wbs_dat_o[23:16] <= wbs_sel_i[2] ? test_csr2[23:16] : 8'h00;
                            wbs_dat_o[31:24] <= wbs_sel_i[3] ? test_csr2[31:24] : 8'h00;
                        end
                        default   : begin
                            wbs_dat_o <= 32'h0000_0000;
                        end
                    endcase
                end
                WB_WRITE : begin
                    wb_state    <= WB_IDLE;
                    wbs_ack_o   <= 1'b1;
                    case(wbs_adr_i)
                        TEST_CSR0 : begin
                            test_csr0[7:0]   <= wbs_sel_i[0] ? wbs_dat_i[7:0] : 8'h00;
                            test_csr0[15:8]  <= wbs_sel_i[1] ? wbs_dat_i[15:8] : 8'h00;
                            test_csr0[23:16] <= wbs_sel_i[2] ? wbs_dat_i[23:16] : 8'h00;
                            test_csr0[31:24] <= wbs_sel_i[3] ? wbs_dat_i[31:24] : 8'h00;
                        end
                        TEST_CSR1 : begin
                            test_csr1[7:0]   <= wbs_sel_i[0] ? wbs_dat_i[7:0] : 8'h00;
                            test_csr1[15:8]  <= wbs_sel_i[1] ? wbs_dat_i[15:8] : 8'h00;
                            test_csr1[23:16] <= wbs_sel_i[2] ? wbs_dat_i[23:16] : 8'h00;
                            test_csr1[31:24] <= wbs_sel_i[3] ? wbs_dat_i[31:24] : 8'h00;
                        end
                        TEST_CSR2 : begin
                            test_csr2[7:0]   <= wbs_sel_i[0] ? wbs_dat_i[7:0] : 8'h00;
                            test_csr2[15:8]  <= wbs_sel_i[1] ? wbs_dat_i[15:8] : 8'h00;
                            test_csr2[23:16] <= wbs_sel_i[2] ? wbs_dat_i[23:16] : 8'h00;
                            test_csr2[31:24] <= wbs_sel_i[3] ? wbs_dat_i[31:24] : 8'h00;
                        end
                    endcase
                end
            endcase
        end
    end

endmodule
