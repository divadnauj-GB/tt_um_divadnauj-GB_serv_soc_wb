# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_divadnauj_GB_serv_rv32e.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_INCLUDE_DIRS += $(SRC_DIR)/uart16550
VERILOG_INCLUDE_DIRS += $(SRC_DIR)/wb_bfm
VERILOG_INCLUDE_DIRS += $(SRC_DIR)/serv_wb_soc_rv32e/
VERILOG_INCLUDE_DIRS += $(PWD)

VERILOG_SOURCES += $(PWD)/timescale.v
VERILOG_SOURCES += $(SRC_DIR)/gpio/gpio.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_aligner.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_alu.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_bufreg.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_bufreg2.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_compdec.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_csr.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_ctrl.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_debug.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_decode.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_immdec.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_mem_if.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_rf_if.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_rf_ram_if.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_rf_ram.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_rf_top.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_state.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_synth_wrapper.v
VERILOG_SOURCES += $(SRC_DIR)/serv/serv_top.v
VERILOG_SOURCES += $(SRC_DIR)/servile/servile_arbiter.v
VERILOG_SOURCES += $(SRC_DIR)/servile/servile_mux.v
VERILOG_SOURCES += $(SRC_DIR)/servile/servile_rf_mem_if.v
VERILOG_SOURCES += $(SRC_DIR)/servile/servile_rf.v
VERILOG_SOURCES += $(SRC_DIR)/servile/servile.v
VERILOG_SOURCES += $(SRC_DIR)/wb_timer/nanorv32_timer.v
VERILOG_SOURCES += $(SRC_DIR)/wb_timer/wb_timer.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/raminfr.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_receiver.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_regs.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_rfifo.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_sync_flops.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_tfifo.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_top.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_transmitter.v
VERILOG_SOURCES += $(SRC_DIR)/uart16550/uart_wb.v
VERILOG_SOURCES += $(SRC_DIR)/verilog-arbiter/arbiter.v
VERILOG_SOURCES += $(SRC_DIR)/vlog_tb_utils/vlog_functions.v
VERILOG_SOURCES += $(SRC_DIR)/vlog_tb_utils/vlog_tap_generator.v
VERILOG_SOURCES += $(SRC_DIR)/vlog_tb_utils/vlog_tb_utils.v
VERILOG_SOURCES += $(SRC_DIR)/wb_bfm/wb_bfm_master.v
VERILOG_SOURCES += $(SRC_DIR)/wb_bfm/wb_bfm_slave.v
VERILOG_SOURCES += $(SRC_DIR)/wb_bfm/wb_bfm_memory.v
VERILOG_SOURCES += $(SRC_DIR)/wb_bfm/wb_bfm_transactor.v
VERILOG_SOURCES += $(SRC_DIR)/wb_qqspi/wb_qqspi.v
VERILOG_SOURCES += $(SRC_DIR)/wb_qqspi/qqspi.v
VERILOG_SOURCES += $(SRC_DIR)/wb_intercon/wb_cdc.v
VERILOG_SOURCES += $(SRC_DIR)/wb_intercon/wb_arbiter.v
VERILOG_SOURCES += $(SRC_DIR)/wb_intercon/wb_data_resize.v
VERILOG_SOURCES += $(SRC_DIR)/wb_intercon/wb_mux.v
VERILOG_SOURCES += $(SRC_DIR)/serv_wb_soc_rv32e/serv_wb_soc_rv32e.v
VERILOG_SOURCES += $(SRC_DIR)/serv_wb_soc_rv32e/wb_intercon.v
VERILOG_SOURCES += $(SRC_DIR)/tt_um_divadnauj_GB_serv_rv32e.v
else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)
VERILOG_INCLUDE_DIRS += $(PWD)
# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(PWD)/psram.v
VERILOG_SOURCES += $(PWD)/spiflash.v

#COCOTB_TOPLEVEL = tb
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
#COCOTB_TEST_MODULES = test
MODULE = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
