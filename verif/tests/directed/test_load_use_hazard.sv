`timescale 1ns / 1ps

module test_load_use_hazard;

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
        $dumpvars(0, test_load_use_hazard);

        // Load the Load-Use Hazard test
        $readmemh("verif/tests/hex_code/test_load_use_hazard.hex", dut.imem.rom);

        rst_n = 0;
        #20;
        rst_n = 1;

        #500; 

        // VERIFICATION 
        // If forwarding logic works, x4 will be 10, the BEQ will be taken, 
        // the branch will succeed, and x10 will become 100.
        $display("Time: %0t | Verifying Hazard Handling (Target: x10=100)...", $time);
        
        if (dut.rf_inst.mem_array[10] === 32'd100) begin
            $display("========================================");
            $display("SUCCESS: Load-Use Hazard and Branch Forwarding Passed!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 100, but got %d", dut.rf_inst.mem_array[10]);
            $display("========================================");
        end
        
        $finish;
    end
endmodule