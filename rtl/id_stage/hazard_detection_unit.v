module hazard_detection_unit (
    input      [4:0] id_rs1,
    input      [4:0] id_rs2,
    input      [4:0] ex_rd,
    input            ex_MemRead,
    output reg       stall
);

    always @(*) begin
        if (ex_MemRead && (ex_rd != 5'b0) && 
        ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
            stall = 1'b1;
        end

        else begin
            stall = 1'b0;
        end
    end

endmodule

