## Clock — 24 MHz
create_clock -period 41.667 -name sys_clk -waveform {0 20.833} [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]

## Reset — slide switch SS0
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports rst_n]

## Control inputs — slide switches SS1 (shift left), SS2 (shift right)
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports BTN_LEFT]
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [get_ports BTN_RIGHT]

## 8 LEDs (LED1–LED8, Bank 35)
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {LED[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {LED[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {LED[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {LED[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {LED[7]}]