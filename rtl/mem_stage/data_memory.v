module data_memory (
    input         clk,
    input  [31:0] address,
    input  [31:0] write_data,
    input  [2:0]  funct3,
    input         MemRead,
    input         MemWrite,
    output [31:0] read_data
);
    localparam F3_B  = 3'b000;
    localparam F3_H  = 3'b001;
    localparam F3_BU = 3'b100;
    localparam F3_HU = 3'b101;

    wire [9:0]  word_address = address[11:2];
    wire [3:0]  write_mask = (funct3 == F3_B) ? (4'b0001 << address[1:0]) :
                             (funct3 == F3_H) ? (address[1] ? 4'b1100 : 4'b0011) :
                             4'b1111;
    wire [31:0] word_data;

`ifndef SYNTHESIS
    // The CPU needs combinational load data in its existing MEM-stage timing.
    // Retain this model for RTL simulation and testbench memory initialization.
    reg [31:0] memory [0:1023];

    always @(posedge clk) begin
        if (MemWrite) begin
            if (write_mask[0]) memory[word_address][7:0]   <= write_data[7:0];
            if (write_mask[1]) memory[word_address][15:8]  <= write_data[15:8];
            if (write_mask[2]) memory[word_address][23:16] <= write_data[23:16];
            if (write_mask[3]) memory[word_address][31:24] <= write_data[31:24];
        end
    end

    assign word_data = memory[word_address];
`else
    // Exactly one 1024 x 32 macro.  wmask0 provides one write enable per byte.

     sky130_sram_1024x32 u_data_sram (
        .clk0(clk),
        .csb0(~(MemRead | MemWrite)),
        .web0(~MemWrite),
        .wmask0(write_mask),
        .addr0(word_address),
        .din0(write_data),
        .dout0(word_data),
        .clk1(clk),
        .csb1(1'b1),
        .addr1(10'b0),
        .dout1()
    );
`endif

    wire [7:0]  byte_data = (address[1:0] == 2'b00) ? word_data[7:0]   :
                            (address[1:0] == 2'b01) ? word_data[15:8]  :
                            (address[1:0] == 2'b10) ? word_data[23:16] :
                                                     word_data[31:24];
    wire [15:0] half_data = address[1] ? word_data[31:16] : word_data[15:0];

    reg [31:0] read_data_r;
    always @(*) begin
        if (!MemRead) read_data_r = 32'h0;
        else case (funct3)
            F3_B:  read_data_r = {{24{byte_data[7]}}, byte_data};
            F3_H:  read_data_r = {{16{half_data[15]}}, half_data};
            F3_BU: read_data_r = {24'h0, byte_data};
            F3_HU: read_data_r = {16'h0, half_data};
            default: read_data_r = word_data;
        endcase
    end

    assign read_data = read_data_r;
endmodule
