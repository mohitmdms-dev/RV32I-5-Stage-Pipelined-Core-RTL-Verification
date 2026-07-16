`timescale 1ns / 1ps

module test_branch_not_taken;

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
        $dumpvars(0, test_branch_not_taken);

        // Load the Branch Not Taken test
        $readmemh("verif/tests/hex_code/test_branch_not_taken.hex", dut.imem.rom);

        // Reset sequence
        rst_n = 0;
        #20;
        rst_n = 1;

        #500;

        // VERIFICATION
        // If branch is NOT taken, PC continues to the next instruction (x3 = 10)
        $display("Time: %0t | Verifying x3 (Target Result)...", $time);
        
        if (dut.rf_inst.mem_array[3] === 32'd10) begin
            $display("========================================");
            $display("SUCCESS: Branch Not Taken! Pipeline continued correctly.");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 10 in x3, but got %d", dut.rf_inst.mem_array[3]);
            $display("========================================");
        end
        
        $finish;
    end
    
endmodule