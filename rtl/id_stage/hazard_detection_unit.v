module hazard_detection_unit (
    input      [4:0] id_rs1,
    input      [4:0] id_rs2,
    input            id_branch,
    input      [4:0] ex_rd,
    input            ex_MemRead,
    input            ex_RegWrite,
    input      [4:0] mem_rd,
    input            mem_RegWrite,
    output reg       stall
);

    wire load_use_hazard, branch_hazard;

    assign load_use_hazard = ex_MemRead && (ex_rd != 5'b0) &&
                            ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    assign branch_hazard = id_branch &&
                        (
                          (ex_RegWrite  && (ex_rd  != 5'b0) && ((ex_rd  == id_rs1) || (ex_rd  == id_rs2))) ||
                          (mem_RegWrite && (mem_rd != 5'b0) && ((mem_rd == id_rs1) || (mem_rd == id_rs2)))
                        );

    always @(*) begin
         stall = load_use_hazard || branch_hazard;
    end            

endmodule


