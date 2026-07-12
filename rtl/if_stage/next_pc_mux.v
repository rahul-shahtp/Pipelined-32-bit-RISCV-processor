module next_pc_mux (
    input      [31:0] pc_plus4,
    input      [31:0] branch_target,
    input      [31:0] jump_target,
    input             branch_taken,
    input             jump_taken,
    output reg [31:0] pc_next
);

    always @(*) begin
        if (branch_taken)
            pc_next = branch_target;
        else if (jump_taken)
            pc_next = jump_target;
        else
            pc_next = pc_plus4;
    end
    
endmodule