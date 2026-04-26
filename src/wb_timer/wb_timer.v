module wb_timer
       (
	input wire 			wb_clk,
	input wire			wb_rst,

	input wire		[31:0]	wb_adr_i,
	input wire		[31:0] 	wb_dat_i,
	input wire			    wb_we_i,
	input wire			    wb_cyc_i,
	input wire			    wb_stb_i,
	input wire		[2:0] 	wb_cti_i,
	input wire		[1:0]	wb_bte_i,
    input wire      [3:0] 	wb_sel_i,
	output reg	    [31:0]	wb_dat_o,
	output reg		    wb_ack_o,
	output wire		    wb_err_o,
	output wire		    wb_rty_o,
	output wire		    o_timer_irq
);


reg [1:0] mtime_valid;
reg [1:0] mtimecmp_valid;
wire mtime_ready;
wire mtimecmp_ready;
wire [3:0] mtime_wstrb;
wire wb_valid = wb_cyc_i & wb_stb_i & !wb_ack_o;
wire [31:0] wb_dat_rd;

assign mtime_wstrb = wb_sel_i & {4{wb_we_i}} & {4{wb_valid}};


always @(*) begin
    case({wb_valid, wb_adr_i[3:2]}) 
        3'b100: {mtimecmp_valid,mtime_valid} = 4'b0001; // Timer value low byte
        3'b101: {mtimecmp_valid,mtime_valid} = 4'b0010; // Timer value high byte
        3'b110: {mtimecmp_valid,mtime_valid} = 4'b0100; // Timer compare low byte
        3'b111: {mtimecmp_valid,mtime_valid} = 4'b1000; // Timer compare high byte
        default: {mtimecmp_valid,mtime_valid} = 4'b0000;
    endcase
end


always @(posedge wb_clk, posedge wb_rst)
	if (wb_rst) begin
		wb_ack_o <= 0;
		wb_dat_o <= 32'h0000_0000;
	end
	else if (wb_ack_o) begin
		wb_ack_o <= 0;
	end else if (wb_cyc_i & wb_stb_i & !wb_ack_o & mtime_ready) begin
		wb_ack_o <= 1;
		wb_dat_o <= wb_dat_rd;
	end



assign wb_err_o = 0;
assign wb_rty_o = 0;


nanorv32_timer #(
				.ENABLE_MTIMECMP	(1)
			)
			timer (
				.reset(wb_rst),
				.clk(wb_clk),
				.io_mtime_valid(mtime_valid),
				.io_mtimecmp_valid(mtimecmp_valid),
				.io_ready(mtime_ready),
				.io_wdata(wb_dat_i),
				.io_wstrb(mtime_wstrb),
				.io_rdata(wb_dat_rd),
				.mtip(o_timer_irq)
				);


endmodule