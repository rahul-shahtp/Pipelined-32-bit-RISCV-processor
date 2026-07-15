module alu_control (
    input      [1:0] ALUopCode,
    input      [2:0] funct3,
    input            funct7_5thBIT,
    input            is_mul_div,
    output reg [3:0] alu_op
);

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin

        if (is_mul_div) begin
            alu_op = ALU_ADD;
        end else begin

            case (ALUopCode)

            2'b00 : alu_op = ALU_ADD;

            2'b01 : alu_op = ALU_SUB;

            2'b10 : begin
                case (funct3)
                    
                    3'b000: alu_op = (funct7_5thBIT) ? ALU_SUB : ALU_ADD; 
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7_5thBIT) ? ALU_SRA : ALU_SRL; 
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;

                    default: alu_op = ALU_ADD;

                endcase
            end

            default : alu_op = ALU_ADD;
            
            endcase
        end
    end

endmodule

