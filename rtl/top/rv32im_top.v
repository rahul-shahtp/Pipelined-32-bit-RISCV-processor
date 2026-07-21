module rv32im_top (
    input clk,
    input rst,
);

    // IF-STAGE


    wire [31:0] pc_if;
    wire [31:0] pc_next;
    wire        pc_if_stall;
    wire [31:0] pc_plus4_if;
    wire [31:0] address_if;
    wire [31:0] instruction_if;
    wire        flush;

    wire [31:0] pc_plus4_id;
    wire [21:0] instruction_id;

    pc_reg u_pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_if_stall(pc_if_stall),
        .pc_in(pc_if),
        .pc_out(pc_next)
    );

    pc_adder u_pc_adder (
        .pc_n(pc_if),
        .pc_plus4_o(pc_plus4_if),
    );

    instr_mem u_instr_mem (
        .address_n(address_if),
        .instruction_o(instruction_if)
    );

    if_to_id_reg u_if_to_id_reg (
        .clk(clk),
        .pc_if_stall(pc_if_stall),
        .rst(rst),
        .flush(flush),
        .pc_plus4_n(pc_plus4_if),
        .instruction_n(instruction_if),
        .pc_plus4_o(pc_plus4_id),
        instruction_o(instruction_id)
    );


    // ID STAGE

    wire [6:0] opcode_id        = instruction[6:0];
    wire [4:0] rd_id            = instruction[11:7];
    wire [2:0] funct3_id        = instruction[14:12];
    wire [4:0] rs1_id           = instruction[19:15];
    wire [4:0] rs2_id           = instruction[24:20];
    wire [6:0] funct7_id        = instruction[31:25];
    wire       funct7_5thBIT_id = instruction_id[30];

    wire [31:0] rs1_data_id;
    wire [31:0] rs2_data_id;
    wire        RegWrite_id;
    wire        MemRead_id;
    wire        MemWrite_id;
    wire        MemtoReg_id;
    wire        ALUsrc_id;
    wire        branch_id;
    wire        jump_id;
    wire        is_mul_div_id;
    wire        mul_div_op_id;
    wire        ALUopCode_id;
    wire [31:0] imm_id;   

    wire [4:0]  rd_wb;
    wire [31:0] write_data_wb ;
    wire        RegWrite_wb;


    register_file u_register_file (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_id),
        .rs2_addr(rs2_id),
        .rd_addr(rd_wb),
        .rd_data(write_data_wb),
        .RegWrite(RegWrite_wb),
        .rs1_data(rs1_data_id),
        .rs2_data(rs2_data_id)
    )

    control_unit u_control_unit (
        .opcode(opcode_id),
        .funct3(funct3_id),
        .funct7(funct3_id),
        .RegWrite(RegWrite_id),
        .MemRead(MemRead_id),
        .MemWrite(MemWrite_id),
        .MemtoReg(MemtoReg_id),
        .ALUsrc(ALUsrc_id),
        .branch(branch_id),
        .jump(jump_id);
        .is_mul_div(is_mul_div_id);
        .mul_div_op(mul_div_op_id),
        .ALUopCode(ALUopCode_id)
    )

    imm_gen u_imm_gen(
        .instruction(instruction_id),
        .imm(imm_id)
    );

    branch_unit u_branch_unit (
        .rs1_data(rs1_data_id),
        .rs2_data(rs2_data_id),
        .funct3(funct3_id),
        .branch(branch_id),
        .pc(pc_id),
        .imm(imm_id),
        .branch_taken(branch_taken),
        .branch_target(branch_taken)
    );

    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire        branch_taken;
    wire        jump_taken;
    wire branch_like_id = branch_id || (jump_id && (opcode_id == OP_JALR));
    wire [31:0] pc_id     = pc_plus4_id - 32'd4;

    assign jump_taken = jump_id;
    assign jump_target = (opcode_id == OP_JALR)
                       ? ((rs1_data_id + imm_id) & 32'hFFFF_FFFE)
                       : (pc_id + imm_id);

    next_pc_mux u_next_pc_mux (
        .pc_plus4(pc_plus4_if),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .pc_next(pc_next)
    );

    wire hold;
    wire bubble;
    wire [4:0] rs1_ex;
    wire [4:0] rs2_ex;
    wire [4:0] rd_ex;
    wire [4:0] rd_mem;
    wire mem_RegWrite;
    wire ex_MemRead;
    wire [31:0] alu_result_mem;
    wire mem_MemRead;
    wire ex_is_mul_div;
    wire mul_div_busy;
    wire mul_div_done;
    wire mul_div_start;

    hazard_detection_unit u_hazard_detection_unit (
        .id_rs1(rs1_id),
        .id_rs2(rs2_id),
        .id_branch(branch_like_id),
        .ex_rd(rd_ex),
        .ex_MemRead(ex_MemRead),
        .ex_RegWrite(RegWrite_ex),
        .mem_rd(rd_mem),
        .mem_RegWrite(mem_RegWrite),
        .ex_is_mul_div(ex_is_mul_div),
        .mul_div_done(mul_div_done),
        .pc_if_stall(pc_if_stall),
        .hold(hold),
        .bubble(bubble)
    );

    assign flush = !pc_if_stall && (branch_taken || jump_taken);

    wire [31:0] pc_ex;
    wire [31:0] pc_plus4_ex;
    wire [31:0] rs1_data_ex;
    wire [31:0] rs2_data_ex;
    wire [31:0] imm_ex;
    wire [2:0]  funct3_ex;
    wire        funct7_5thBIT_ex;
    wire [2:0]  mul_div_op_ex;
    wire        MemWrite_ex;
    wire        MemtoReg_ex;
    wire        ALUsrc_ex;
    wire        branch_ex;
    wire        jump_ex;
    wire        MemRead_ex;
    wire [1:0]  ALUopCode_ex;
    wire [6:0]  opcode_ex;
    wire        RegWrite_ex;

    id_to_ex_reg u_id_to_ex_reg (
        .clk(clk),
        .rst(rst),
        .bubble(bubble),
        .hold(hold),
        .flush(flush),
        .pc_id(pc_id),
        .pc_plus4_id(pc_plus4_id),
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rs1_data_id(rs1_data_id),
        .rs2_data_id(rs2_data_id),
        .rd_id(rd_id),
        .imm_id(imm_id),
        .funct3_id(funct3_id),
        .funct7_5thBIT_id(funct7_5thBIT_id),
        .is_mul_div_id(is_mul_div_id),
        .mul_div_op_id(mul_div_op_id),
        .RegWrite_id(RegWrite_id),
        .MemWrite_id(MemWrite_id),
        .MemtoReg_id(MemtoReg_id),
        .ALUsrc_id(ALUsrc_id),
        .branch_id(branch_id),
        .jump_id(jump_id),
        .MemRead_id(MemRead_id),
        .ALUopCode_id(ALUopCode_id),
        .opcode_id(opcode_id),
        .pc_ex(pc_ex),
        .pc_plus4_ex(pc_plus4_ex),
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rs1_data_ex(rs1_data_ex),
        .rs2_data_ex(rs2_data_ex),
        .rd_ex(rd_ex),
        .imm_ex(imm_ex),
        .funct3_ex(funct3_ex),
        .funct7_5thBIT_ex(funct7_5thBIT_ex),
        .is_mul_div_ex(ex_is_mul_div),
        .mul_div_op_ex(mul_div_op_ex),
        .RegWrite_ex(RegWrite_ex),
        .MemWrite_ex(MemWrite_ex),
        .MemtoReg_ex(MemtoReg_ex),
        .ALUsrc_ex(ALUsrc_ex),
        .branch_ex(branch_ex),
        .jump_ex(jump_ex),
        .MemRead_ex(ex_MemRead),
        .ALUopCode_ex(ALUopCode_ex),
        .opcode_ex(opcode_ex)
    );

    // EX STAGE

    wire [1:0] forward_a;
    wire [1:0] forward_b;
    wire [31:0] forwarded_rs1_data;
    wire [31:0] forwarded_rs2_data;
    wire [31:0] ex_operand_a;
    wire [31:0] ex_operand_b;
    wire [3:0]  alu_op;
    wire [31:0] alu_result;
    wire [31:0] mul_div_result;
    wire [31:0] ex_result;
    wire        alu_zero;

    forwarding_unit u_forwarding_unit (
        .id_ex_rs1(rs1_ex),
        .id_ex_rs2(rs2_ex),
        .ex_mem_rd(rd_mem),
        .ex_mem_RegWrite(mem_RegWrite),
        .mem_wb_rd(rd_wb),
        .mem_wb_RegWrite(RegWrite_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    assign forwarded_rs1_data = (forward_a == 2'b10) ? alu_result_mem :
                                (forward_a == 2'b01) ? write_data_wb :
                                                        rs1_data_ex;
    assign forwarded_rs2_data = (forward_b == 2'b10) ? alu_result_mem :
                                (forward_b == 2'b01) ? write_data_wb :
                                                        rs2_data_ex;

    assign ex_operand_a = forwarded_rs1_data;
    assign ex_operand_b = ALUsrc_ex ? imm_ex : forwarded_rs2_data;

    alu_control u_alu_control (
        .ALUopCode(ALUopCode_ex),
        .funct3(funct3_ex),
        .funct7_5thBIT(funct7_5thBIT_ex),
        .is_mul_div(ex_is_mul_div),
        .alu_op(alu_op)
    );

    alu u_alu (
        .operand_a(ex_operand_a),
        .operand_b(ex_operand_b),
        .alu_op(alu_op),
        .zero(alu_zero),
        .alu_result(alu_result)
    );

    assign mul_div_start = ex_is_mul_div && !mul_div_busy && !mul_div_done;

    mul_div_unit u_mul_div_unit (
        .clk(clk),
        .rst(rst),
        .operand_a(forwarded_rs1_data),
        .operand_b(forwarded_rs2_data),
        .op(mul_div_op_ex),
        .start(mul_div_start),
        .abort(1'b0),
        .result(mul_div_result),
        .busy(mul_div_busy),
        .done(mul_div_done)
    );

    assign ex_result = jump_ex ? pc_plus4_ex :
                       (opcode_ex == OP_LUI) ? imm_ex :
                       (opcode_ex == OP_AUIPC) ? (pc_ex + imm_ex) :
                       ex_is_mul_div ? mul_div_result :
                       alu_result;

    wire [31:0] rs2_data_mem;
    wire        RegWrite_mem;
    wire        MemRead_mem;
    wire        MemWrite_mem;
    wire        MemtoReg_mem;
    wire [31:0] ex_to_mem_alu_result_in = hold ? alu_result_mem : ex_result;
    wire [31:0] ex_to_mem_rs2_data_in    = hold ? rs2_data_mem : forwarded_rs2_data;
    wire [4:0]  ex_to_mem_rd_in          = hold ? rd_mem : rd_ex;
    wire        ex_to_mem_RegWrite_in    = hold ? RegWrite_mem : RegWrite_ex;
    wire        ex_to_mem_MemRead_in     = hold ? MemRead_mem : ex_MemRead;
    wire        ex_to_mem_MemWrite_in    = hold ? MemWrite_mem : MemWrite_ex;
    wire        ex_to_mem_MemtoReg_in    = hold ? MemtoReg_mem : MemtoReg_ex;

    ex_to_mem_reg u_ex_to_mem_reg (
        .clk(clk),
        .rst(rst),
        .alu_result_ex(ex_to_mem_alu_result_in),
        .rs2_data_ex(ex_to_mem_rs2_data_in),
        .rd_ex(ex_to_mem_rd_in),
        .RegWrite_ex(ex_to_mem_RegWrite_in),
        .MemRead_ex(ex_to_mem_MemRead_in),
        .MemWrite_ex(ex_to_mem_MemWrite_in),
        .MemtoReg_ex(ex_to_mem_MemtoReg_in),
        .alu_result_mem(alu_result_mem),
        .rs2_data_mem(rs2_data_mem),
        .rd_mem(rd_mem),
        .RegWrite_mem(RegWrite_mem),
        .MemRead_mem(MemRead_mem),
        .MemWrite_mem(MemWrite_mem),
        .MemtoReg_mem(MemtoReg_mem)
    );

    // MEM STAGE

    wire [31:0] read_data_mem;

    data_memory u_data_memory (
        .clk(clk),
        .address(alu_result_mem),
        .write_data(rs2_data_mem),
        .MemRead(MemRead_mem),
        .MemWrite(MemWrite_mem),
        .read_data(read_data_mem)
    );

    wire [31:0] alu_result_wb;
    wire [31:0] read_data_wb;
    wire        MemtoReg_wb;
    wire [31:0] wb_alu_result_in = hold ? alu_result_wb : alu_result_mem;
    wire [31:0] wb_read_data_in   = hold ? read_data_wb : read_data_mem;
    wire [4:0]  wb_rd_in         = hold ? rd_wb : rd_mem;
    wire        wb_RegWrite_in   = hold ? RegWrite_wb : RegWrite_mem;
    wire        wb_MemtoReg_in   = hold ? MemtoReg_wb : MemtoReg_mem;

    mem_to_wb_reg u_mem_to_wb_reg (
        .clk(clk),
        .rst(rst),
        .alu_result_mem(wb_alu_result_in),
        .read_data_mem(wb_read_data_in),
        .rd_mem(wb_rd_in),
        .RegWrite_mem(wb_RegWrite_in),
        .MemtoReg_mem(wb_MemtoReg_in),
        .alu_result_wb(alu_result_wb),
        .read_data_wb(read_data_wb),
        .rd_wb(rd_wb),
        .RegWrite_wb(RegWrite_wb),
        .MemtoReg_wb(MemtoReg_wb)
    );

// WB STAGE
    wb_mux u_wb_mux (
        .alu_result_wb(alu_result_wb),
        .read_data_wb(read_data_wb),
        .MemtoReg_wb(MemtoReg_wb),
        .write_data_wb(write_data_wb)
    );


endmodule   

