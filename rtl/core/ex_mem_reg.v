//EX/MEM PIPELINE REGISTER

module ex_mem_reg (
    input logic clk,
    input logic rst_n,

    // Control Inputs
    input logic reg_write_in, mem_to_reg_in, mem_write_in, mem_read_in, branch_in,
    
    // Data Inputs
    input logic [31:0] alu_result_in, rd2_in, target_addr_in,
    input logic        zero_flag_in,
    input logic [4:0]  rd_in,

    // Control Outputs
    output logic reg_write_out, mem_to_reg_out, mem_write_out, mem_read_out, branch_out,
    
    // Data Outputs
    output logic [31:0] alu_result_out, rd2_out, target_addr_out,
    output logic        zero_flag_out,
    output logic [4:0]  rd_out
   
);

always_ff @(posedge clk or negedge rst_n) begin

        if (rst_n == 1'b0) begin
            // Clear Control Signals
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            branch_out     <= 1'b0;
            
            // Clear Data and Flags
            alu_result_out  <= 32'b0;
            rd2_out         <= 32'b0;
            target_addr_out <= 32'b0;
            zero_flag_out   <= 1'b0;
            rd_out          <= 5'b0;
        end
        else begin
            // Pass Inputs to Outputs
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            branch_out     <= branch_in;
            
            alu_result_out  <= alu_result_in;
            rd2_out         <= rd2_in;
            target_addr_out <= target_addr_in;
            zero_flag_out   <= zero_flag_in;
            rd_out          <= rd_in;
        end    


end

endmodule