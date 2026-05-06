# Blink Led on SERVE-SoC
This example uses the LEDs connected to the GPIO output of the SERVE-SoC. The following table shows the LED sequence implemented, the "x" mean LED OFF and "o" meand LED ON. 

The transitions between sequence states takes approximately 200ms, implemented using a custom locking dealy function. 

|76543210|
|---|
|**xxxxxxxo**|
|**xxxxxxox**|
|**xxxxxoxx**|
|**xxxxoxxx**|
|**xxxoxxxx**|
|**xxoxxxxx**|
|**xoxxxxxx**|
|**oxxxxxxx**|

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
    cd ./sw/1-blink_led
    make clean build nmon
    ```
2. Program the SERVE-SoC with the compiled application
    ```bash
    expect nmon-loader.sh application.nmon /dev/ttyUSB0 115200
    ```