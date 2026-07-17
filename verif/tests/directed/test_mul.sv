`timescale 1ns / 1ps

module test_mul;

    logic clk;
    logic rst_n;

    // Instantiation of the DUT
    riscv_core dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation (10ns period / 100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test execution block
    initial begin
        
        $dumpfile("sim/test_mul.vcd");
        $dumpvars(0, test_mul);
    
        $readmemh("verif/tests/hex_code/test_mul.hex", dut.imem.rom);

        // Reset 
        rst_n = 0;
        #20;
        rst_n = 1;

        //enough time for the 32-cycle stall to finish
        #500;

        // VERIFICATION
        // If the MUL instruction works and stalls correctly, 
        // 5 * 4 will be 20, stored in register x7.
        $display("Time: %0t | Verifying MUL (Target: x7=20)...", $time);
        
        
        if (dut.rf_inst.mem_array[7] === 32'd20) begin
            $display("========================================");
            $display("SUCCESS: Multiplier stalled and computed correctly!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 20 in x7, but got %d", dut.rf_inst.mem_array[7]);
            $display("========================================");
        end
        
        $finish;
    end
endmodule