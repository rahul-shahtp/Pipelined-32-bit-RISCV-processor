`timescale 1ns/1ps

module simple_add_tb;
    logic clk = 0;
    logic rst = 1;

    rv32im_top dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;  

    initial begin
        $dumpfile("simple_add.vcd");
        $dumpvars(0, simple_add_tb);

        repeat (5) @(posedge clk);
        rst = 0;

        repeat (200) @(posedge clk);  

        $display("\n--- Final Register State ---");
        $display("x5 = %0d", dut.u_register_file.register[5]);
        $display("x6 = %0d", dut.u_register_file.register[6]);
        $display("x7 = %0d", dut.u_register_file.register[7]);
        $display("Memory[0] = %0d", dut.u_data_memory.memory[0]);

        $finish;
    end
endmodule