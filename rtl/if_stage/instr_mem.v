module instr_mem (
    input  [31:0] address_n,
    output [31:0] instruction_o
);
    localparam MAX_SIZE = 1024 ;
    reg [31:0] memory [0:MAX_SIZE-1];

    initial begin
        $readmemh("instruction.hex", memory);
    end

    assign instruction_o = memory[address_n[11:2]];

endmodule
