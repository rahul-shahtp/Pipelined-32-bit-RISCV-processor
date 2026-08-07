// Technology replacement point for the data RAM.
//
// Compile this file with the RTL and define SYNTHESIS for an ASIC synthesis
// build.  Replace this black box with the foundry/library SRAM macro during
// implementation.  The interface has an asynchronous read because the CPU's
// original behavioural data-memory model also has an asynchronous read.
 (* blackbox *)
module sram_1024x32 (
    input         clk,
    input  [9:0]  addr,
    input  [31:0] wdata,
    input         we,
    input  [3:0]  wmask,
    output [31:0] rdata
);
    reg [31:0] memory [0:1023];

    always @(posedge clk) begin
        if (we) begin
            if (wmask[0]) memory[addr][7:0]   <= wdata[7:0];
            if (wmask[1]) memory[addr][15:8]  <= wdata[15:8];
            if (wmask[2]) memory[addr][23:16] <= wdata[23:16];
            if (wmask[3]) memory[addr][31:24] <= wdata[31:24];
        end
    end

    assign rdata = memory[addr];
endmodule
