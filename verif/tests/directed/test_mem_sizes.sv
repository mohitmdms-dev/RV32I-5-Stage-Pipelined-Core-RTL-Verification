`timescale 1ns / 1ps

module test_mem_sizes;

    logic clk;
    logic rst_n;

    // Instantiation of the DUT
    riscv_core dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test block
    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, test_mem_sizes);

        // Load the memory sizes test
        $readmemh("verif/tests/hex_code/test_mem_sizes.hex", dut.imem.rom);

        // Reset sequence
        rst_n = 0;
        #20;
        rst_n = 1;

        // time for pipeline to finish all 5 instructions
        #500;

        // VERIFICATION
        $display("Time: %0t | Verifying Memory Byte Masking & Extension...", $time);
        
        if (dut.rf_inst.mem_array[3] === 32'h000000AB && dut.rf_inst.mem_array[4] === 32'hFFFFFFAB) begin
            $display("========================================");
            $display("SUCCESS: Byte Masking and Sign-Extension Passed!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Memory logic error.");
            $display("x3 (LBU) Expected: 000000AB | Got: %h", dut.rf_inst.mem_array[3]);
            $display("x4 (LB)  Expected: FFFFFFAB | Got: %h", dut.rf_inst.mem_array[4]);
            $display("========================================");
        end
        
        $finish;
    end
endmodule