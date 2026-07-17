`timescale 1ns / 1ps

module test_multiplier;

    logic        clk;
    logic        rst_n;
    logic        start;
    logic [31:0] multiplicand;
    logic [31:0] multiplier_in;
    
    logic [31:0] result;
    logic        ready;

    // Instantiate the Device Under Test (DUT)
    multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier_in),
        .result(result),
        .ready(ready)
    );

    // Clock generation (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test Sequence
    initial begin
        // Setup waveforms
        $dumpfile("sim/multiplier_tb.vcd");
        $dumpvars(0, test_multiplier);

        // Initialize and Reset
        start = 0;
        multiplicand = 0;
        multiplier_in = 0;
        rst_n = 0;
        #25; 
        rst_n = 1; // Release reset
        #15;

        $display("========================================");
        $display("Time: %0t | Starting Multiplier Unit Tests...", $time);
        $display("========================================");

        
        // TEST 1: 25 * 4 = 100

        @(posedge clk);
        multiplicand  = 32'd25;
        multiplier_in = 32'd4;
        start         = 1'b1;     // Pulse start HIGH
        
        @(posedge clk);
        start         = 1'b0;     // Pulse start LOW (must only be high for 1 cycle)

        // The testbench pauses here and waits for the DUT to pull 'ready' HIGH
        wait(ready == 1'b1);
        @(posedge clk); // Wait one more edge to let the result settle on the wire

        if (result === 32'd100) begin
            $display("SUCCESS: Test 1 Passed! 25 * 4 = %d", result);
        end else begin
            $display("FAIL: Test 1! Expected 100, Got %d", result);
        end

        
        // TEST 2: 1024 * 7 = 7168
        
        @(posedge clk);
        multiplicand  = 32'd1024;
        multiplier_in = 32'd7;
        start         = 1'b1;
        
        @(posedge clk);
        start         = 1'b0;

        wait(ready == 1'b1);
        @(posedge clk);

        if (result === 32'd7168) begin
            $display("SUCCESS: Test 2 Passed! 1024 * 7 = %d", result);
        end else begin
            $display("FAIL: Test 2! Expected 7168, Got %d", result);
        end

        $display("========================================");
        $display("Time: %0t | All Tests Completed.", $time);
        
        $finish;
    end
endmodule