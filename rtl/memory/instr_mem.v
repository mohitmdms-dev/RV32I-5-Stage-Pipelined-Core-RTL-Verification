module instr_mem (
    input logic [31:0] a,
    output logic [31:0] rd 
);

logic [31:0] rom [255:0];

assign rd = rom[a[31:2]];

    // The synthesis tool will completely ignore anything inside this block
    `ifndef SYNTHESIS
    initial begin
        $readmemh("program.hex", rom); // This looks for a text file called "program.hex" in your simulation folder
    end
    `endif


endmodule