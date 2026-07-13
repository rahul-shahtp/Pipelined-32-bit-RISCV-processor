module forwarding_unit (
    input      [4:0] id_ex_rs1,
    input      [4:0] id_ex_rs2,
    input      [4:0] ex_mem_rd,
    input            ex_mem_RegWrite,
    input      [4:0] mem_wb_rd,
    input            mem_wb_RegWrite,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    localparam NO_FORWARDING = 2'b00;
    localparam FORWARDING_MEM_TO_WB = 2'b01;
    localparam FORWARDING_EX_TO_MEM = 2'b10;

    always @(*) begin
        
        if ((ex_mem_RegWrite && ex_mem_rd != 0) &&
            (ex_mem_rd == id_ex_rs1)) begin

                forward_a = FORWARDING_EX_TO_MEM;
            end
        else if ((mem_wb_RegWrite && mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs1)) begin
                    
                    forward_a = FORWARDING_MEM_TO_WB;
                 end
        else 
            forward_a = NO_FORWARDING;


        if ((ex_mem_RegWrite && ex_mem_rd != 0) &&
            (ex_mem_rd == id_ex_rs2)) begin

                forward_b = FORWARDING_EX_TO_MEM;
            end
        else if ((mem_wb_RegWrite && mem_wb_rd != 0) &&
                 (mem_wb_rd == id_ex_rs2)) begin
                    
                    forward_b = FORWARDING_MEM_TO_WB;
                 end
        else 
            forward_b = NO_FORWARDING;


    end

endmodule
