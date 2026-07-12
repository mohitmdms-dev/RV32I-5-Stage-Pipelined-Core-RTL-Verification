module branch_adder #(parameter DATA_WIDTH = 32)(
    input logic [DATA_WIDTH-1:0] pc_in,
    input logic [DATA_WIDTH-1:0] imm_in,
    output logic [DATA_WIDTH-1:0] target_addr
);

assign target_addr = pc_in + imm_in;

endmodule