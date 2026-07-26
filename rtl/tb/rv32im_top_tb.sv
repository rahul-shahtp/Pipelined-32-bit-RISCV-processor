`timescale 1ns/1ps

module rv32im_top_tb;
    localparam int CLK_PERIOD = 10;
    localparam int MAX_CYCLES = 50000; // Watchdog timeout
    localparam int MEM_WORDS  = 1024;

    logic clk = 1'b0;
    logic rst = 1'b1;

    // DUT Instantiation
    rv32im_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    //  Waveform generation
    initial begin
        $dumpfile("rv32im_pipeline.vcd");
        $dumpvars(0, rv32im_top_tb);
    end

    //  Register file correctness (x0 fixed at zero)
    always @(negedge clk) begin
        if (!rst) begin
            // 1. x0 must strictly remain zero 
            if (dut.u_register_file.register[0] !== 32'h00000000) begin
                $display("\n[FATAL ERROR] Invariant Violation: x0 is not zero! Got: 0x%08h at PC: 0x%08h", 
                         dut.u_register_file.register[0], dut.pc_if);
                $finish;
            end
            
            // 2. Program counter must remain 32-bit
            if (dut.pc_if[1:0] !== 2'b00) begin
                $display("\n[FATAL ERROR] Invariant Violation: PC is unaligned! PC: 0x%08h", dut.pc_if);
                $finish;
            end
            
            // 3. Memory bounds checking 
            if (dut.MemWrite_ex) begin
                if ((dut.alu_result >> 2) >= MEM_WORDS) begin
                    $display("\n[FATAL ERROR] Memory Write out of bounds! Address: 0x%08h", dut.alu_result);
                    $finish;
                end
            end
        end
    end

 
endmodule