// ASIC-facing top level for the RV32IM pipeline.
//
// The processor's instruction and data memories are instantiated inside the
// core.  Its externally observable interface is therefore the architectural
// write-back (commit) stream, which can be connected to pads, a trace block,
// or a test harness without relying on hierarchical references.
module rv32im_asic (
    input         clk,
    input         rst,
    output        commit_valid,
    output [4:0]  commit_rd,
    output [31:0] commit_data
);

    rv32im_top u_rv32im_top (
        .clk(clk),
        .rst(rst),
        .commit_valid(commit_valid),
        .commit_rd(commit_rd),
        .commit_data(commit_data)
    );

endmodule
