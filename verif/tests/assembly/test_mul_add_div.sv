`timescale 1ns / 1ps

module test_mul_add_div;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [31:0] probe_out;

    // Instantiate the Top-Level Processor
    riscv_core uut (
        .clk(clk),
        .rst_n(rst_n),
        .probe_out(probe_out)
    );

    // 100 MHz Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    
    integer test_step = 1;
    integer errors = 0;

    // Monitor the Writeback Stage on the falling edge of the clock
    // (This ensures the data has settled before we read it)
    always @(negedge clk) begin
        // Only check when the processor is actively writing to a valid register
        if (rst_n && uut.reg_write_W && uut.rd_W != 5'b0) begin
            $display("Time: %0t | Register Write: x%0d = %0d", $time, uut.rd_W, uut.write_data_W);
            
            case (test_step)
                1: begin
                    if (uut.rd_W === 5'd1 && uut.write_data_W === 32'd11) 
                        $display("  [PASS] Step 1: x1 = 11");
                    else begin 
                        $display("  [FAIL] Step 1: Expected x1 = 11"); 
                        errors++; 
                    end
                end
                2: begin
                    if (uut.rd_W === 5'd2 && uut.write_data_W === 32'd3) 
                        $display("  [PASS] Step 2: x2 = 3");
                    else begin 
                        $display("  [FAIL] Step 2: Expected x2 = 3"); 
                        errors++; 
                    end
                end
                3: begin
                    if (uut.rd_W === 5'd3 && uut.write_data_W === 32'd33) 
                        $display("  [PASS] Step 3: MUL x3 = 33 (Stall Success)");
                    else begin 
                        $display("  [FAIL] Step 3: Expected x3 = 33"); 
                        errors++; 
                    end
                end
                4: begin
                    if (uut.rd_W === 5'd4 && uut.write_data_W === 32'd44) 
                        $display("  [PASS] Step 4: ADD x4 = 44 (MUL-to-ADD Forwarding Success!)");
                    else begin 
                        $display("  [FAIL] Step 4: Expected x4 = 44"); 
                        errors++; 
                    end
                end
                5: begin
                    if (uut.rd_W === 5'd5 && uut.write_data_W === 32'd14) 
                        $display("  [PASS] Step 5: DIV x5 = 14 (ADD-to-DIV Forwarding Success!)");
                    else begin 
                        $display("  [FAIL] Step 5: Expected x5 = 14"); 
                        errors++; 
                    end
                    
                    // The test is over after the 5th instruction writes back.
                    $display("====================================================");
                    if (errors == 0) 
                        $display("  VERIFICATION SUCCESS: ALL TESTS PASSED! ");
                    else 
                        $display("  VERIFICATION FAILED: %0d errors detected.", errors);
                    $display("====================================================");
                    $finish;
                end
            endcase
            test_step++;
        end
    end

    
    // WATCHDOG TIMER
    // If our stall logic is broken, the simulation might freeze forever.
    // This watchdog forces the simulation to fail and exit if it takes too long.
    initial begin
        #2000;
        $display("\n[FATAL] Watchdog Timeout! The processor stalled indefinitely or failed to execute all 5 instructions.");
        $display("====================================================");
        $finish;
    end

    
    initial begin
        $display("Starting RISC-V Verification...");
        
        // Dump waves  
        $dumpfile("riscv_waves.vcd");
        $dumpvars(0, test_mul_add_div);
        
        // Zero out the entire instruction memory to prevent X-propagation
        for (int i = 0; i < 256; i++) begin
            uut.imem.rom[i] = 32'h00000000;
        end
        $readmemh("verif/tests/hex_code/test_mul_add_div.hex", uut.imem.rom);
        // Apply System Reset
        rst_n = 0;
        #15;
        rst_n = 1;
    end

endmodule