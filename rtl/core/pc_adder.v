module pc_adder #(
    parameter DATA_WIDTH = 32)(
        input logic [DATA_WIDTH-1:0] pc_in,  //CURRENT PC VALUE
        output logic [DATA_WIDTH-1:0] pc_out //NEXT PC VALUE

    );

assign pc_out = pc_in + 32'd4;

endmodule