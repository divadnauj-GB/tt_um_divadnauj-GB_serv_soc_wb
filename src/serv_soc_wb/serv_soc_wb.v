`default_nettype none

module serv_soc_wb #(
	parameter width = 1,
    parameter EMBEDDED = 0,
    parameter PRE_REGISTER = 1,
    parameter reset_pc = 32'h00000000,
    parameter reset_strategy = "MINI",
    parameter sim = 0,
    parameter debug = 0,
    parameter with_c = 0,
    parameter with_csr = 1,
    parameter with_mdu = 0
	)
	(
	input  wire clock,
	input  wire reset,

	input  wire uart_rx,
	output wire uart_tx,

    output wire sclk,

    input wire sio0_si_mosi_i,
    input wire sio1_so_miso_i,
    input wire sio2_i,
    input wire sio3_i,

    output wire sio0_si_mosi_o,
    output wire sio1_so_miso_o,
    output wire sio2_o,
    output wire sio3_o,
	output wire [3:0] sio_oe,
	output wire [2:0] ce,

	input  wire [7:0] gpio0_i,
	output wire [7:0] gpio0_o,
	output wire [7:0] gpio0_dir_o
	);

	wire wb_clk;
	assign wb_clk = clock;
	wire wb_rst;
	assign wb_rst = reset;


`include "wb_common_params.v"
`include "wb_intercon.vh"

	wb_qqspi #(
		.CHIP_SELECTS(3)
	) wb_qqspi (
		.wb_clk_i(wb_clk),
		.wb_rst_i(wb_rst),
		.wb_adr_i(wb_qqspi0_adr),
		.wb_dat_i(wb_qqspi0_dat),
		.wb_sel_i(wb_qqspi0_sel),
		.wb_we_i(wb_qqspi0_we),
		.wb_bte_i(wb_qqspi0_bte),
		.wb_cti_i(wb_qqspi0_cti),
		.wb_cyc_i(wb_qqspi0_cyc),
		.wb_stb_i(wb_qqspi0_stb),
		.wb_ack_o(wb_qqspi0_ack),
		.wb_err_o(wb_qqspi0_err),
		.wb_rty_o(wb_qqspi0_rty),
		.wb_dat_o(wb_qqspi0_rdt),

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
		.ce(ce)
   );

	uart_top #(
		.SIM (sim)
	)
	uart16550(
		.wb_clk_i(wb_clk),
		.wb_rst_i(wb_rst),

		.wb_adr_i(wb_uart0_adr[2:0]),
		.wb_dat_i(wb_uart0_dat),
		.wb_sel_i(wb_uart0_sel),
		.wb_we_i(wb_uart0_we),
		.wb_cyc_i(wb_uart0_cyc),
		.wb_stb_i(wb_uart0_stb),
		.wb_dat_o(wb_uart0_rdt),
		.wb_ack_o(wb_uart0_ack),

		.stx_pad_o(uart_tx),
		.srx_pad_i(uart_rx),
		.rts_pad_o(),
		.cts_pad_i(),
		.dtr_pad_o(),
		.dsr_pad_i(),
		.ri_pad_i(),
		.dcd_pad_i(),
		.int_o()
	);

	gpio gpio0 (
		// GPIO bus
		.gpio_i		(gpio0_i),
		.gpio_o		(gpio0_o),
		.gpio_dir_o	(gpio0_dir_o),

		// Wishbone slave interface
		.wb_adr_i	(wb_gpio0_adr[2]),
		.wb_dat_i	(wb_gpio0_dat[7:0]),
		.wb_we_i	(wb_gpio0_we),
		.wb_cyc_i	(wb_gpio0_cyc),
		.wb_stb_i	(wb_gpio0_stb),
		.wb_cti_i	(wb_gpio0_cti),
		.wb_bte_i	(wb_gpio0_bte),
		.wb_dat_o	(wb_gpio0_rdt[7:0]),
		.wb_ack_o	(wb_gpio0_ack),
		.wb_err_o	(wb_gpio0_err),
		.wb_rty_o	(wb_gpio0_rty),

		.wb_clk		(wb_clk),
		.wb_rst		(wb_rst)
	);
	assign wb_gpio0_rdt[31:8] = 24'h000000;

	wire timer_irq;

	wb_timer timer0 (
		// GPIO bus
		.o_timer_irq  (timer_irq),
		// Wishbone slave interface
		.wb_adr_i	(wb_tmr0_adr),
		.wb_dat_i	(wb_tmr0_dat),
		.wb_we_i	(wb_tmr0_we),
		.wb_cyc_i	(wb_tmr0_cyc),
		.wb_stb_i	(wb_tmr0_stb),
		.wb_cti_i	(wb_tmr0_cti),
		.wb_bte_i	(wb_tmr0_bte),
		.wb_sel_i   (wb_tmr0_sel),
		.wb_dat_o	(wb_tmr0_rdt),
		.wb_ack_o	(wb_tmr0_ack),
		.wb_err_o	(wb_tmr0_err),
		.wb_rty_o	(wb_tmr0_rty),

		.wb_clk		(wb_clk),
		.wb_rst		(wb_rst)
	);

	servile_rf #(
	.width(width),
	.EMBEDDED(EMBEDDED),
	.PRE_REGISTER(PRE_REGISTER),
	.reset_pc(reset_pc),
	.reset_strategy(reset_strategy),
	.sim(sim),
	.debug(debug),
	.with_c(with_c),
	.with_csr(with_csr),
	.with_mdu(with_mdu)
	) 
	servile_core (
		    .i_clk(wb_clk),
   			.i_rst(wb_rst),
   			.i_timer_irq(timer_irq),
			.o_wb_mem_adr(wb_serv_adr),
			.o_wb_mem_dat(wb_serv_dat),
			.o_wb_mem_sel(wb_serv_sel),
			.o_wb_mem_we(wb_serv_we),
			.o_wb_mem_stb(wb_serv_stb),
			.i_wb_mem_rdt(wb_serv_rdt),
			.i_wb_mem_ack(wb_serv_ack)
   );

	assign wb_serv_cyc = wb_serv_stb;
	assign wb_serv_bte = 0;
	assign wb_uart0_err = 0;
	assign wb_uart0_rty = 0;

	assign wb_serv_cti = CTI_CLASSIC;




endmodule
