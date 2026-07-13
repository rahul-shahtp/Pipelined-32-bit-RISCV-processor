module data_memory (
    input         clk,
    input  [31:0] address,
    input  [31:0] write_data,
    input         MemRead,
    input         MemWrite,
    output [31:0] read_data
);
    localparam MAX_SIZE = 1024;

    reg [31:0] memory [0:MAX_SIZE-1];

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address[11:2]] <= write_data;
        end
    end

    assign read_data = memory[address[11:2]];


endmodule