module register_file (
    input             clk,
    input             rst,
    input      [4:0]  rs1_addr,
    input      [4:0]  rs2_addr,
    input      [4:0]  rd_addr,
    input      [31:0] rd_data,
    input             RegWrite,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);

    reg [31:0] register [0:31];

    // register 0 is hardwired to zero
    always @(*) begin
        rs1_data = (rs1_addr == 5'b0) ? 32'h0 : register[rs1_addr];
        rs2_data = (rs2_addr == 5'b0) ? 32'h0 : register[rs2_addr];
    end

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0 ; i < 32 ; i = i + 1) begin
                register[i]   <= 32'h0;
            end
        end
        else if (RegWrite && (rd_addr != 5'b0)) begin
            register[rd_addr] <= rd_data;
        end
    end

endmodule
