module hazard_detection (
    // Inputs from Decode Stage (Current Instruction)
    input  logic [4:0] rs1_id,
    input  logic [4:0] rs2_id,
    
    // Inputs from Execute Stage (Previous Instruction)
    input  logic [4:0] rd_ex,
    input  logic       mem_read_ex,
    
    // Output Control Signal
    output logic       stall
);

    always_comb begin
        // If the instruction ahead of us is a LOAD, and it is loading into 
        // a register we are about to use, we MUST freeze (stall) for one cycle.
        if (mem_read_ex == 1'b1 && (rd_ex == rs1_id || rd_ex == rs2_id)) begin
            stall = 1'b1;
        end
        else begin
            stall = 1'b0;
        end
    end

endmodule