`timescale 1ns / 1ps

module test_forwarding;

    // --- Signals ---
    logic clk;
    logic rst_n;
    
     riscv_core dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, test_forwarding);
        // Load the test
        $readmemh("verif/tests/hex_code/test_forwarding.hex", dut.imem.rom);

        // Reset sequence
        rst_n = 0;
        #20;
        rst_n = 1;

      #2000;

        // VERIFICATION
        // We expect x3 to be 21 
        $display("Time: %0t | Verifying ALU Arithmetic Chain (Target: x3=28)...", $time);
    
        if (dut.rf_inst.mem_array[3] === 32'd21) begin
           $display("========================================");
           $display("SUCCESS: Arithmetic Chain Passed!");
           $display("========================================");
        end
        else begin
           $display("========================================");
           $display("FAIL: Expected 28, but got %d", dut.rf_inst.mem_array[3]);
           $display("========================================");
        end
    
        $finish;
    end

endmodule