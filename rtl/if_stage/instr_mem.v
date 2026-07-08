module instr_mem (
    input  [31:0]  address,
    output [31:0]  instruction
);
    parameter MAX_SIZE = 1024 ;
    reg [31:0] memory [0:MAX_SIZE];

    initial begin
        $readmemh("docs/progeam.hex", memory);
    end

    assign instruction = memory[address[11:2]];

endmodule
