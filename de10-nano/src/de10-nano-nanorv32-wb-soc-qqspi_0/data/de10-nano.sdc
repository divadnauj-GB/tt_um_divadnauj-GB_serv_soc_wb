#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20 [get_ports CLOCK_50]
#create_clock -period 20 [get_ports CLOCK2_50]
#create_clock -period 20 [get_ports CLOCK3_50]
#create_clock -period 20 [get_ports CLOCK4_50]

# for enhancing USB BlasterII to be reliable, 25MHz
#create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
#set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
#set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
#set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
#set input_setup_delay_value [expr 20 * 0.65]
#set input_hold_delay_value [expr 20 * 0.2]
#set_input_delay -clock [get_clocks CLOCK_50] -max $input_setup_delay_value {GPIO_1}
#set_input_delay -clock [get_clocks CLOCK_50] -min $input_hold_delay_value {GPIO_1}


#**************************************************************
# Set Output Delay
#**************************************************************
#set output_setup_delay_value [expr 20 * 0.65]
#set output_hold_delay_value 1
#set_output_delay -clock [get_clocks CLOCK_50] -max $output_setup_delay_value {GPIO_1[7] GPIO_1[6] GPIO_1[5] GPIO_1[4] GPIO_1[2] GPIO_1[1] GPIO_1[0]}
#set_output_delay -clock [get_clocks CLOCK_50] -min $output_hold_delay_value {GPIO_1}
#
#
#
#set spi_clk_setup_delay_value [expr 20 * 0.2]
#set_output_delay -clock [get_clocks CLOCK_50] -max $spi_clk_setup_delay_value {GPIO_1[3]}


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************



