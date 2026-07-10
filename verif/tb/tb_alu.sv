module alu_tb;

    parameter DATA_WIDTH = 32;

    logic [DATA_WIDTH-1:0] a_test;
    logic [DATA_WIDTH-1:0] b_test;
    logic [3:0]            op_sel_test;
    logic [DATA_WIDTH-1:0] result_test;
    logic                  zero_flag_test; 

    // Instantiating the ALU with the parameter
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .a(a_test),
        .b(b_test),
        .op_sel(op_sel_test),
        .result(result_test),
        .zero_flag(zero_flag_test) 
    );

    initial begin 
        
        // TEST ADD
        
        a_test = 32'd10;
        b_test = 32'd5;
        op_sel_test = 4'b0000; // ADD
        #10;
        if (result_test == 32'd15 && zero_flag_test == 1'b0)
            $display("ADD Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        // ADD resulting in 0 (overflow)
        a_test = 32'hFFFF_FFFF;
        b_test = 32'd1;
        op_sel_test = 4'b0000; // ADD
        #10;
        
        if (result_test == 32'd0 && zero_flag_test == 1'b1) 
            $display("ADD Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        
        
        // TEST SUB
        
        a_test = 32'd5;
        b_test = 32'd2;
        op_sel_test = 4'b0001; // SUB
        #10;
        if (result_test == 32'd3 && zero_flag_test == 1'b0) 
            $display("SUB Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        // SUB resulting in a negative number (Two's Complement)
        a_test = 32'd2;
        b_test = 32'd5;
        op_sel_test = 4'b0001; // SUB
        #10;
        if (result_test == 32'hFFFF_FFFD && zero_flag_test == 1'b0) 
            $display("SUB Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

    
        // TEST AND
        
        a_test = 32'd5;
        b_test = 32'd2;
        op_sel_test = 4'b0010; // AND
        #10;
        //  (0101) AND (0010) = (0000)
        if (result_test == 32'd0 && zero_flag_test == 1'b1) 
            $display("AND Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        a_test = 32'd0;
        b_test = 32'd2;
        op_sel_test = 4'b0010; // AND
        #10;
        if (result_test == 32'd0 && zero_flag_test == 1'b1) 
            $display("AND Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        
        // TEST OR 
        
        a_test = 32'd2;
        b_test = 32'd12;
        op_sel_test = 4'b0011; // OR
        #10;
        if (result_test == 32'd14 && zero_flag_test == 1'b0) 
            $display("OR Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        
        // TEST XOR
        
        a_test = 32'd2;
        b_test = 32'd12;
        op_sel_test = 4'b0100; // XOR
        #10;
        if (result_test == 32'd14 && zero_flag_test == 1'b0) 
            $display("XOR Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        
        // TEST SLL (Shift Left Logical)
        
        a_test = 32'd2;
        b_test = 32'd1;
        op_sel_test = 4'b0101; // SLL
        #10;
        if (result_test == 32'd4 && zero_flag_test == 1'b0) 
            $display("SLL Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        // TEST SRL (Shift Right Logical)
        
        a_test = 32'd2;
        b_test = 32'd1;
        op_sel_test = 4'b0110; // SRL
        #10;
        if (result_test == 32'd1 && zero_flag_test == 1'b0) 
            $display("SRL Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        
        // TEST SRA (Shift Right Arithmetic)
        
        a_test = 32'd2;
        b_test = 32'd1;
        op_sel_test = 4'b0111; // SRA
        #10;
        if (result_test == 32'd1 && zero_flag_test == 1'b0) 
            $display("SRA Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        
        // TEST SLT (Set Less Than - Signed)
        
        a_test = 32'd2;
        b_test = 32'd12;
        op_sel_test = 4'b1000; // SLT
        #10;
        if (result_test == 32'd1 && zero_flag_test == 1'b0) 
            $display("SLT Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

    
        // TEST SLTU (Set Less Than - Unsigned)
    
        a_test = 32'd2;
        b_test = 32'd12;
        op_sel_test = 4'b1001; // SLTU
        #10;
        if (result_test == 32'd1 && zero_flag_test == 1'b0) 
            $display("SLTU Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);
        else 
            $display("TEST FAILED Result: a=%h, b=%h, result=%h, zero=%b", a_test, b_test, result_test, zero_flag_test);

        #50;
        $stop;
    end

endmodule