# RTOS basic example SERVE-SoC
This example implements a port example of FreeRTOS on SERVE-SoC. The program creates two tasks. The first task is executed every 500ms and the second task is executed every 300ms. The tasks control a separate set of LEDs and send a message via UART during the operation.

## Project structure
The following shows the file structure of the current project.

```bash
.
├── inc
│   ├── freertos_risc_v_chip_specific_extensions.h
│   ├── FreeRTOSConfig.h
│   ├── SERVE_regs.h
│   ├── SERVE.h
│   ├── print.h
│   ├── riscv-csr.h
│   ├── soc_gpio.h
│   ├── soc_regs.h
│   ├── soc_uart.h
│   └── systimer.h
├── src
│   ├── main.c
│   ├── print.c
│   ├── soc_gpio.c
│   ├── soc_uart.c
│   ├── start.S
│   └── systimer.c
├── Makefile
├── SERVE-wb-soc.lds
└── nmon-loader.sh
```

# How to use this example

Connect the SERVE-SoC to the PC using a USB-to-Serial converter (e.g., FT232RL), following this schematic diagram. The `uart0_tx `must be connected to the RX pin on the USB-to-Serial converter and the `uart0_rx` must be connected to the TX pin on the USB-to-Serial converter. The GND of the SERVE-SoC mut be connected to the GND of the USB-to-Serial converter.


|||||
|-|-|-|-|
|#|Input (ui)|Output (uo) |Bidirectional (uio)|
|0|gpio_i[0] | gpio_o[0] | cs_flash |
|1|gpio_i[1] | gpio_o[1] | sio0 |
|2|gpio_i[2] | gpio_o[2] | sio1 |
|3|gpio_i[3] | gpio_o[3] | sck |
|4|gpio_i[4] | gpio_o[4] | sio2 |
|5|gpio_i[5] | gpio_o[5] | sio3 |
|6|gpio_i[6] | gpio_o[6] | cs_ram0 |
|7|uart0_rx  | uart0_tx  | cs_ram1 |


## Compile and program de SoC with the application
1. Pull the FreeRTOS main repository
    ```bash
    cd ./sw/8-FreeRTOS-demo1
    git submodule update --recursive
    ```
2. Compile the program
    ```bash
    cd ./sw/8-FreeRTOS-demo1
    make clean build nmon
    ```
3. Program the SERVE-SoC with the compiled application
    ```bash
    expect nmon-loader.sh FreeRTOS_demo.nmon /dev/ttyUSB0 115200
    ```