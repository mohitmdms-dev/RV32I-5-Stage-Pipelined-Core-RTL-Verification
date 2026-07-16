`timescale 1ns / 1ps

module test_back_to_branch;

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
    
    // Test execution block
    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, test_back_to_branch);

        // Load the back-to-back branch test
        $readmemh("verif/tests/hex_code/test_back_to_back_branch.hex", dut.imem.rom);

        // Reset sequence
        rst_n = 0;
        #20;
        rst_n = 1;

        
        #500;

        // VERIFICATION 
        $display("Time: %0t | Verifying x10...", $time);
        
        if (dut.rf_inst.mem_array[10] === 32'd100) begin
            $display("========================================");
            $display("SUCCESS: Back-to-Back Branches Passed!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 100, but got %d", dut.rf_inst.mem_array[10]);
            $display("========================================");
        end
        
        $finish;
    end
endmodule