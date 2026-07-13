module wb_mux (
    input  [31:0] alu_result_wb,
    input  [31:0] read_data_wb,
    input         MemtoReg_wb,
    output [31:0] write_data_wb
);

    assign write_data_wb = MemtoReg_wb ? read_data_wb : alu_result_wb;

endmodule