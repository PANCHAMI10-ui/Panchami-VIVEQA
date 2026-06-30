# --------------------------------------------------------
# Clock Signal (24 MHz)
# --------------------------------------------------------
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 41.667 [get_ports clk]

# --------------------------------------------------------
# LEDs L1-L8
# --------------------------------------------------------
set_property PACKAGE_PIN D5 [get_ports {led[0]}]
set_property PACKAGE_PIN A3 [get_ports {led[1]}]
set_property PACKAGE_PIN B4 [get_ports {led[2]}]
set_property PACKAGE_PIN A4 [get_ports {led[3]}]
set_property PACKAGE_PIN E6 [get_ports {led[4]}]
set_property PACKAGE_PIN C13 [get_ports {led[5]}]
set_property PACKAGE_PIN C14 [get_ports {led[6]}]
set_property PACKAGE_PIN D14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# --------------------------------------------------------
# Buttons
# --------------------------------------------------------
# REPLACE THE "__" WITH YOUR ACTUAL BUTTON PINS
set_property PACKAGE_PIN A13 [get_ports btn1]
set_property PACKAGE_PIN F5 [get_ports btn2]
set_property IOSTANDARD LVCMOS33 [get_ports btn1]
set_property IOSTANDARD LVCMOS33 [get_ports btn2]