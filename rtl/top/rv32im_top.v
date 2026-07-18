module rv32im_top (
    input clk,
    input rst,
);

    // IF-STAGE


    wire [31:0] pc_if;
    wire [31:0] pc_next;
    wire        pc_if_stall;
    wire [31:0] pc_plus4_if;
    wire [31:0] branch_target_if;
    wire [31:0] jump_target_if;
    wire        branch_taken_if;
    wire        jump_taken_if;
    wire [31:0] address_if;
    wire [31:0] instruction_if;
    wire        flush;

    pc_reg u_pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_if_stall(pc_if_stall),
        .pc_in(pc_if),
        .pc_out(pc_next)
    );

    pc_adder u_pc_adder (
        .pc_n(pc_if),
        .pc_plus4_o(pc_plus4_if),
    );

    next_pc_mux u_next_pc_mux (
        .pc_plus4(pc_plus4_if),
        .branch_target(branch_target_if),
        .jump_target(jump_target_if),
        .branch_taken(branch_taken_if),
        .jump_taken(jump_taken_if),
        .pc_next(pc_next)
    );

    instr_mem u_instr_mem (
        .address_n(address_if),
        .instruction_o(instruction_if)
    );

    wire [31:0] pc_plus4_id;
    wire [21:0] instruction_id;

    if_to_id_reg u_if_to_id_reg (
        .clk(clk),
        .pc_if_stall(pc_if_stall),
        .rst(rst),
        .flush(flush),
        .pc_plus4_n(pc_plus4_if),
        .instruction_n(instruction_if),
        .pc_plus4_o(pc_plus4_id),
        instruction_o(instruction_id)
    );


    // ID STAGE

    

