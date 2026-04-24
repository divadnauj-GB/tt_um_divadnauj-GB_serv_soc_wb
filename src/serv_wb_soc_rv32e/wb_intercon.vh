wire [31:0] wb_serv_adr;
wire [31:0] wb_serv_dat;
wire  [3:0] wb_serv_sel;
wire        wb_serv_we;
wire        wb_serv_cyc;
wire        wb_serv_stb;
wire  [2:0] wb_serv_cti;
wire  [1:0] wb_serv_bte;
wire [31:0] wb_serv_rdt;
wire        wb_serv_ack;
wire        wb_serv_err;
wire        wb_serv_rty;
wire [31:0] wb_qqspi0_adr;
wire [31:0] wb_qqspi0_dat;
wire  [3:0] wb_qqspi0_sel;
wire        wb_qqspi0_we;
wire        wb_qqspi0_cyc;
wire        wb_qqspi0_stb;
wire  [2:0] wb_qqspi0_cti;
wire  [1:0] wb_qqspi0_bte;
wire [31:0] wb_qqspi0_rdt;
wire        wb_qqspi0_ack;
wire        wb_qqspi0_err;
wire        wb_qqspi0_rty;
wire [31:0] wb_uart0_adr;
wire  [7:0] wb_uart0_dat;
wire  [3:0] wb_uart0_sel;
wire        wb_uart0_we;
wire        wb_uart0_cyc;
wire        wb_uart0_stb;
wire  [2:0] wb_uart0_cti;
wire  [1:0] wb_uart0_bte;
wire  [7:0] wb_uart0_rdt;
wire        wb_uart0_ack;
wire        wb_uart0_err;
wire        wb_uart0_rty;
wire [31:0] wb_gpio0_adr;
wire [31:0] wb_gpio0_dat;
wire  [3:0] wb_gpio0_sel;
wire        wb_gpio0_we;
wire        wb_gpio0_cyc;
wire        wb_gpio0_stb;
wire  [2:0] wb_gpio0_cti;
wire  [1:0] wb_gpio0_bte;
wire [31:0] wb_gpio0_rdt;
wire        wb_gpio0_ack;
wire        wb_gpio0_err;
wire        wb_gpio0_rty;
wire [31:0] wb_tmr0_adr;
wire [31:0] wb_tmr0_dat;
wire  [3:0] wb_tmr0_sel;
wire        wb_tmr0_we;
wire        wb_tmr0_cyc;
wire        wb_tmr0_stb;
wire  [2:0] wb_tmr0_cti;
wire  [1:0] wb_tmr0_bte;
wire [31:0] wb_tmr0_rdt;
wire        wb_tmr0_ack;
wire        wb_tmr0_err;
wire        wb_tmr0_rty;

wb_intercon wb_intercon0
   (.wb_clk_i        (wb_clk),
    .wb_rst_i        (wb_rst),
    .wb_serv_adr_i   (wb_serv_adr),
    .wb_serv_dat_i   (wb_serv_dat),
    .wb_serv_sel_i   (wb_serv_sel),
    .wb_serv_we_i    (wb_serv_we),
    .wb_serv_cyc_i   (wb_serv_cyc),
    .wb_serv_stb_i   (wb_serv_stb),
    .wb_serv_cti_i   (wb_serv_cti),
    .wb_serv_bte_i   (wb_serv_bte),
    .wb_serv_rdt_o   (wb_serv_rdt),
    .wb_serv_ack_o   (wb_serv_ack),
    .wb_serv_err_o   (wb_serv_err),
    .wb_serv_rty_o   (wb_serv_rty),
    .wb_qqspi0_adr_o (wb_qqspi0_adr),
    .wb_qqspi0_dat_o (wb_qqspi0_dat),
    .wb_qqspi0_sel_o (wb_qqspi0_sel),
    .wb_qqspi0_we_o  (wb_qqspi0_we),
    .wb_qqspi0_cyc_o (wb_qqspi0_cyc),
    .wb_qqspi0_stb_o (wb_qqspi0_stb),
    .wb_qqspi0_cti_o (wb_qqspi0_cti),
    .wb_qqspi0_bte_o (wb_qqspi0_bte),
    .wb_qqspi0_rdt_i (wb_qqspi0_rdt),
    .wb_qqspi0_ack_i (wb_qqspi0_ack),
    .wb_qqspi0_err_i (wb_qqspi0_err),
    .wb_qqspi0_rty_i (wb_qqspi0_rty),
    .wb_uart0_adr_o  (wb_uart0_adr),
    .wb_uart0_dat_o  (wb_uart0_dat),
    .wb_uart0_sel_o  (wb_uart0_sel),
    .wb_uart0_we_o   (wb_uart0_we),
    .wb_uart0_cyc_o  (wb_uart0_cyc),
    .wb_uart0_stb_o  (wb_uart0_stb),
    .wb_uart0_cti_o  (wb_uart0_cti),
    .wb_uart0_bte_o  (wb_uart0_bte),
    .wb_uart0_rdt_i  (wb_uart0_rdt),
    .wb_uart0_ack_i  (wb_uart0_ack),
    .wb_uart0_err_i  (wb_uart0_err),
    .wb_uart0_rty_i  (wb_uart0_rty),
    .wb_gpio0_adr_o  (wb_gpio0_adr),
    .wb_gpio0_dat_o  (wb_gpio0_dat),
    .wb_gpio0_sel_o  (wb_gpio0_sel),
    .wb_gpio0_we_o   (wb_gpio0_we),
    .wb_gpio0_cyc_o  (wb_gpio0_cyc),
    .wb_gpio0_stb_o  (wb_gpio0_stb),
    .wb_gpio0_cti_o  (wb_gpio0_cti),
    .wb_gpio0_bte_o  (wb_gpio0_bte),
    .wb_gpio0_rdt_i  (wb_gpio0_rdt),
    .wb_gpio0_ack_i  (wb_gpio0_ack),
    .wb_gpio0_err_i  (wb_gpio0_err),
    .wb_gpio0_rty_i  (wb_gpio0_rty),
    .wb_tmr0_adr_o   (wb_tmr0_adr),
    .wb_tmr0_dat_o   (wb_tmr0_dat),
    .wb_tmr0_sel_o   (wb_tmr0_sel),
    .wb_tmr0_we_o    (wb_tmr0_we),
    .wb_tmr0_cyc_o   (wb_tmr0_cyc),
    .wb_tmr0_stb_o   (wb_tmr0_stb),
    .wb_tmr0_cti_o   (wb_tmr0_cti),
    .wb_tmr0_bte_o   (wb_tmr0_bte),
    .wb_tmr0_rdt_i   (wb_tmr0_rdt),
    .wb_tmr0_ack_i   (wb_tmr0_ack),
    .wb_tmr0_err_i   (wb_tmr0_err),
    .wb_tmr0_rty_i   (wb_tmr0_rty));

