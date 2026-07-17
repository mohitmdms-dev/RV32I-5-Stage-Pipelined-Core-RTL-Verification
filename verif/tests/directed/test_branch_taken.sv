`timescale 1ns / 1ps

module test_branch_taken;

    logic clk;
    logic rst_n;
    
    //instantiate dut
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
        $dumpvars(0, test_branch_taken);

        // Load the Branch Taken test
        $readmemh("verif/tests/hex_code/test_branch_taken.hex", dut.imem.rom);

        rst_n = 0;
        #20;
        rst_n = 1;

        #500; 

        // VERIFICATION 
        $display("Time: %0t | Verifying Branch Taken (Target: x10=100)...", $time);
        
        if (dut.rf_inst.mem_array[10] === 32'd100) begin
            $display("========================================");
            $display("SUCCESS: Branch Taken and Poison Pill Flushed!");
            $display("========================================");
        end else if (dut.rf_inst.mem_array[10] === 32'd99) begin
            $display("========================================");
            $display("FAIL: Poison Pill executed! Flush logic failed.");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("FAIL: Expected 100, but got %d", dut.rf_inst.mem_array[10]);
            $display("========================================");
        end
        
        $finish;
    end
    
endmodule