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
    
    //memory initialization and waveform dump
    initial begin
        $dumpfile("sim/riscv_tb.vcd");
        $dumpvars(0, tb_top);

        // READ THE HEX FILE INTO MEMORY HERE:
        $readmemh("verif/tests/directed/test_alu_r_type.hex", dut.imem.rom);

        //reset active
        rst_n = 0;

        #25;

        //reset inactive
        rst_n = 1;

        #2000;

        $finish;

    end
    
    //verification block
    always_ff @(negedge clk) begin
        if (dut.reg_write_W) begin
            $display("Time: %0t | Writeback: Reg[%0d] = %h", $time, dut.rd_W, dut.write_data_W);

            if(dut.rd_W == 5'd10) begin 
                if (dut.write_data_W == 32'd2) begin 
                    $display("=========================");
                    $display("SUCCESS: Test Passed (Value: %d)", dut.write_data_W);
                    $display("==========================");
                    $finish;
                end
            end
         end
    end


endmodule
