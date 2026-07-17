module rv32im_top (
    input clk,
    input rst,
);

    // IF-STAGE

    // pc reg
    wire [31:0] pc_in
    wire [31:0] pc_out;
    wire [31:0] pc_plus4_o;
    wire [31:0] pc_next;
    wire [31:0] instruction_o;
    wire [31:0] pc_plus4_n;
    wire [31:0] instruction_n;
    wire        branch_taken;
    wire        jump_taken;
    wire        pc_if_stall;
    wire        flush;


    // Module instan

    pc_reg PC_REG (
        .clk(clk),
        .rst(rst),
        .pc_if_stall(pc_if_stall),
    )

