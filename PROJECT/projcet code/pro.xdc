# ============================================================
# AT-STLN-ARTIX 7-001 (Anmaya Technologies)
# XDC Constraints for parking_top
# ============================================================

# Clock - 24 MHz oscillator (ASDM1) on D13
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 41.667 -name sys_clk [get_ports clk]

# UART - using PMOD connector pins (Bank 34)
# TX  → PMOD IO_0 = T2
# RX  → PMOD IO_1 = R3
set_property PACKAGE_PIN T2 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

set_property PACKAGE_PIN R3 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

# Servo PWM - DC Motor driver IN2 pin = H11 (Bank 14)
set_property PACKAGE_PIN H11 [get_ports servo_pwm]
set_property IOSTANDARD LVCMOS33 [get_ports servo_pwm]

# Buzzer - BZR_OUT on K5 (Bank 35) - confirmed from hardware manual section 4.11
set_property PACKAGE_PIN K5 [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]

# User LEDs - Bank 35 (section 3.1)
set_property PACKAGE_PIN D5  [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN A3  [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN B4  [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN A4  [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN E6  [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN C13 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN C14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN D14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]