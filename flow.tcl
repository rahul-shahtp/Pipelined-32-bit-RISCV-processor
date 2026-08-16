# flow.tcl - OpenROAD P&R flow for the pipelined RV32IM processor
#             WITH the 4 SRAM macros placed and powered.

# Usage:
#   openroad -no_init -exit flow.tcl
#
# Inputs:
#   - Gate-level netlist: synth_out/rv32im_asic_sky130.v
#   - PDK (sky130A) via $env(PDK_ROOT) or -rd PDK_ROOT=...
#   - SRAM blackbox file is used ONLY by Yosys. Do NOT read it here: doing so
#     drops all 4 SRAM instances (OpenROAD binds them via the LEF macro).
#
# Outputs (in results/):
#   - rv32im_asic.def / _route.v / .sdc / .db
#   - drc.rpt

# PDK location - override with: openroad -no_init -rd PDK_ROOT=/path -exit flow.tcl
if {![info exists PDK_ROOT]} {
    set PDK_ROOT $env(PDK_ROOT)
}
set PDK         "sky130A"
set TECH_DIR    "$PDK_ROOT/$PDK"

# Design
set DESIGN      "rv32im_asic"
set NETLIST     [file normalize "synth_out/rv32im_asic_sky130.v"]
set SRAM_BB     [file normalize "rtl/mem_stage/sram_1kbyte_1rw1r_8x1024_8_bb.v"]
set SDC_FILE    [file normalize "synth_out/rv32im_asic.sdc"]

# Timing
set CLK_PERIOD_NS 10.0  
set IO_DELAY_NS   1.0

# Output directories
set RESULT_DIR [file normalize "results"]
set REPORT_DIR [file normalize "reports"]
file mkdir $RESULT_DIR
file mkdir $REPORT_DIR

 
# Step 1: Read
 
puts "\n=== {1/11} Reading technology files ==="
set STD_TLEF  "$TECH_DIR/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef"
set STD_LEF   "$TECH_DIR/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set SRAM_LEF  "$TECH_DIR/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef"
set STD_LIB   "$TECH_DIR/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
set SRAM_LIB  "$TECH_DIR/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_8x1024_8_TT_1p8V_25C.lib"

if {![file exists $STD_TLEF]} { utl::error FLOW 1 "Tech LEF not found: $STD_TLEF" }
if {![file exists $STD_LEF]}  { utl::error FLOW 2 "Std cell LEF not found: $STD_LEF" }
if {![file exists $STD_LIB]}  { utl::error FLOW 3 "Liberty not found: $STD_LIB" }
if {![file exists $SRAM_LEF]} { utl::error FLOW 4 "SRAM macro LEF not found: $SRAM_LEF" }
if {![file exists $SRAM_LIB]} { utl::error FLOW 5 "SRAM liberty not found: $SRAM_LIB" }

read_lef $STD_TLEF
read_lef $STD_LEF
read_lef $SRAM_LEF
read_liberty $STD_LIB
read_liberty $SRAM_LIB

 
# Step 2: Read netlist + link
 
puts "\n=== {2/11} Reading netlist ==="
if {![file exists $NETLIST]} { utl::error FLOW 6 "Netlist not found: $NETLIST" }
read_verilog $NETLIST

link_design $DESIGN

set_wire_rc -signal -layer met2
set_wire_rc -clock  -layer met3


foreach const_net [list one_ zero_] {
    if {[llength [get_nets $const_net]] > 0} {
        delete_net $const_net
        puts "Removed constant net: $const_net"
    }
}

 
# Step 3: Constraints
 
puts "\n=== {3/11} Constraints ==="
if {[file exists $SDC_FILE]} {
    puts "Reading SDC: $SDC_FILE"
    read_sdc $SDC_FILE
} else {
    puts "No SDC found ($SDC_FILE) - creating default ${CLK_PERIOD_NS} ns clock"
    create_clock -name clk -period $CLK_PERIOD_NS [get_ports clk]
    set_input_delay  -clock clk $IO_DELAY_NS [get_ports rst]
    set_output_delay -clock clk $IO_DELAY_NS [get_ports {commit_valid commit_rd commit_data}]
    set_false_path -from [get_ports rst]
}

 
# Step 4: Floorplan + macro placement
 
puts "\n=== {4/11} Floorplan + macro placement ==="
initialize_floorplan -die_area {0 0 1250 1200} -core_area {10 10 1240 1190} -site unithd

make_tracks

set block [ord::get_db_block]
set units [$block getDefUnits]

proc place_macro {block units name x_um y_um} {
    set inst [$block findInst $name]
    if {$inst == "NULL"} {
        puts "ERROR: instance $name not found"
        return
    }
    $inst setOrient "R0"
    $inst setLocation [expr {int($x_um * $units)}] [expr {int($y_um * $units)}]
    $inst setPlacementStatus "FIRM"
}
proc add_macro_halo {block units inst_name halo_um} {
    set inst [$block findInst $inst_name]
    if {$inst == "NULL"} { return }
    set halo_dbu [expr {int($halo_um * $units)}]
    $inst setHalo $halo_dbu $halo_dbu $halo_dbu $halo_dbu
}

place_macro $block $units {u_rv32im_top.u_data_memory.byte_lane\[0\].u_sram_lane} 50  50
place_macro $block $units {u_rv32im_top.u_data_memory.byte_lane\[1\].u_sram_lane} 650 50
place_macro $block $units {u_rv32im_top.u_data_memory.byte_lane\[2\].u_sram_lane} 50  650
place_macro $block $units {u_rv32im_top.u_data_memory.byte_lane\[3\].u_sram_lane} 650 650

foreach macro {
    u_rv32im_top.u_data_memory.byte_lane\[0\].u_sram_lane
    u_rv32im_top.u_data_memory.byte_lane\[1\].u_sram_lane
    u_rv32im_top.u_data_memory.byte_lane\[2\].u_sram_lane
    u_rv32im_top.u_data_memory.byte_lane\[3\].u_sram_lane
} {
    add_macro_halo $block $units $macro 8.0
}

 
# Step 5: Power distribution network
 
puts "\n=== {5/11} Power grid (PDN) ==="
add_global_connection -net VDD -pin_pattern "^VPWR$"  -power
add_global_connection -net VDD -pin_pattern "^VPB$"   -power
add_global_connection -net VDD -pin_pattern "^vccd1$" -power
add_global_connection -net VSS -pin_pattern "^VGND$"  -ground
add_global_connection -net VSS -pin_pattern "^VNB$"   -ground
add_global_connection -net VSS -pin_pattern "^vssd1$" -ground

global_connect

set_voltage_domain -power VDD -ground VSS
define_pdn_grid -name "core_grid" -voltage_domains {CORE}

add_pdn_stripe -grid "core_grid" -layer met1 -width 0.48 -followpins
add_pdn_stripe -grid "core_grid" -layer met4 -width 1.6 -pitch 27.2 -offset 15.5
add_pdn_stripe -grid "core_grid" -layer met5 -width 1.6 -pitch 27.2 -offset 15.5
add_pdn_connect -grid "core_grid" -layers {met1 met4}
add_pdn_connect -grid "core_grid" -layers {met4 met5}

define_pdn_grid -name "macro_grid" -macro -default -voltage_domains {CORE} -orient {R0 R180 MX MY}
add_pdn_connect -grid "macro_grid" -layers {met4 met5}

pdngen

tapcell \
  -tapcell_master "sky130_fd_sc_hd__tapvpwrvgnd_1" \
  -endcap_master "sky130_fd_sc_hd__decap_3" \
  -distance 14

place_pins -hor_layers met3 -ver_layers met2

 
# Step 6: Placement
 
puts "\n=== {6/11} Global placement ==="
global_placement -density 0.35
detailed_placement

set_max_fanout 32 [current_design]
repair_design

puts "\n=== {7/11} Detailed placement ==="
detailed_placement

 
# Step 7: Clock tree synthesis
 
puts "\n=== {8/11} Clock tree synthesis ==="
clock_tree_synthesis -root_buf sky130_fd_sc_hd__clkbuf_4 \
  -buf_list {sky130_fd_sc_hd__clkbuf_1 sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4} \
  -sink_clustering_enable

detailed_placement

estimate_parasitics -placement
repair_timing -setup -setup_margin 0.2

detailed_placement

 
# Step 8: Routing

set_routing_layers -signal met1-met5

puts "\n=== {9/11} Global routing ==="
global_route

puts "\n=== {10/11} Detailed routing ==="
detailed_route -output_drc drc.rpt

 
# Step 9: Write outputs + reports
 
puts "\n=== {11/11} Writing outputs + reports ==="
set DEF_FILE  [file join $RESULT_DIR ${DESIGN}.def]
set VERILOG   [file join $RESULT_DIR ${DESIGN}_route.v]
set SDC_OUT   [file join $RESULT_DIR ${DESIGN}.sdc]
set DB_FILE   [file join $RESULT_DIR ${DESIGN}.db]
set REP_TIMING [file join $REPORT_DIR ${DESIGN}_timing.rpt]
set REP_AREA   [file join $REPORT_DIR ${DESIGN}_area.rpt]
set REP_POWER  [file join $REPORT_DIR ${DESIGN}_power.rpt]

report_checks -path_delay max -format full > $REP_TIMING
report_checks -path_delay min -format full >> $REP_TIMING
report_design_area > $REP_AREA
report_power > $REP_POWER

write_def $DEF_FILE
write_verilog $VERILOG
write_sdc $SDC_OUT
write_db $DB_FILE

puts "  DEF:      $DEF_FILE"
puts "  Netlist:  $VERILOG"
puts "  SDC:      $SDC_OUT"
puts "  DB:       $DB_FILE"
puts "  Timing:   $REP_TIMING"
puts "  Area:     $REP_AREA"
puts "  Power:    $REP_POWER"
puts "  DRC:      drc.rpt"

puts "\n=== FLOW COMPLETE ==="