`timescale 1ns / 1ps

module test_reset_integrity;

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
    
    // Reset Sequence and Integrity Check
  
    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, test_reset_integrity);

        $readmemh("verif/tests/hex_code/test_branch.hex", dut.imem.rom);

    
        $display("Time: %0t | Power-On State | PC = %h | x0 = %h", $time, dut.pc_F, dut.rf_inst.mem_array[0]);

        // ASSERT RESET
        rst_n = 0;
        #5; // Wait half a clock cycle
        
        $display("Time: %0t | Reset Active   | PC = %h | x0 = %h", $time, dut.pc_F, dut.rf_inst.mem_array[0]);

        
        $display("========================================");
        if (dut.pc_F === 32'h00000000 && dut.rf_inst.mem_array[0] === 32'h00000000) begin
            $display("SUCCESS: Reset Behavior and x0 Integrity Passed!");
        end else begin
            $display("FAIL: Uninitialized states (X) or non-zero x0 detected.");
        end
        $display("=========================================");

        // RELEASE RESET
        rst_n = 1;
        #15; // Wait past the next clock edge

        $display("Time: %0t | Reset Released | PC = %h | x0 = %h", $time, dut.pc_F, dut.rf_inst.mem_array[0]);
        
        $finish;
    end

endmodule
