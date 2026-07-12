module forwarding_unit (

    //Inputs (from the older instructions in MEM and WB stages)
    input logic [4:0] rd_mem,
    input logic [4:0] rd_wb,
    input logic reg_write_mem, reg_write_wb,
    
    //Inputs (from the current instruction in the EX stage)
    input logic [4:0] rs1_ex,    //first source register
    input logic [4:0] rs2_ex,    //second source register

    //Outputs (Controls for two 3-to-1 MUXes in front of the ALU)
    output logic [1:0] forward_a, //Controls ALU Input 1
    output logic [1:0] forward_b  //Controls ALU Input 2

);

always_comb begin
    if (reg_write_mem == 1'b1 && rd_mem != 5'b0 && rd_mem == rs1_ex) begin  //EX HAZARD
        forward_a = 2'b10;
    end
    else if (reg_write_wb == 1'b1 && rd_wb != 0 && rd_wb == rs1_ex) begin //MEM HAZARD
        forward_a = 2'b01;
    end
    else forward_a = 2'b00;
end

always_comb begin
    if (reg_write_mem == 1'b1 && rd_mem != 5'b0 && rd_mem == rs2_ex) begin  //EX HAZARD
        forward_b = 2'b10;
    end
    else if (reg_write_wb == 1'b1 && rd_wb != 0 && rd_wb == rs2_ex) begin //MEM HAZARD
        forward_b = 2'b01;
    end
    else forward_b = 2'b00;
end

endmodule