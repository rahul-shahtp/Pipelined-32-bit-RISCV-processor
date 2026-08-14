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
    //for RTL simulation and testbench memory initialization.
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
    // Four SkyWater 1 Kbyte 1RW1R macros (8 bits each) build the 1024 x 32
    wire [31:0] q_lanes;

    genvar g;
    generate
        for (g = 0; g < 4; g = g + 1) begin : byte_lane
            sky130_sram_1kbyte_1rw1r_8x1024_8 u_sram_lane (
                .CLK0(clk),
                .CEN0(~(MemRead | MemWrite)),  // chip enable, active low
                .WEN0(~MemWrite),              // write enable, active low
                .WMASKO(write_mask[g]),
                .A0(word_address),
                .D(write_data[g*8 +: 8]),
                .Q(q_lanes[g*8 +: 8]),
                .CLK1(clk),
                .CEN1(1'b1),                   // second port unused
                .A1(10'b0),
                .Q1(),
                .ABIST_CLK0(1'b0),             // BIST test pins tied off
                .ABIST_WA0(1'b0),
                .ABIST_WEN0(1'b0),
                .ABIST_WDATA0(1'b0),
                .ABIST_WMASK0(1'b0),
                .ABIST_RDATA0()
            );
        end
    endgenerate

    assign word_data = q_lanes;
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
