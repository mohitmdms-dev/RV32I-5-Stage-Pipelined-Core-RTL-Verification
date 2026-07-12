module alu_control (
    input  logic [1:0] alu_op,     
    input  logic [2:0] funct3,     // bits [14:12]
    input  logic       funct7_5,   // bit [30] add/sub
    input  logic       op_5,       // bit [5]  RType(1) or IType(0)
    output logic [2:0] alu_ctrl    // final command sent to alu 
);

    always_comb begin
        if (alu_op == 2'b00) begin
            alu_ctrl = 3'b010;     // LOAD/STORE -> ADD
        end 
        else if (alu_op == 2'b01) begin
            alu_ctrl = 3'b110;     // BRANCH -> SUB
        end 
        else if (alu_op == 2'b10) begin
            // R-TYPE or I-TYPE MATH
            case (funct3)
                3'b000: begin
                    // It is SUBTRACT only if it's an R-type AND bit 30 is 1
                    if (funct7_5 == 1'b1 && op_5 == 1'b1) 
                        alu_ctrl = 3'b110; // SUB
                    else 
                        alu_ctrl = 3'b010; // ADD
                end
                3'b111:  alu_ctrl = 3'b000; // AND
                3'b110:  alu_ctrl = 3'b001; // OR
                default: alu_ctrl = 3'b000; // Safe default
            endcase
        end 
        else begin
            alu_ctrl = 3'b000;     // Safe default for the whole block
        end
    end

endmodule