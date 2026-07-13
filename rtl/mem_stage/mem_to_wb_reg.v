module mem_to_wb_reg (
    input             clk,
    input             rst,
    input      [31:0] alu_result_mem,
    input      [31:0] read_data_mem,
    input      [4:0]  rd_mem,
    input             RegWrite_mem,
    input             MemtoReg_mem,
    output reg [31:0] alu_result_wb,
    output reg [31:0] read_data_wb,
    output reg [4:0]  rd_wb,
    output reg        RegWrite_wb,
    output reg        MemtoReg_wb
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_result_wb <= 32'h0;
            read_data_wb  <= 32'h0;
            rd_wb         <= 5'h0;
            RegWrite_wb   <= 1'b0;
            MemtoReg_wb   <= 1'b0;
        end

        else begin
            alu_result_wb <= alu_result_mem;
            read_data_wb  <= read_data_mem;
            rd_wb         <= rd_mem;
            RegWrite_wb   <= RegWrite_mem;
            MemtoReg_wb   <= MemtoReg_mem;
        end
    end

endmodule