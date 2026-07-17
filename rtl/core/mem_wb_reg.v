// mem/write back pipeline register

module mem_wb_reg (
    input logic clk,
    input logic rst_n,
    
    // Control Inputs
    input logic reg_write_in,
    input logic mem_to_reg_in,
    
    // Data Inputs
    input logic [31:0] alu_result_in,
    input logic [31:0] read_data_in,
    input logic [4:0]  rd_in,

    // Control Outputs
    output logic reg_write_out,
    output logic mem_to_reg_out,
    
    // Data Outputs
    output logic [31:0] alu_result_out,
    output logic [31:0] read_data_out,
    output logic [4:0]  rd_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear all signals on reset
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_result_out <= 32'b0;
            read_data_out  <= 32'b0;
            rd_out         <= 5'b0;
        end
        else begin
            // Pass signals forward to the Writeback stage
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_result_out <= alu_result_in;
            read_data_out  <= read_data_in;
            rd_out         <= rd_in;
        end
    end

endmodule