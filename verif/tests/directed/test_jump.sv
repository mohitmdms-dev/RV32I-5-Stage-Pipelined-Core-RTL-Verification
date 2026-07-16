`timescale 1ns / 1ps

module test_jump;

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
        $dumpvars(0, test_jump);

        // Load the Jump test
        $readmemh("verif/tests/hex_code/test_jump.hex", dut.imem.rom);

        // Reset sequence
        rst_n = 0;
        #20;
        rst_n = 1;

        // Allow ample time for pipeline flushes and write-back
        #500;

        // VERIFICATION
        // If JAL and JALR work correctly, x10 will equal 12.
        $display("Time: %0t | Verifying Jumps (Target: x10=12)...", $time);
        
        if (dut.rf_inst.mem_array[10] === 32'd12) begin
            $display("========================================");
            $display("SUCCESS: JAL and JALR Passed! Poison Pills Skipped.");
            $display("========================================");
        end else if (dut.rf_inst.mem_array[10] === 32'd99) begin
            $display("========================================");
            $display("FAIL: Poison Pill Executed! A jump failed to flush the pipeline.");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 12 in x10, but got %d", dut.rf_inst.mem_array[10]);
            $display("Tip: Verify JAL saved the correct return address in x1, or check JALR ALU target calculation.");
            $display("========================================");
        end
        
        $finish;
    end
endmodule