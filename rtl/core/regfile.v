
module regfile #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic write_en,
    input logic [4:0] a1,
    input logic [4:0] a2,
    input logic [4:0] a3,
    input logic [DATA_WIDTH-1:0] wd3,
    
    output logic [DATA_WIDTH-1:0] rd1,
    output logic [DATA_WIDTH-1:0] rd2
);

logic [DATA_WIDTH-1:0] mem_array [31:0];

//ASNYCHRONOUS READ LOGIC
    // RISC-V Architecture Rule: Register x0 must always read as 0.
    // The ternary operator (?) checks if the address is 0. If true, it 
    // outputs all zeros. If false, it outputs the data stored in the array
    // If reading the register that is currently being written, bypass the memory
    // and output wd3 directly. Otherwise, read from the memory array
    assign rd1 = (a1 == 5'b0) ? {DATA_WIDTH{1'b0}} : (write_en && (a1 == a3)) ? wd3 : mem_array[a1];
    assign rd2 = (a2 == 5'b0) ? {DATA_WIDTH{1'b0}} : (write_en && (a2 == a3)) ? wd3 : mem_array[a2];


// SYNCHRONOUS WRITE LOGIC
   //only save data if the Control Unit tells us to (write_en == 1)
   //make sure we never accidentally overwrite register x0
always_ff @(posedge clk) begin
    if(write_en == 1'b1 && a3 !=5'b0) begin
        mem_array[a3] <= wd3;
    end
end

endmodule
