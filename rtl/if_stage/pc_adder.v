module pc_adder (
    input      [31:0] pc_n,
    output reg [31:0] pc_plus4_o
);
    always @(*) begin
        pc_plus4_o = pc_n + 4;
    end
endmodule
