
module imm_gen #(
    parameter DATA_WIDTH = 32 )
    (
    input  logic [DATA_WIDTH-1:0] instr,
    input logic [2:0] imm_src,     //The Control Unit will send this 3-bit code to tell the Immediate Generator which format to untangle: I-type, S-type, B-type, U-type, or J-type
    
    output logic [DATA_WIDTH-1:0] imm_ext
);


always_comb begin
    case(imm_src)
    3'b000: imm_ext = {{20{instr[31]}},instr[31:20]};                                 //I-Type (Loads, ADDI)
    3'b001: imm_ext = {{20{instr[31]}},instr[31:25],instr[11:7]};                     //S-Type (Stores)
    3'b010: imm_ext = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};       //B-Type (Branches)
    3'b011: imm_ext = {instr[31:12],12'b0};                                         //U-Type (LUI, AUIPC)
    3'b100: imm_ext = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0}; //J-Type (Jumps - JAL)
    default: imm_ext = 32'b0;               
    endcase  
end

endmodule
