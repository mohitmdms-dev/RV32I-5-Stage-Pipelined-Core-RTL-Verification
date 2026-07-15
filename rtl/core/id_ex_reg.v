//register between instruction decode and execute phase

module id_ex_reg (
    input logic clk,
    input logic rst_n,
    input logic flush, // Flushes control signals to 0 to kill the instruction

    // Control Inputs
    input logic reg_write_in, mem_to_reg_in, mem_write_in, mem_read_in,
    input logic branch_in, alu_src_in, 
    input logic [2:0] alu_op_in,
    
    // Data Inputs
    input logic [31:0] pc_in, rd1_in, rd2_in, imm_ext_in,
    input logic [4:0]  rs1_in, rs2_in, rd_in, // Reg addresses for hazard detection later
    input logic [2:0]  funct3_in,
    input logic        funct7_5_in,
    // [BUGFIX]: Added op_5 to pipeline register. 
    // Bit 5 of the opcode is required in the Execute stage to differentiate 
    // between R-Type (e.g., SUB) and I-Type (e.g., ADDI) ALU operations.
    input logic        op_5_in,

    // Control Outputs
    output logic reg_write_out, mem_to_reg_out, mem_write_out, mem_read_out,
    output logic branch_out, alu_src_out,
    output logic [2:0] alu_op_out,
    
    // Data Outputs
    output logic [31:0] pc_out, rd1_out, rd2_out, imm_ext_out,
    output logic [4:0]  rs1_out, rs2_out, rd_out,
    output logic [2:0]  funct3_out,
    output logic        funct7_5_out,
    output logic        op_5_out    // Carries opcode bit 5 into Execute stage
);


always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            // Clear Control Signals
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            branch_out     <= 1'b0;
            alu_src_out    <= 1'b0;
            alu_op_out     <= 3'b000;
            
            // Clear Data/Address Signals
            pc_out         <= 32'b0;
            rd1_out        <= 32'b0;
            rd2_out        <= 32'b0;
            imm_ext_out    <= 32'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            funct3_out     <= 3'b0;
            funct7_5_out   <= 1'b0;
            op_5_out       <= 1'b0;
        end
        else if (flush == 1'b1) begin
            // Clear Control Signals (creates a NOP bubble)
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            branch_out     <= 1'b0;
            alu_src_out    <= 1'b0;
            alu_op_out     <= 3'b000;
            
            // Clear Data/Address Signals
            pc_out         <= 32'b0;
            rd1_out        <= 32'b0;
            rd2_out        <= 32'b0;
            imm_ext_out    <= 32'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            funct3_out     <= 3'b0;
            funct7_5_out   <= 1'b0;
            op_5_out       <= 1'b0;
        end
        else begin
            // Pass Inputs to Outputs
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            branch_out     <= branch_in;
            alu_src_out    <= alu_src_in;
            alu_op_out     <= alu_op_in;
            
            pc_out         <= pc_in;
            rd1_out        <= rd1_in;
            rd2_out        <= rd2_in;
            imm_ext_out    <= imm_ext_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            funct3_out     <= funct3_in;
            funct7_5_out   <= funct7_5_in;
            op_5_out       <= op_5_in;
        end
    end

endmodule