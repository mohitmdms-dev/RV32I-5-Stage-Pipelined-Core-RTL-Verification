module hazard_detection (
    input logic clk, 
    input logic rst_n,

    // Inputs from Decode Stage (Current Instruction)
    input  logic [4:0] rs1_id,
    input  logic [4:0] rs2_id,
    
    // Inputs from Execute Stage (Previous Instruction)
    input  logic [4:0] rd_ex,
    input  logic       mem_read_ex,
    
    // Multiplier Hazard Inputs
    input logic       mult_start,
    input logic       mult_ready,

    // Output Control Signal
    output logic       stall
);

    logic load_stall;
    logic mult_stall;

    // Load-Use Hazard (Combinational - instant reaction)
    assign load_stall = mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id));

    // Multiplier Hazard (Sequential - remembers the state)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mult_stall <= 1'b0;
        end else if (mult_start) begin
            mult_stall <= 1'b1; // Start the stall
        end else if (mult_ready) begin
            mult_stall <= 1'b0; // End the stall when math finishes
        end
    end

    // The total stall is the combination of both hazards
    assign stall = load_stall || mult_stall;

endmodule