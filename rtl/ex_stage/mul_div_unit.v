module mul_div_unit (
    input              clk,
    input              rst,
    input       [31:0] operand_a,
    input       [31:0] operand_b,
    input       [2:0]  op,
    input              start,
    input              abort,
    output reg  [31:0] result,
    output reg         busy,
    output reg         done
);

    localparam MUL    = 3'b000;
    localparam MULH   = 3'b001;
    localparam MULHSU = 3'b010;
    localparam MULHU  = 3'b011;
    localparam DIV    = 3'b100;
    localparam DIVU   = 3'b101;
    localparam REM    = 3'b110;
    localparam REMU   = 3'b111;

    // FSM state
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE    = 2'b10;

    reg [1:0] state;
    reg [5:0] counter;
    reg [2:0] op_r;

    reg        result_neg_mul;
    reg        dividend_neg;
    reg        divisor_neg;
    reg        div_by_zero;
    reg        signed_overflow;

    reg [31:0] divisor_u;
    reg [31:0] dividend_u;
    reg [63:0] macc;

    // 1. Sign Extraction & Absolute Values
    wire a_is_signed = (op == MUL || op == MULH || op == MULHSU || op == DIV || op == REM);
    wire b_is_signed = (op == MUL || op == MULH || op == DIV || op == REM);
    
    wire a_neg = a_is_signed & operand_a[31];
    wire b_neg = b_is_signed & operand_b[31];
    
    wire [31:0] abs_a = a_neg ? (~operand_a + 1'b1) : operand_a;
    wire [31:0] abs_b = b_neg ? (~operand_b + 1'b1) : operand_b;

    // 2. Multiply Combinatorial Logic
    wire [32:0] part_sum  = {1'b0, macc[63:32]} + {1'b0, divisor_u};
    wire [63:0] final_mul = result_neg_mul ? (~macc + 1'b1) : macc;

    // 3. Divide Combinatorial Logic
    wire [63:0] shifted = {macc[62:0], 1'b0};
    wire [32:0] diff    = {1'b0, shifted[63:32]} - {1'b0, divisor_u};

    // 4. Edge Case Detection
    wire is_div_zero = (operand_b == 32'b0);
    wire is_overflow = ((op == DIV || op == REM) && 
                        (operand_a == 32'h8000_0000) && (operand_b == 32'hFFFF_FFFF));
    
    always @(posedge clk or posedge rst) begin
        if (rst || abort) begin
            state   <= IDLE;
            busy    <= 1'b0;
            done    <= 1'b0;
            counter <= 6'h0;
            result  <= 32'h0;
        end else begin
            case (state)

            IDLE : begin
                done <= 1'b0;
                if (start) begin
                    op_r            <= op;
                    counter         <= 6'h0;
                    busy            <= 1'b1;

                    // Load pre-calculated combinatorial values into registers
                    dividend_u      <= abs_a;
                    divisor_u       <= abs_b;
                    result_neg_mul  <= a_neg ^ b_neg; 
                    dividend_neg    <= a_neg;
                    divisor_neg     <= b_neg;
                    div_by_zero     <= is_div_zero;
                    signed_overflow <= is_overflow;
                    macc            <= {32'b0, abs_a};
                    state           <= COMPUTE;
                end
            end

            COMPUTE : begin
                if (!op_r[2]) begin
                    //Multiply
                    if (macc[0]) begin
                        macc <= { part_sum, macc[31:1] };
                    end else begin
                        macc <= { 1'b0, macc[63:32], macc[31:1] }; 
                    end
                end else begin
                    //Divide
                    if (!diff[32]) begin 
                        macc <= { diff[31:0], shifted[31:1], 1'b1 };
                    end else begin
                        macc <= shifted;
                    end
                end

                // Cycle Tracking
                if (counter == 6'd31) begin
                    state <= DONE;
                end else begin
                    counter <= counter + 1'b1;
                end
            end

            DONE: begin
                busy  <= 1'b0;
                done  <= 1'b1;
                state <= IDLE;

                if (!op_r[2]) begin
                    //multiply result
                    case (op_r)
                        MUL:     result <= final_mul[31:0];
                        default: result <= final_mul[63:32]; // MULH, MULHSU, MULHU
                    endcase
                end else begin
                    //divide result
                    if (div_by_zero) begin
                        result <= (op_r == DIV || op_r == DIVU) ? 32'hFFFF_FFFF
                                    : (dividend_neg ? (~dividend_u + 1'b1) : dividend_u);
                    end else if (signed_overflow) begin
                        result <= (op_r == DIV) ? 32'h8000_0000 : 32'b0;
                    end else begin
                        // macc[31:0]  = Quotient
                        // macc[63:32] = Remainder
                        case (op_r)
                            DIV:  result <= (dividend_neg ^ divisor_neg) ? (~macc[31:0] + 1'b1)  : macc[31:0];
                            DIVU: result <= macc[31:0];
                            REM:  result <= dividend_neg                 ? (~macc[63:32] + 1'b1) : macc[63:32];
                            REMU: result <= macc[63:32];
                        endcase
                    end
                end
            end

            endcase
        end
    end
endmodule