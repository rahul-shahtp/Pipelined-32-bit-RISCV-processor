module pc_reg (
    input             clk,
    input             rst,
    input             stall,
    input      [31:0] pc_in,
    output reg [31:0] pc_out
);

    always

