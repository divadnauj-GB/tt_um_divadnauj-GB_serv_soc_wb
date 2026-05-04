`default_nettype none

module wb_qqspi#(
    parameter CHIP_SELECTS = 3
)(
   input   wire 	        wb_clk_i,
   input   wire 	        wb_rst_i,
   input   wire [31:0]    wb_adr_i,
   input   wire [31:0]    wb_dat_i,
   input   wire [3:0] 	  wb_sel_i,
   input   wire 	        wb_we_i,
   input   wire [1:0] 	  wb_bte_i,
   input   wire [2:0] 	  wb_cti_i,
   input   wire 	        wb_cyc_i,
   input   wire 	        wb_stb_i,
   output  wire           wb_ack_o,
   output  wire           wb_err_o,
	 output	 wire          	wb_rty_o,
   output  wire   [31:0]   wb_dat_o,

   output wire             sclk,
   input  wire            sio0_si_mosi_i,
   input  wire            sio1_so_miso_i,
   input  wire            sio2_i,
   input  wire            sio3_i,
   output wire            sio0_si_mosi_o,
   output wire            sio1_so_miso_o,
   output wire            sio2_o,
   output wire            sio3_o,
   output wire  [3:0]     sio_oe,
   output wire  [CHIP_SELECTS -1:0] ce
   );


   wire        qqspi_mem_ready;
   wire        spi_nor_mem_valid;
   wire        mem_sdram_valid,mem_sdram_valid1,mem_sdram_valid2;
   wire [3:0]  wb_wstrb_ctrl;

   assign mem_sdram_valid1 = (wb_adr_i[24]&&!wb_adr_i[23]&&!qqspi_mem_ready && wb_stb_i && wb_cyc_i);
   assign mem_sdram_valid2 = (wb_adr_i[24]&&wb_adr_i[23]&&!qqspi_mem_ready && wb_stb_i && wb_cyc_i);
   assign mem_sdram_valid = mem_sdram_valid1 | mem_sdram_valid2;

   assign spi_nor_mem_valid = (!wb_adr_i[24]&&!qqspi_mem_ready && wb_stb_i && wb_cyc_i ) ;
    
   assign wb_ack_o = qqspi_mem_ready & wb_stb_i & wb_cyc_i;

   assign wb_wstrb_ctrl = wb_sel_i & {4{wb_we_i}};

   assign wb_err_o = 0;
   assign wb_rty_o = 0;

   /*
   reg [7:0] ack_delay;
   assign wb_ack_o = ack_delay[2];
   always @(posedge wb_clk_i) begin
      if (wb_rst_i) begin
         ack_delay <= 0;
      end else begin
         if (qqspi_mem_ready && wb_stb_i && wb_cyc_i) begin
            ack_delay <= {ack_delay[6:0], 1'b1};
          end else begin
            ack_delay <= 0;
         end
      end
    end
   */


    qqspi #(
      .CHIP_SELECTS(CHIP_SELECTS)
    ) qqspi_I (
      .addr({wb_adr_i[24:2]}),
      .wdata(wb_dat_i),
      .rdata(wb_dat_o),
      .wstrb(wb_wstrb_ctrl),
      .ready(qqspi_mem_ready),
      .valid(wb_stb_i & wb_cyc_i),
      .QUAD_MODE(1'b0),
      .PSRAM_SPIFLASH(mem_sdram_valid),

      .sclk(sclk),

      .sio0_si_mosi_i(sio0_si_mosi_i),
      .sio1_so_miso_i(sio1_so_miso_i),
      .sio2_i        (sio2_i),
      .sio3_i        (sio3_i),

      .sio0_si_mosi_o(sio0_si_mosi_o),
      .sio1_so_miso_o(sio1_so_miso_o),
      .sio2_o        (sio2_o),
      .sio3_o        (sio3_o),
      .sio_oe        (sio_oe),

      .ce_ctrl({mem_sdram_valid2, mem_sdram_valid1, spi_nor_mem_valid}),
      .ce(ce),

      .clk   (wb_clk_i),
      .reset(wb_rst_i)
  );






endmodule