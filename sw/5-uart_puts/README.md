# UART and GPIO drivers on SERVE-SoC
This example implements the drivers/libraries to handle the GPIO and the UART on the SERVE-SoC system. The program does the same as the [4-uart_stub_2](../4-uart_stub_2/) example, but instead of using the uart function from the bootloader, it uses a library to configure the UART port.

## Project structure
The following shows the file structure of the current project.

```bash
.
├── inc
│   ├── SERVE_regs.h # Core registers definitions
│   ├── SERVE.h      # Helper functions and definitions
│   ├── riscv-csr.h.    # Definitions and registers of the CSR registers
│   ├── soc_gpio.h      # Register definitions and functions for controlling GPIOs
│   ├── soc_regs.h      # Peripherals memory map
│   ├── soc_uart.h      # Register definitions and functions for controlling UART
│   └── systimer.h      # Funtions and definitions for using the systimer
├── src
│   ├── soc_gpio.c      # GPIOs functions
│   ├── soc_uart.c      # UART functions
│   ├── stub_stdlib.c   # stdlib stub functions
│   └── systimer.c      # Systimer functions
├── main.c              # Main program
├── start.S             # crt0 initialization of the processor before calling main function
├── SERVE-wb-soc.lds # Linker script memory segments definitions
├── qemu.lds            # Linker script memory segments definitions for QEMU
├── Makefile            # Makefile targets 
└── nmon-loader.sh      # SERVE-SoC programmer through UART
```

# How to use this example

Connect the SERVE-SoC to the PC using a USB-to-Serial converter (e.g., FT232RL), following this schematic diagram. The `uart0_tx `must be connected to the RX pin on the USB-to-Serial converter and the `uart0_rx` must be connected to the TX pin on the USB-to-Serial converter. The GND of the SERVE-SoC mut be connected to the GND of the USB-to-Serial converter.

||||
|-|-|-|
|tt-io| direction | SoC pinout
|clk|input  |clk|
|rst_n|input  |rst_n|
|ui[7:0]|input  |gpio_i[7:0]|
|uo[7:0]|output |gpio_o[7:0]|
|uio[0]|output |cs_flash|
|uio[1]|inout  |sio0|
|uio[2]|inout  |sio1|
|uio[3]|output |sck|
|uio[4]|output |uart0_tx (tt-->usb2serial)|
|uio[5]|input  |uart0_rx (tt<--usb2serial)|
|uio[6]|output |cs_ram0|
|uio[7]|output |cs_ram1|

## Compile and program de SoC with the application

1. Compile the program
    ```bash
    cd ./sw/5-uart_puts
    make clean build nmon
    ```
2. Program the SERVE-SoC with the compiled application
    ```bash
    expect nmon-loader.sh application.nmon /dev/ttyUSB0 115200
    ```