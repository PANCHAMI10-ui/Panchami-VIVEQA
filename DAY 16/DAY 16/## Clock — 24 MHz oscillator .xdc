## Clock — 24 MHz oscillator (Bank 15)
create_clock -period 41.667 -name sys_clk -waveform {0 20.833} [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]

## Reset — slide switch SS0
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports rst_n]

## LEDs (Bank 35)
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports L1]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports L2]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports L3]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports L4]