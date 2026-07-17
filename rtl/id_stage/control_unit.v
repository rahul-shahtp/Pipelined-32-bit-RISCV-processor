module control_unit (
    input      [6:0] opcode,
    input      [2:0] funct3,
    input      [6:0] funct7,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       MemtoReg,
    output reg       ALUsrc,
    output reg       branch,
    output reg       jump,
    output reg       is_mul_div,
    output reg [2:0] mul_div_op,
    output reg [1:0] ALUopCode
);
    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;

    always @(*) begin
        RegWrite   = 1'b0;
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        MemtoReg   = 1'b0;
        ALUsrc     = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        ALUopCode  = 2'h0;
        is_mul_div = 1'b0;
        mul_div_op = 3'h0;

        case (opcode)
            OP_RTYPE : begin
                RegWrite  = 1'b1;
                ALUsrc    = 1'b0;
                ALUopCode = 2'b10;

                if (funct7 == 7'b0000001) begin
                    is_mul_div = 1'b1;
                    mul_div_op = funct3;
                end
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
