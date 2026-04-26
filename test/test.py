import cocotb
from cocotb.clock import Clock
from cocotb.types import LogicArray
from cocotb.triggers import ClockCycles
from cocotbext.uart import UartSource, UartSink
from cocotb.triggers import RisingEdge, FallingEdge
import logging
logging.getLogger("cocotb.tb.uart0_tx").setLevel(logging.WARNING)
logging.getLogger("cocotb.tb.uart0_rx").setLevel(logging.WARNING)


GOLDEN_OUTPUT="FreeRTOs-check.txt"
OUTPUT_SIM="FreeRTOs.txt"

#logging.basicConfig(level=logging.DEBUG)

async def uart_send(clk,dev, msg=[]):
    for d in msg:
        await dev.write(f"{d}".encode())
        await ClockCycles(clk, 10500)
    await ClockCycles(clk, 50500)


class monitor_uart():
    def __init__(self,tx):
        self.uart_sink = UartSink(tx, baud=115200, bits=8)
        with open(OUTPUT_SIM,'w') as fp:
            pass

    async def start(self):
        while True:
            ch = await self.uart_sink.read()
            print(ch.decode("utf-8"), end="")
            with open(OUTPUT_SIM,"a") as fp:
                fp.write(ch.decode("utf-8"))

@cocotb.test()
async def test_uart(dut):

    dut._log.setLevel(logging.DEBUG)
    clock = dut.clk
    uart_source = UartSource(dut.uart0_rx, baud=115200, bits=8)
    uart_monitor = monitor_uart(dut.uart0_tx)
    cocotb.start_soon(uart_monitor.start())
    await ClockCycles(dut.clk, 10)

    await ClockCycles(dut.clk, 20000 * 10)
   
    await uart_send(dut.clk, uart_source, "g01000000")

    #await ClockCycles(dut.clk, 20000 * 50)
    await ClockCycles(dut.clk, 20000 * 1000)
   

    with open(GOLDEN_OUTPUT,"r") as Gfp:
        expected_output=Gfp.readlines()

    with open(OUTPUT_SIM,"r") as Rfp:
        sim_output=Rfp.readlines()

    assert(expected_output==sim_output)