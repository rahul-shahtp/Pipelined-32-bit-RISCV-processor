//sky130_sram_1kbyte_1rw1r_8x1024_8   (1 Kbyte, 1RW1R, 8-bit x 1024)
//Pin names and directions MUST match the macro LEF:
//sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef
// Yosys keeps this module as a blackbox; OpenROAD links the instances to
// the LEF macro during place & route.

(* blackbox *)
module sky130_sram_1kbyte_1rw1r_8x1024_8 (
    input        CLK0,     // port 0 clock (write port)
    input        CEN0,     // chip enable, active low
    input        WEN0,     // write enable, active low
    input        WMASKO,   // write mask, 1 = write this byte
    input  [9:0] A0,       // port 0 address
    input  [7:0] D,        // port 0 write data
    output [7:0] Q,        // port 0 read data
    input        CLK1,     // port 1 clock (read port)
    input        CEN1,     // chip enable, active low
    input  [9:0] A1,       // port 1 address
    output [7:0] Q1,       // port 1 read data
    input        ABIST_CLK0,
    input        ABIST_WA0,
    input        ABIST_WEN0,
    input        ABIST_WDATA0,
    input        ABIST_WMASK0,
    output       ABIST_RDATA0
);
endmodule
