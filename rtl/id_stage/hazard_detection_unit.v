module hazard_detection_unit (
    input      [4:0] id_rs1,
    input      [4:0] id_rs2,
    input            id_branch,
    input      [4:0] ex_rd,
    input            ex_MemRead,
    input            ex_RegWrite,
    input      [4:0] mem_rd,
    input            mem_RegWrite,
    input            ex_is_mul_div,
    input            mul_div_done,
    output reg       pc_if_stall,
    output reg       hold,
    output reg       bubble
);

    wire load_use_hazard, branch_hazard, mul_div_hazard;

    assign load_use_hazard = ex_MemRead && (ex_rd != 5'b0) &&
                            ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    assign branch_hazard = id_branch &&
                        (
                          (ex_RegWrite  && (ex_rd  != 5'b0) && ((ex_rd  == id_rs1) || (ex_rd  == id_rs2))) ||
                          (mem_RegWrite && (mem_rd != 5'b0) && ((mem_rd == id_rs1) || (mem_rd == id_rs2)))
                        );

    assign mul_div_hazard = ex_is_mul_div  && (~mul_div_done);

    always @(*) begin
         pc_if_stall = load_use_hazard || branch_hazard || mul_div_hazard;
         bubble      = load_use_hazard || branch_hazard;
         hold        = mul_div_hazard;
    end            

endmodule


