module hazard_detection (
    input logic clk, 
    input logic rst_n,

    // Inputs from Decode Stage (Current Instruction)
    input  logic [4:0] rs1_id,
    input  logic [4:0] rs2_id,
    
    // Inputs from Execute Stage (Previous Instruction)
    input  logic [4:0] rd_ex,
    input  logic mem_read_ex,

    // Output Control Signal
    output logic       stall
);

    // Load-Use Hazard (MUL/DIV stalling handled combinationally)
    assign stall = mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id));

endmodule