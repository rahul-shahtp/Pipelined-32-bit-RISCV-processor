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

        for (int i = 0; i < 32; i++)
            $dumpvars(1, dut.u_register_file.register[i]);
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

   // Pipeline stage movement & data/control hazard Coverage
    bit covered_stall;
    bit covered_flush;
    bit covered_fwd_a;
    bit covered_fwd_b;
    
    always @(posedge clk) begin
        if (!rst) begin
            // Track if pipeline control signals actually fired during the test
            if (dut.pc_if_stall)        covered_stall = 1'b1;
            if (dut.flush)              covered_flush = 1'b1;
            if (dut.forward_a != 2'b00) covered_fwd_a = 1'b1;
            if (dut.forward_b != 2'b00) covered_fwd_b = 1'b1;
        end
    end
   
    // Reset behavior and Hex Execution
    task automatic run_hex_test(
        input  string hex_file, 
        output bit    success
        );
    
        logic [31:0] current_instr;
        int  cycle_count = 0;
        bit  finished = 1'b0;
        success = 1'b0;
    
        $display("\n-------------------------------------------------");
        $display("[RUNNING] Test: %s", hex_file);
    
        for (int i = 0; i < MEM_WORDS; i++) begin
            dut.u_instr_mem.memory[i]   = 32'h00000000;
            dut.u_data_memory.memory[i] = 32'h00000000;
        end
    
        $readmemh(hex_file, dut.u_instr_mem.memory);
    
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    
        while (!finished && cycle_count < MAX_CYCLES) begin
            @(posedge clk);
            cycle_count++;
            current_instr = dut.u_instr_mem.memory[dut.pc_if >> 2];
    
            if (current_instr == 32'h00100073) begin
                if (dut.u_register_file.register[10] == 32'd1 || dut.u_register_file.register[10] == 32'd0) begin
                    $display("[PASS] %s - EBREAK (x10 valid).", hex_file);
                    success = 1'b1;
                end else begin
                    $display("[FAIL] %s - EBREAK Error (x10 = %0d).", hex_file, dut.u_register_file.register[10]);
                    success = 1'b0;
                end
                finished = 1'b1;
            end
            else if (current_instr == 32'h0000006f) begin
                $display("[INFO] %s - Jump-to-self halt detected.", hex_file);
                success  = 1'b1;
                finished = 1'b1;
            end
        end
    
        if (!finished)
            $display("[FAIL] %s - Watchdog timeout after %0d cycles.", hex_file, MAX_CYCLES);

    endtask

    //---------------------------------------------------------
    // Regression tests using multiple .hex programs
    //---------------------------------------------------------
    initial begin
        string test_suite [] = '{
            "hex/simple_add.hex"
        };
        
        int passed_tests = 0;
        int total_tests  = test_suite.size();
        bit current_status;

        $display("\n=================================================");
        $display("  STARTING FULL RV32IM PIPELINE VERIFICATION");
        $display("  Total Tests Queued: %0d", total_tests);
        $display("=================================================");

        foreach (test_suite[i]) begin
            run_hex_test(test_suite[i], current_status);
            if (current_status) passed_tests++;
        end

        // Final Assessment
        $display("\n=================================================");
        $display("  VERIFICATION SCORECARD");
        $display("  Regression Tests:  %0d / %0d Passed", passed_tests, total_tests);
        
        // Pipeline Feature Coverage Report
        $display("\n  PIPELINE COVERAGE REPORT:");
        $display("  - Load-Use Stalls     : %s", covered_stall ? "VERIFIED" : "MISSING");
        $display("  - Control Flushes     : %s", covered_flush ? "VERIFIED" : "MISSING");
        $display("  - ALU Forwarding A    : %s", covered_fwd_a ? "VERIFIED" : "MISSING");
        $display("  - ALU Forwarding B    : %s", covered_fwd_b ? "VERIFIED" : "MISSING");
        $display("=================================================\n");

        if (passed_tests == total_tests && covered_stall && covered_flush && covered_fwd_a && covered_fwd_b) begin
            $display("ALL TESTS PASSED & ALL PIPELINE FEATURES VERIFIED! \n");
        end else if (passed_tests == total_tests) begin
            $display("TESTS PASSED, BUT SOME PIPELINE FEATURES WERE NOT EXERCISED. \n");
        end else begin
            $display("TEST SUITE FAILED! \n");
        end

        repeat (500) @(posedge clk);   // extend sim/waveform for viewing

        $finish;
    end

endmodule