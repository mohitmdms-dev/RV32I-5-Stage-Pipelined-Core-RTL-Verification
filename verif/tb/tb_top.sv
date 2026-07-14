`timescale 1ns / 1ps

module tb_top;

    logic clk;
    logic rst_n;

    //instantiation of the dut

    riscv_core dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    //clock generation

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, tb_top);

        // READ THE HEX FILE INTO MEMORY HERE:
        $readmemh("verif/tests/directed/test_alu_ops.hex", dut.imem.rom);

        //reset active
        rst_n = 0;

        #25;

        //reset inactive
        rst_n = 1;

        #500;

        $finish;

    end
    

    always_ff @(negedge clk) begin

        //only evaluate on cycles where the processor actually writes
        if(dut.reg_write_W) begin
            //check specifically for our final ADD instruction writing to x3 
            if (dut.rd_W == 5'd3) begin
                //assert the math is correct
                if (dut.write_data_W == 32'h0000_000F) begin
                    $display("\n=========");
                    $display("SUCCESS: x3 correctly calculated as 15");
                    $display("=========\n");
                    $finish; 
                end
                else begin
                    $fatal(1, "\n FAILED: expected 15 in x3, but got %h\n", dut.write_data_W);
                end
            end
        end
    end

    
endmodule
