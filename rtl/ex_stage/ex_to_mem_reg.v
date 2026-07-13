module ex_to_mem_reg (
    input             clk,
    input             rst,
    input      [31:0] alu_result_ex,
    input      [31:0] rs2_data_ex,
    input      [4:0]  rd_ex,
    input             RegWrite_ex,
    input             MemRead_ex,
    input             MemWrite_ex,
    input             MemtoReg_ex,
    output reg [31:0] alu_result_mem,
    output reg [31:0] rs2_data_mem,
    output reg [4:0]  rd_mem,
    output reg        RegWrite_mem,
    output reg        MemRead_mem,
    output reg        MemWrite_mem,
    output reg        MemtoReg_mem

);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_mem <= 32'h0;
            rs2_data_mem   <= 32'h0;
            rd_mem         <= 5'h0;
            RegWrite_mem   <= 1'b0;
            MemRead_mem    <= 1'b0;
            MemWrite_mem   <= 1'b0;
            MemtoReg_mem   <= 1'b0;
        end

        else begin
            alu_result_mem <= alu_result_ex;
            rs2_data_mem   <= rs2_data_ex;
            rd_mem         <= rd_ex;
            RegWrite_mem   <= RegWrite_ex;
            MemRead_mem    <= MemRead_ex;
            MemWrite_mem   <= MemWrite_ex;
            MemtoReg_mem   <= MemtoReg_ex;
        end
    end

endmodule
