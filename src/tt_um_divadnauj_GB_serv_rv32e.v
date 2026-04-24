/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_divadnauj_GB_serv_rv32e (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire wb_clk;
	reg wb_rst;

	wire w_sio0_si_mosi_i;
	wire w_sio1_so_miso_i;
	wire w_sio2_i;
	wire w_sio3_i;

	wire w_sio0_si_mosi_o;
	wire w_sio1_so_miso_o;
	wire w_sio2_o;
	wire w_sio3_o;
	wire [3:0] w_sio_oe;
	wire [2:0] w_ce;

	wire [7:0] gpio0_o;
	wire [7:0] gpio0_i;

	wire uart0_tx;
	wire uart0_rx;

	wire sclk;

    assign wb_clk = clk;

    assign wb_rst = ~rst_n;


	assign uo_out[7:0] = gpio0_o[7:0];
	assign gpio0_i[7:0] = ui_in[7:0];


	assign uio_out[0] = w_ce[0];
	assign uio_out[1] = w_sio0_si_mosi_o;
	assign uio_out[2] = w_sio1_so_miso_o;
	assign uio_out[3] = sclk;
	//assign uio_out[4] = w_sio2_o;
	//assign uio_out[5] = w_sio3_o;
	assign uio_out[6] = w_ce[1];
	assign uio_out[7] = w_ce[2];

    assign uio_oe[0] = 1'b1; // w_ce[0] is always output
	assign uio_oe[1] = w_sio_oe[0];
	assign uio_oe[2] = w_sio_oe[1];
	assign uio_oe[3] = 1'b1; // sclk is always output
	//assign uio_oe[4] = w_sio_oe[1];
	//assign uio_oe[5] = w_sio_oe[3];
	assign uio_oe[6] = 1'b1; // w_ce[1] is always output
	assign uio_oe[7] = 1'b1; // w_ce[2] is always output


    assign w_sio0_si_mosi_i = uio_in[1];
	assign w_sio1_so_miso_i = uio_in[2];
	//assign w_sio2_i			= uio_in[4];
	//assign w_sio3_i			= uio_in[5];

    
    assign uio_oe[4] = 1'b1; // uart0_tx is always output 
	assign uio_oe[5] = 1'b0; // uart0_rx is always input


	assign uio_out[4] = uart0_tx;
	assign uio_out[5] = 1'b0;
	assign uart0_rx = uio_in[5];

	assign w_sio2_i			= 1'b0;
	assign w_sio3_i			= 1'b0;


	serv_wb_soc_rv32e #(
		.PROGADDR_RESET (32'h 0000_0000),
		.PROGADDR_IRQ(32'h 0000_0010),
		.BOOTROM_MEMFILE ("./src/riscv-nmon_0/nmon_nanorv32-wb-soc_24MHz_115200.txt"),
		.BOOTROM_MEMDEPTH (1024)
	)
	soc(
		.clock (wb_clk),
		.reset (wb_rst),

		.uart_rx (uart0_rx),
		.uart_tx (uart0_tx),

		.sclk(sclk),
		.sio0_si_mosi_i(w_sio0_si_mosi_i),
		.sio1_so_miso_i(w_sio1_so_miso_i),
		.sio2_i        (w_sio2_i),
		.sio3_i        (w_sio3_i),

		.sio0_si_mosi_o(w_sio0_si_mosi_o),
		.sio1_so_miso_o(w_sio1_so_miso_o),
		.sio2_o        (w_sio2_o),
		.sio3_o        (w_sio3_o),
		.sio_oe        (w_sio_oe),
		.ce(w_ce),

		.gpio0_i (gpio0_i),
		.gpio0_o (gpio0_o),
		.gpio0_dir_o ()
	);





endmodule
