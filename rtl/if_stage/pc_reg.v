module pc_reg (
    input             clk,
    input             rst,
    input             pc_if_stall,
    input      [31:0] pc_in,
    output reg [31:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h00;
        end else if (!pc_if_stall) begin
            pc_out <= pc_in;
        end
    end
endmodule
