module pc_register #(
    parameter DATA_WIDTH =32
)(
    input logic clk,
    input logic rst_n,
    input logic pc_en,
    input logic [DATA_WIDTH-1:0] pc_next,
    output logic [DATA_WIDTH-1:0] pc_current
);

always_ff @(posedge clk or negedge rst_n) begin
    if(rst_n == 0) pc_current <= {DATA_WIDTH{1'b0}};
    else if (pc_en == 1) pc_current <= pc_next;
end

endmodule