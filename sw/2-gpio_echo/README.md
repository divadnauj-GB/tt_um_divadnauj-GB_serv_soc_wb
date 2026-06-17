# GPIO echo on SERVE-SoC
This example reads the GPIO input and then send it to the GPIO output. The GPIO input is connected to the switched (SW) on the DE1 FPGA board and the GPIO output is connected to the Red LEDs on the DE1 FPGA board.

## Project structure
The following corresponds to the project structure the main program is located in `main.c` the `start.S` file contains the initialization file equivalent to `crt0.S` required by C programing. The file `stub_stdlib.c` incorporates the function definitions required by the `libc` library in order to enable the usage of standar C functions such as `sprintf`, `malloc` among others. 

The `SERVE-wb-soc.lds` corresponds to the linkerscript where the memoery segments are defined according to the `SERVE-SoC` arhitecture.

The `Makefile` implements the compilation targets of the program.

Finally, the `nmon-loader.sh` is an script the allows to program the `SERVE-SoC` using the UART conection, this file is independent of the program.



```bash
.
├── main.c
├── stub_stdlib.c
├── start.S
├── SERVE-wb-soc.lds
├── Makefile
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

1. Compile the program
    ```bash
    cd ./sw/2-gpio_echo
    make clean build nmon
    ```
2. Program the SERVE-SoC with the compiled application
    ```bash
    expect nmon-loader.sh application.nmon /dev/ttyUSB0 115200
    ```