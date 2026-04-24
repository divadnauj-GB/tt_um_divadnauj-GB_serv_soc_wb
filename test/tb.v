`default_nettype none
`timescale 1ns / 1ps


module tb_clkgen(
	 wb_clk_o,
	 wb_rst_o,

	 sdram_clk_o,
	 sdram_rst_o
);

	output wb_clk_o;
	output wb_rst_o;
	output sdram_clk_o;
	output sdram_rst_o;
	reg async_rst = 0;
	reg sync_rst_n = 0;

	// 50 MHz
	reg wb_clk_o = 0;
	always
	begin
		#10 wb_clk_o = !wb_clk_o;
	end

	// 100 MHz
	reg sdram_clk_o = 0;
	always
	begin
		#5 sdram_clk_o = !sdram_clk_o;
	end

	initial
	begin
		#2 sync_rst_n = 1;
		#3 async_rst = 1;
		#27 async_rst = 0;
	end

	// Reset generation for wishbone
	reg [15:0]	wb_rst_shr;

	always @(posedge wb_clk_o or posedge async_rst)
		if (async_rst)
			wb_rst_shr <= 16'hffff;
		else
			wb_rst_shr <= {wb_rst_shr[14:0], ~(sync_rst_n)};

	assign wb_rst_o = wb_rst_shr[15];

	// Reset generation for sdram
	reg [15:0]	sdram_rst_shr;

	always @(posedge sdram_clk_o or posedge async_rst)
		if (async_rst)
			sdram_rst_shr <= 16'hffff;
		else
			sdram_rst_shr <= {sdram_rst_shr[14:0], ~(sync_rst_n)};

	assign sdram_rst_o = sdram_rst_shr[15];

endmodule

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(1, tb);
    #1;
  end


  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

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

	wire spi_flash_clk;
	wire spi_psram_clk;
	assign spi_flash_clk = sclk;
	assign spi_psram_clk = sclk;

	wire spi_ce0 ;
	assign spi_ce0 = w_ce[0];
	wire spi_ce1 ;
	assign spi_ce1 = w_ce[1];
	wire spi_ce2;
	assign spi_ce2 = w_ce[2];

	tb_clkgen clkgen(
		.wb_clk_o(clk),
		.wb_rst_o(rst_n)
	);

	wire spi_io3;
	assign spi_io3 =  1'bz;
	wire spi_io2 ;
	assign spi_io2 = 1'bz;
	wire spi_io1;
	assign spi_io1 =  uio_oe[2]  ? uio_out[2] : 1'bz;
	wire spi_io0 ;
	assign spi_io0 = uio_oe[1]  ? uio_out[1] : 1'bz;


	//assign w_sio0_si_mosi_i = spi_io0;
	//assign w_sio1_so_miso_i = spi_io1;
	//assign w_sio2_i			= spi_io2;
	//assign w_sio3_i			= spi_io3;

  assign gpio0_i = 8'b0000_0000;
  assign ui_in = gpio0_i;
  assign gpio0_o = uo_out;
  assign ena = 1'b1;  

  assign w_ce[0] = uio_out[0];
  //assign w_sio0_si_mosi_o = uio_out[1];
  //assign w_sio1_so_miso_o = uio_out[2];
  assign sclk = uio_out[3];
  assign uart0_tx = uio_out[4];
  //
  assign w_ce[1] = uio_out[6];
  assign w_ce[2] = uio_out[7];
  
  assign uio_in[0] = 1'b0;
  assign uio_in[1] = spi_io0;
  assign uio_in[2] = spi_io1;
  assign uio_in[3] = 1'b0;
  assign uio_in[4] = 1'b0;
  assign uio_in[5] = uart0_rx;
  assign uio_in[6] = 1'b0;
  assign uio_in[7] = 1'b0;

  

  //assign w_sio_oe[3:0] = {uio_oe[5:4],uio_oe[2:1]}; // w_ce[0] is always output

  // Replace tt_um_example with your module name:
  tt_um_divadnauj_GB_serv_rv32e user_project (
      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (~rst_n)     // not reset
  );

  spiflash #(
      // change the hex file to match your project
      .FILENAME("./firmware.hex")
  ) spiflash (
      .csb(spi_ce0),
      .clk(spi_flash_clk),
      .io0(spi_io0),
      .io1(spi_io1),
      .io2(spi_io2),
      .io3(spi_io3)
  );

  psram #(
      // change the hex file to match your project
      .FILENAME("./firmware-f.hex")
  ) psram_I (
      .ce_n(spi_ce1),
      .sck (spi_psram_clk),
      .dio ({spi_io3, spi_io2, spi_io1, spi_io0})
  );

  psram psram_II (
      .ce_n(spi_ce2),
      .sck (spi_psram_clk),
      .dio ({spi_io3, spi_io2, spi_io1, spi_io0})
  );


endmodule
