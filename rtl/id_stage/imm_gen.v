module imm_gen (
    input      [31:0] instruction,
    output reg [31:0] imm
);

    wire [6:0] opcode = instruction[6:0];

    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;


    always @(*) begin
        case (opcode) 
            
            OP_ITYPE , OP_LOAD , OP_JALR : begin
                imm = {{20{instruction[31]}} , instruction[31:20]};
            end

            OP_STORE : begin
                imm = {{20{instruction[31]}} , instruction[31:25] , instruction[11:7]};
            end

            OP_BRANCH : begin
                imm = {{19{instruction[31]}} , instruction[31] , instruction[7] ,
                 instruction[30:25] , instruction[11:8] , 1'b0};
            end

            OP_JAL : begin
                imm = {{11{instruction[31]}} , instruction[31] , instruction[19:12] , 
                instruction[20] , instruction[30:21], 1'b0};
            end

            OP_LUI , OP_AUIPC : begin
                imm = {instruction[31:12] , 12'b0};
            end

            default : begin
                imm = 32'h0;
            end
        endcase
    end    
endmodule
