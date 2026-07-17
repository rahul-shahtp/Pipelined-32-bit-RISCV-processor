module if_to_id_reg (
    input             clk,
    input             pc_if_stall,
    input             rst,
    input             flush,
    input      [31:0] pc_plus4_n,
    input      [31:0] instruction_n,
    output reg [31:0] pc_plus4_o,
    output reg [31:0] instruction_o
);
    localparam NOP = 32'h00000013; // addi x0, x0, 0

    always @(posedge clk_n or posedge rst) begin
        if (rst) begin
            pc_plus4_o    <= 32'b0;
            instruction_o <= NOP;
        end
        else if (flush) begin
            pc_plus4_o    <= 32'b0;
            instruction_o <= NOP;
        end
        else if (pc_if_stall) begin
            pc_plus4_o    <= pc_plus4_o;
            instruction_o <= instruction_o;
        end
        else  begin
            pc_plus4_o    <= pc_plus4_n;
            instruction_o <= instruction_n;
        end
    end
endmodule


