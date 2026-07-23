module data_memory (
    input         clk,
    input  [31:0] address,
    input  [31:0] write_data,
    input  [2:0]  funct3,
    input         MemRead,
    input         MemWrite,
    output [31:0] read_data
);
    localparam MAX_SIZE = 1024;

    localparam F3_B  = 3'b000;
    localparam F3_H  = 3'b001;
    localparam F3_W  = 3'b010;
    localparam F3_BU = 3'b100;
    localparam F3_HU = 3'b101;

    reg [31:0] memory [0:MAX_SIZE-1];
    reg [31:0] read_data_r;

    wire [31:0] word_data = memory[address[11:2]];
    wire [7:0]  byte_data = (address[1:0] == 2'b00) ? word_data[7:0]   :
                            (address[1:0] == 2'b01) ? word_data[15:8]  :
                            (address[1:0] == 2'b10) ? word_data[23:16] :
                                                     word_data[31:24];
    wire [15:0] half_data = address[1] ? word_data[31:16] : word_data[15:0];

    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                F3_B: begin
                    case (address[1:0])
                        2'b00: memory[address[11:2]][7:0]   <= write_data[7:0];
                        2'b01: memory[address[11:2]][15:8]  <= write_data[7:0];
                        2'b10: memory[address[11:2]][23:16] <= write_data[7:0];
                        2'b11: memory[address[11:2]][31:24] <= write_data[7:0];
                    endcase
                end
                F3_H: begin
                    if (!address[1]) begin
                        memory[address[11:2]][15:0] <= write_data[15:0];
                    end else begin
                        memory[address[11:2]][31:16] <= write_data[15:0];
                    end
                end
                default: begin
                    memory[address[11:2]] <= write_data;
                end
            endcase
        end
    end

    always @(*) begin
        if (!MemRead) begin
            read_data_r = 32'h0;
        end else begin
            case (funct3)
                F3_B:  read_data_r = {{24{byte_data[7]}}, byte_data};
                F3_H:  read_data_r = {{16{half_data[15]}}, half_data};
                F3_BU: read_data_r = {24'h0, byte_data};
                F3_HU: read_data_r = {16'h0, half_data};
                default: read_data_r = word_data;
            endcase
        end
    end

    assign read_data = read_data_r;


endmodule