module alu_control (
    input  logic [2:0] alu_op,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       op_5,      // Bit 5 of the instruction opcode (1 for R-type, 0 for I-type)

    output logic [3:0] alu_ctrl   // 4-bit output to support all RISC-V operations
);

    always_comb begin
        case (alu_op)
            
            // Memory (Load/Store) -> Always ADD the base address and offset
            3'b000: alu_ctrl = 4'b0000; 
            
            // Branches -> Always SUBTRACT to compare the two registers
            3'b001: alu_ctrl = 4'b1000; 

            // R-Type or I-Type Math Operations
            3'b010, 3'b011: begin
                case (funct3)
                    
                    // ADD or SUB
                    3'b000: begin
                        // It is ONLY a SUB if it's an R-Type instruction AND the modifier bit is 1.
                        // I-Type (ADDI) is ALWAYS an ADD, regardless of the modifier bit.
                        if (op_5 == 1'b1 && funct7_5 == 1'b1) 
                            alu_ctrl = 4'b1000; // SUB
                        else 
                            alu_ctrl = 4'b0000; // ADD
                    end

                    3'b001: alu_ctrl = 4'b0001; // SLL  (Shift Left Logical)
                    3'b010: alu_ctrl = 4'b0010; // SLT  (Set Less Than - Signed)
                    3'b011: alu_ctrl = 4'b0011; // SLTU (Set Less Than - Unsigned)
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    
                    // SRL or SRA
                    3'b101: begin
                        // The modifier bit determines Logical vs Arithmetic shift.
                        // This applies to BOTH R-Type and I-Type shifts!
                        if (funct7_5 == 1'b1)
                            alu_ctrl = 4'b1101; // SRA (Shift Right Arithmetic)
                        else
                            alu_ctrl = 4'b0101; // SRL (Shift Right Logical)
                    end
                    
                    3'b110: alu_ctrl = 4'b0110; // OR
                    3'b111: alu_ctrl = 4'b0111; // AND
                    
                    default: alu_ctrl = 4'b0000; // Default to ADD
                endcase
            end

            // Default safe fallback
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule