module alu (
    input      [31:0] operand_a,
    input      [31:0] operand_b,
    input      [3:0]  alu_op,
    output            zero,
    output reg [31:0] alu_result
);

    assign zero = (alu_result== 32'h0);

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0101;
    localparam SRL  = 4'b0110;
    localparam SRA  = 4'b0111;
    localparam SLT  = 4'b1000;
    localparam SLTU = 4'b1001;

    always @(*) begin
        case (alu_op)

            ADD  : alu_result = operand_a + operand_b;
            SUB  : alu_result = operand_a - operand_b;
            AND  : alu_result = operand_a & operand_b;
            OR   : alu_result = operand_a | operand_b;
            XOR  : alu_result = operand_a ^ operand_b;
            SLL  : alu_result = operand_a << operand_b[4:0];
            SRL  : alu_result = operand_a >> operand_b[4:0];
            SRA  : alu_result = $signed(operand_a) >>> operand_b[4:0];
            SLT  : alu_result = ($signed(operand_a) < $signed(operand_b)) ? 32'h1 : 32'h0;
            SLTU : alu_result = (operand_a < operand_b) ? 32'h1 : 32'h0;

            default : alu_result = 32'h0;
        endcase
    end
endmodule


