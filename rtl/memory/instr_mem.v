module instr_mem (
    input logic [31:0] a,
    output logic [31:0] rd 
);

    logic [31:0] rom [255:0];

    assign rd = rom[a[31:2]];

endmodule