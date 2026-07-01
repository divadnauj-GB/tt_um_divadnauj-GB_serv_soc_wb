module de10_nano_nanorv32_wb_soc(
	input wire CLOCK_50,
	input wire [1:0] KEY,
	input wire [3:0] SW,
	output wire [7:0] LED,
	inout wire [7:0] GPIO_0,
	inout wire [7:0] GPIO_1
	);

	wire wb_clk;
	wire wb_rst;

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

	altera_pll_wb_clkgen #(
		.INPUT_FREQUENCY ("50.0 MHz"),
		.WB_CLK_FREQUENCY ("50.0 MHz")
	)
	clkgen(
		.sys_clk_pad_i (CLOCK_50),
		.rst_n_pad_i (KEY[0]),
		.wb_clk_o (wb_clk),
		.wb_rst_o (wb_rst)
	);


	assign LED[7:0] = gpio0_o[7:0];
	assign gpio0_i[7:2] = {SW[3:0],~KEY[1],~KEY[0]};


	assign GPIO_1[0] =  w_ce[0];
	assign GPIO_1[1] = w_sio_oe[0] ? w_sio0_si_mosi_o : 1'bz;
	assign GPIO_1[2] = w_sio_oe[1] ? w_sio1_so_miso_o : 1'bz;
	assign GPIO_1[3] = sclk;
	assign GPIO_1[4] = w_sio_oe[2] ? w_sio2_o : 1'bz;
	assign GPIO_1[5] = w_sio_oe[3] ? w_sio3_o : 1'bz;
	assign GPIO_1[6] = w_ce[1];
	assign GPIO_1[7] = w_ce[2];

	assign w_sio0_si_mosi_i = GPIO_1[1];
	assign w_sio1_so_miso_i = GPIO_1[2];
	assign w_sio2_i			= GPIO_1[4];
	assign w_sio3_i			= GPIO_1[5];

	assign GPIO_0[1] = uart0_tx;
	assign uart0_rx = GPIO_0[3];


	serv_soc_wb #(
		.width(1),
		.EMBEDDED(1),
		.PRE_REGISTER(1),
		.reset_pc(32'h00000000),
		.reset_strategy("MINI"),
		.sim(0),
		.debug(0),
		.with_c(0),
		.with_csr(1),
		.with_mdu(0)
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
