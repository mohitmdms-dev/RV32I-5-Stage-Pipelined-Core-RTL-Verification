module data_mem (
    //CONTROL INPUTS
    input logic clk, mem_write, mem_read,

    //DATA INPUTS
    input logic [31:0] addr,   //The memory address calculated by the ALU
    input [31:0] write_data    //The data we want to save, which comes from rd2

    //DATA OUTPUT
    output logic [31:0] read_data
);

logic [31:0] ram [255:0];

//READ LOGIC
assign read_data = (mem_read == 1'b1) ? ram[addr[31:2]] : 32'b0;

//WRITE LOGIC
always_ff @(posedge clk) begin
    if(mem_write == 1'b1) begin
    ram[addr[31:2]] <= write_data;
    end

end

endmodule