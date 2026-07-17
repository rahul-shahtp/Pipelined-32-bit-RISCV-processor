module branch_unit (
    input      [31:0] rs1_data,
    input      [31:0] rs2_data,
    input      [2:0]  funct3,
    input             branch,
    input      [31:0] pc,
    input      [31:0] imm,
    output reg        branch_taken,
    output     [31:0] branch_target
);

    localparam BEQ  = 3'b000;
    localparam BNE  = 3'b001;
    localparam BLT  = 3'b100;
    localparam BGE  = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;

    always @(*) begin
        branch_taken = 1'b0;
        if (branch) begin
            case (funct3)
                BEQ  : branch_taken  = (rs1_data == rs2_data);
                BNE  : branch_taken  = (rs1_data != rs2_data);
                BLT  : branch_taken  = ($signed(rs1_data) < $signed(rs2_data));
                BGE  : branch_taken  = ($signed(rs1_data) >= $signed(rs2_data));
                BLTU : branch_taken  = (rs1_data < rs2_data);
                BGEU : branch_taken  = (rs1_data >= rs2_data);

                default : branch_taken = 1'b0;
            endcase
        end
    end

    assign branch_target = pc + imm ;

endmodule
