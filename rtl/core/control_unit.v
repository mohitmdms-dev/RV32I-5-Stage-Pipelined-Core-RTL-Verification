module control_unit (
    input logic [6:0] opcode,

    output logic branch,            //1 if it's a Branch instruction, 0 otherwise
    output logic mem_read,          //1 if we are reading Data Memory, e.g., LOAD
    output logic mem_write,         //1 if we are writing Data Memory, e.g., STORE
    output logic mem_to_reg,        //1 if we are saving memory data to a register, 0 if saving ALU data
    output logic alu_src,           //1 if the ALU uses the Immediate Generator, 0 if it uses Register 2
    output logic reg_write,         //1 if we are saving a result to the Register File

    output logic [2:0] alu_op       //Tells a secondary ALU decoder what type of math to do. 00 for Add, 01 for Branch/Sub, 10 for R-type/I-type math 
);          

// RISC-V RV32I Opcodes
    localparam [6:0] 
        OP_R_TYPE  = 7'b0110011, // ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND
        OP_I_TYPE  = 7'b0010011, // ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        OP_LOAD    = 7'b0000011, // LW, LH, LB
        OP_STORE   = 7'b0100011, // SW, SH, SB
        OP_BRANCH  = 7'b1100011; // BEQ, BNE, BLT, BGE
        

always_comb begin

    case(opcode)

    OP_R_TYPE: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;       //USE REG2, NOT IMMEDIATE
        reg_write  = 1'b1;       //SAVE THE MATH RESULT
        alu_op     = 2'b10;      //R-TYPE MATH
    end

    OP_I_TYPE: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b1;       //USE IMMEDIATE
        reg_write  = 1'b1;       //SAVE THE MATH RESULT
        alu_op     = 2'b10;      //MATH
    end

    OP_LOAD: begin
        branch     = 1'b0;
        mem_read   = 1'b1;       //Turn on the memory read port
        mem_write  = 1'b0;
        mem_to_reg = 1'b1;       //Route the memory output to the Register File
        alu_src    = 1'b1;       //Feed the Immediate Generator into the ALU for the offset
        reg_write  = 1'b1;       //Turn on the Register File write enable
        alu_op     = 2'b00;       //Force the ALU to ADD
    end

    OP_STORE: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b1;        //Turn on the memory write port
        mem_to_reg = 1'b0;        //Doesn't matter, we aren't saving to a register, so default to 0
        alu_src    = 1'b1;        //Feed the Immediate Generator into the ALU for the offset
        reg_write  = 1'b0;        //Do not overwrite a register
        alu_op     = 2'b00;        //Force the ALU to ADD
    end

    OP_BRANCH: begin
        branch     = 1'b1;        //Tell the branch AND gate to listen to the ALU's zero flag
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;        //Feed Register 2 into the ALU so we can compare it with Register 1
        reg_write  = 1'b0;        //Do not write to a register
        alu_op     = 2'b01;        //Force the ALU to SUBTRACT to evaluate the comparison
    end

    default: begin
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        reg_write  = 1'b0;
        alu_op     = 2'b00;
    end

    endcase
end

endmodule