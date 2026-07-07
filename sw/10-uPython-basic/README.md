# MicroPython basic example SERVE-SoC
This example implements a port example of MicroPython on SERVE-SoC. The program runs REPL terminal of micropython.

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
1. Pull the MicroPython main repository
    ```bash
    cd ./sw/10-uPython-basic
    git submodule update --recursive
    ```
2. Compile the program
    ```bash
    cd ./sw/10-uPython-basic
    make PATCH=1 clean all pre-flash
    ```
3. Program the SERVE-SoC with the compiled. This can be done by flashing the QPMOD flash memory using the generated file in `build/firmware-pre-flash.bin`

4. After booting the system you will get the prompt of the bootloader as follows: 

    nmon has only 4 commands:

        q - quit
        d <addr> - read 32-bit word from <addr> address
        w <addr> <val> - write 32-bit word <val> to <addr>
        g <addr> - jump to <addr>
        nmon> 

5. You need to type g00000400, this will instruct the bootloader to execute MicroPython which entry point is the address 00000400. This process was intentionally created such that after a reset we can use the bootloader to load and execute any other programs from ram memory w/o reprogramming the flash memory every time. 