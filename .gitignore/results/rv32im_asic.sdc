###############################################################################
# Created by write_sdc
# Sun Aug 16 11:57:26 2026
###############################################################################
current_design rv32im_asic
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_propagated_clock [get_clocks {clk}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[10]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[11]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[12]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[13]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[14]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[15]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[16]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[17]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[18]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[19]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[20]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[21]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[22]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[23]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[24]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[25]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[26]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[27]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[28]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[29]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[30]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[31]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[4]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[5]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[6]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[7]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[8]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_data[9]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_rd[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_rd[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_rd[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_rd[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_rd[4]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {commit_valid}]
set_false_path\
    -from [get_ports {rst}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
set_max_fanout 32.0000 [current_design]
