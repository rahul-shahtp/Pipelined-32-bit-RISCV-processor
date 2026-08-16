//sky130_sram_1kbyte_1rw1r_8x1024_8   (1 Kbyte, 1RW1R, 8-bit x 1024)
//Pin names and directions MUST match the macro LEF:
//sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef
//
// LEF pins: addr0[9:0] addr1[9:0] din0[7:0] dout0[7:0] dout1[7:0]
//           csb0 csb1 web0 clk0 clk1 wmask0 vccd1 vssd1
// Yosys keeps this module as a blackbox; OpenROAD links the instances to
// the LEF macro during place & route.

(* blackbox *)
module sky130_sram_1kbyte_1rw1r_8x1024_8 (
    input         clk0,    // port 0 clock (access port)
    input         csb0,    // port 0 chip select, active low
    input         web0,    // port 0 write enable, active low
    input         wmask0,  // port 0 write mask (1 = write this word)
    input  [9:0]  addr0,   // port 0 address
    input  [7:0]  din0,    // port 0 write data
    output [7:0]  dout0,   // port 0 read data
    input         clk1,    // port 1 clock (read port, unused)
    input         csb1,    // port 1 chip select, active low (tied inactive)
    input  [9:0]  addr1,   // port 1 address
    output [7:0]  dout1,   // port 1 read data (unused)
    input         vccd1,   // power  (connected via global net VDD)
    input         vssd1    // ground (connected via global net VSS)
);
endmodule