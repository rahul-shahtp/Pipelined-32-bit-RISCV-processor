module control_unit (
    input      [6:0] opcode,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       MemtoReg,
    output reg       ALUsrc,
    output reg       branch,
    output reg       jump,
    output reg [1:0] ALUopCode
);
    parameter OP_RTYPE  = 7'b0110011;
    parameter OP_ITYPE  = 7'b0010011;
    parameter OP_LOAD   = 7'b0000011;
    parameter OP_STORE  = 7'b0100011;
    parameter OP_BRANCH = 7'b1100011;
    parameter OP_JAL    = 7'b1101111;
    parameter OP_JALR   = 7'b1100111;
    parameter OP_LUI    = 7'b0110111;
    parameter OP_AUIPC  = 7'b0010111;

    always @(*) begin
        RegWrite  = 1'b0;
        MemRead   = 1'b0;
        MemWrite  = 1'b0;
        MemtoReg  = 1'b0;
        ALUsrc    = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        ALUopCode = 2'b00;

        case (opcode)
            OP_RTYPE : begin
                RegWrite  = 1'b1;
                ALUsrc    = 1'b0;
                ALUopCode = 2'b10;
            end

            OP_ITYPE : begin
                RegWrite  = 1'b1;
                ALUsrc    = 1'b1;
                ALUopCode = 2'b10;
            end

            OP_LOAD : begin
                RegWrite  = 1'b1;
                MemRead   = 1'b1;
                MemtoReg  = 1'b1;
                ALUsrc    = 1'b1;
                ALUopCode = 2'b00;
            end

            OP_STORE : begin
                MemWrite  = 1'b1;
                ALUsrc    = 1'b1;
                ALUopCode = 2'b00;
            end

            OP_BRANCH : begin
                branch    = 1'b1;
                ALUsrc    = 1'b0;
                ALUopCode = 2'b01;
            end

            OP_JAL : begin
                RegWrite  = 1'b1;
                jump      = 1'b1;
            end

            OP_JALR : begin
                RegWrite  = 1'b1;
                jump      = 1'b1;
                ALUsrc    = 1'b1;
            end

            OP_LUI : begin
                RegWrite  = 1'b1;
                ALUsrc    = 1'b1;
            end

            OP_AUIPC : begin
                RegWrite  = 1'b1;
                ALUsrc    = 1'b1;
            end

            default : begin
            end
        endcase
    end
endmodule

