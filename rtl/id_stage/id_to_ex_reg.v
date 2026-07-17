module id_to_ex_reg (
    input             clk,
    input             rst,
    input             bubble,
    input             hold,
    input             flush,

    //data from ID stage

    input      [31:0] pc_id,
    input      [31:0] pc_plus4_id,
    input      [4:0]  rs1_id,
    input      [4:0]  rs2_id,
    input      [31:0] rs1_data_id,
    input      [31:0] rs2_data_id,
    input      [4:0]  rd_id,
    input      [31:0] imm_id,
    input      [2:0]  funct3_id,
    input             funct7_5thBIT_id,
    input             is_mul_div_id,
    input      [2:0]  mul_div_op_id,
    input      [6:0]  opcode_id,

    // control unit input 

    input              RegWrite_id,
    input              MemWrite_id,
    input              MemtoReg_id,
    input              ALUsrc_id,
    input              branch_id,
    input              jump_id,
    input              MemRead_id,
    input      [1:0]   ALUopCode_id,

    //output 
    output reg [31:0] pc_ex,
    output reg [31:0] pc_plus4_ex,
    output reg [4:0]  rs1_ex,
    output reg [4:0]  rs2_ex,
    output reg [31:0] rs1_data_ex,
    output reg [31:0] rs2_data_ex,
    output reg [4:0]  rd_ex,
    output reg [31:0] imm_ex,
    output reg [2:0]  funct3_ex,
    output reg        funct7_5thBIT_ex,
    output reg        is_mul_div_ex,
    output reg [2:0]  mul_div_op_ex,

    output reg        RegWrite_ex,
    output reg        MemWrite_ex,
    output reg        MemtoReg_ex,
    output reg        ALUsrc_ex,
    output reg        branch_ex,
    output reg        jump_ex,
    output reg        MemRead_ex,
    output reg [1:0]  ALUopCode_ex,
    output reg [6:0]  opcode_ex

);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_ex            <= 32'h0;
            pc_plus4_ex      <= 32'h0;
            rs1_ex           <= 5'h0;
            rs2_ex           <= 5'h0;
            rs1_data_ex      <= 32'h0;
            rs2_data_ex      <= 32'h0;
            rd_ex            <= 5'h0;
            imm_ex           <= 32'h0;
            funct3_ex        <= 3'h0;
            funct7_5thBIT_ex <= 1'b0;
            mul_div_op_ex    <= 3'h0;
            is_mul_div_ex    <= 1'b0;

            RegWrite_ex      <= 1'b0;
            MemWrite_ex      <= 1'b0;
            MemtoReg_ex      <= 1'b0;
            ALUsrc_ex        <= 1'b0;
            branch_ex        <= 1'b0;
            jump_ex          <= 1'b0;
            MemRead_ex       <= 1'b0;
            ALUopCode_ex     <= 2'b00;
            opcode_ex       <= 7'h0;
        end

        else if (flush) begin
            pc_ex            <= 32'h0;
            pc_plus4_ex      <= 32'h0;
            rs1_ex           <= 5'h0;
            rs2_ex           <= 5'h0;
            rs1_data_ex      <= 32'h0;
            rs2_data_ex      <= 32'h0;
            rd_ex            <= 5'h0;
            imm_ex           <= 32'h0;
            funct3_ex        <= 3'h0;
            funct7_5thBIT_ex <= 1'b0;
            is_mul_div_ex    <= 1'b0;
            mul_div_op_ex    <= 3'h0;

            RegWrite_ex      <= 1'b0;
            MemWrite_ex      <= 1'b0;
            MemtoReg_ex      <= 1'b0;
            ALUsrc_ex        <= 1'b0;
            branch_ex        <= 1'b0;
            jump_ex          <= 1'b0;
            MemRead_ex       <= 1'b0;
            ALUopCode_ex     <= 2'b00;
            opcode_ex       <= 7'h0;
            
        end

        else if (hold) begin
            pc_ex            <= pc_ex;
            pc_plus4_ex      <= pc_plus4_ex;
            rs1_ex           <= rs1_ex;
            rs2_ex           <= rs2_ex;
            rs1_data_ex      <= rs1_data_ex;
            rs2_data_ex      <= rs2_data_ex;
            rd_ex            <= rd_ex;
            imm_ex           <= imm_ex;
            funct3_ex        <= funct3_ex;
            funct7_5thBIT_ex <= funct7_5thBIT_ex;
            is_mul_div_ex    <= is_mul_div_ex;
            mul_div_op_ex    <= mul_div_op_ex;

            RegWrite_ex      <= RegWrite_ex;
            MemWrite_ex      <= MemWrite_ex;
            MemtoReg_ex      <= MemtoReg_ex;
            ALUsrc_ex        <= ALUsrc_ex;
            branch_ex        <= branch_ex; 
            jump_ex          <= jump_ex;    
            MemRead_ex       <= MemRead_ex; 
            ALUopCode_ex     <= ALUopCode_ex;
            opcode_ex        <= opcode_ex;
        end

        else if (bubble) begin
            pc_ex            <= pc_id;
            pc_plus4_ex      <= pc_plus4_id;
            rs1_ex           <= rs1_id;
            rs2_ex           <= rs2_id;
            rs1_data_ex      <= rs1_data_id;
            rs2_data_ex      <= rs2_data_id;
            rd_ex            <= rd_id;
            imm_ex           <= imm_id;
            funct3_ex        <= funct3_id;
            funct7_5thBIT_ex <= funct7_5thBIT_id;
            is_mul_div_ex    <= 1'b0;
            mul_div_op_ex    <= 3'h0;

            RegWrite_ex      <= 1'b0;
            MemWrite_ex      <= 1'b0;
            MemtoReg_ex      <= 1'b0;
            ALUsrc_ex        <= 1'b0;
            branch_ex        <= 1'b0;
            jump_ex          <= 1'b0;
            MemRead_ex       <= 1'b0;
            ALUopCode_ex     <= 2'b00;
            opcode_ex       <= 7'h0;
            
        end

        else begin
            pc_ex            <= pc_id;
            pc_plus4_ex      <= pc_plus4_id;
            rs1_ex           <= rs1_id;
            rs2_ex           <= rs2_id;
            rs1_data_ex      <= rs1_data_id;
            rs2_data_ex      <= rs2_data_id;
            rd_ex            <= rd_id;
            imm_ex           <= imm_id;
            funct3_ex        <= funct3_id;
            funct7_5thBIT_ex <= funct7_5thBIT_id;
            is_mul_div_ex    <= is_mul_div_id;
            mul_div_op_ex    <= mul_div_op_id;

            RegWrite_ex      <= RegWrite_id;
            MemWrite_ex      <= MemWrite_id;
            MemtoReg_ex      <= MemtoReg_id;
            ALUsrc_ex        <= ALUsrc_id;
            branch_ex        <= branch_id;
            jump_ex          <= jump_id;
            MemRead_ex       <= MemRead_id;
            ALUopCode_ex     <= ALUopCode_id;
            opcode_ex        <= opcode_id;
        end
    end

endmodule
