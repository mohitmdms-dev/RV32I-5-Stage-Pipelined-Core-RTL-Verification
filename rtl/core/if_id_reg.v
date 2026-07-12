// pipeline register between instruction fetch and decode

module if_id_reg(
    input logic clk,
    input logic rst_n,

    //hazard control inputs
    input logic en,                 //If 0, the register freezes (used to stall the pipeline)
    input logic flush,              //If 1, the register zeroes itself out (used when misprediction and need to throw away the instruction)
    input logic [31:0] pc_in,       //from IF
    input logic [31:0] instr_in,

    output logic [31:0] pc_out,     //to ID
    output logic [31:0] instr_out
);

always_ff @(posedge clk or negedge rst_n) begin
    
    if(rst_n == 1'b0) begin
        instr_out <= 32'b0;
        pc_out <= 32'b0;
    end
    else if(flush == 1) begin
        instr_out <= 32'b0;
        pc_out <= 32'b0;
    end
    else if(en == 1) begin
        pc_out <= pc_in;
        instr_out <= instr_in;
    end
end

endmodule