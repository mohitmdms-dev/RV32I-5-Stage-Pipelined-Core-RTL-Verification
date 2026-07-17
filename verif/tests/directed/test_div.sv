`timescale 1ns / 1ps

module test_div;

    logic clk;
    logic rst_n;
    logic [31:0] probe_out;

    riscv_core uut (
        .clk(clk),
        .rst_n(rst_n),
        .probe_out(probe_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    
    integer test_step = 1;
    integer errors = 0;

    always @(negedge clk) begin
        if (rst_n && uut.reg_write_W && uut.rd_W != 5'b0) begin
            $display("Time: %0t | Register Write: x%0d = %0d (Hex: %h)", $time, uut.rd_W, uut.write_data_W, uut.write_data_W);
            
            case (test_step)
                1: begin
                    if (uut.rd_W === 5'd1 && uut.write_data_W === 32'd100) 
                        $display("  [PASS] Step 1: x1 = 100");
                    else begin $display("  [FAIL] Step 1: Expected x1 = 100"); errors++; end
                end
                2: begin
                    if (uut.rd_W === 5'd2 && uut.write_data_W === 32'd3) 
                        $display("  [PASS] Step 2: x2 = 3");
                    else begin $display("  [FAIL] Step 2: Expected x2 = 3"); errors++; end
                end
                3: begin
                    if (uut.rd_W === 5'd3 && uut.write_data_W === 32'd0) 
                        $display("  [PASS] Step 3: x3 = 0");
                    else begin $display("  [FAIL] Step 3: Expected x3 = 0"); errors++; end
                end
                4: begin
                    if (uut.rd_W === 5'd4 && uut.write_data_W === 32'd33) 
                        $display("  [PASS] Step 4: DIV x4 = 33 (Standard Division)");
                    else begin $display("  [FAIL] Step 4: Expected x4 = 33"); errors++; end
                end
                5: begin
                    if (uut.rd_W === 5'd5 && uut.write_data_W === 32'hFFFF_FFFF) 
                        $display("  [PASS] Step 5: DIV x5 = 0xFFFFFFFF (Division by Zero Handled!)");
                    else begin $display("  [FAIL] Step 5: Expected x5 = 0xFFFFFFFF"); errors++; end
                end
                6: begin
                    if (uut.rd_W === 5'd6 && uut.write_data_W === 32'd1) 
                        $display("  [PASS] Step 6: x6 = 1");
                    else begin $display("  [FAIL] Step 6: Expected x6 = 1"); errors++; end
                end
                7: begin
                    if (uut.rd_W === 5'd7 && uut.write_data_W === 32'd100) 
                        $display("  [PASS] Step 7: DIV x7 = 100 (Division by One / Forwarding Success!)");
                    else begin $display("  [FAIL] Step 7: Expected x7 = 100"); errors++; end
                    
                    $display("====================================================");
                    if (errors == 0) 
                        $display("  DIVIDER VERIFICATION SUCCESS: ALL TESTS PASSED! ");
                    else 
                        $display("  VERIFICATION FAILED: %0d errors detected.", errors);
                    $display("====================================================");
                    $finish;
                end
            endcase
            test_step++;
        end
    end

    // Watchdog Timer
    initial begin
        #2500;
        $display("\n[FATAL] Watchdog Timeout! Simulation stalled.");
        $finish;
    end

    
    initial begin
        $display("Starting RISC-V Divider Edge-Case Verification...");
        $dumpfile("riscv_waves.vcd");
        $dumpvars(0, test_div);

        for (int i = 0; i < 256; i++) begin
            uut.imem.rom[i] = 32'h00000000;
        end
        
        
        $readmemh("verif/tests/hex_code/test_div.hex", uut.imem.rom);

        rst_n = 0;
        #17;
        rst_n = 1;
    end

endmodule