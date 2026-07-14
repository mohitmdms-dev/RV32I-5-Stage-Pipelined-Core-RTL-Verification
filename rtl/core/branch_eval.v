module branch_eval (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  funct3,
    output logic        take_branch
);

    always_comb begin
        case (funct3)
            3'b000: take_branch = (a == b); // BEQ
            3'b001: take_branch = (a != b); // BNE
            3'b100: take_branch = ($signed(a) < $signed(b));  // BLT  (branch if less than)
            3'b101: take_branch = ($signed(a) >= $signed(b)); // BGE  (branch if greater than or equal)
            3'b110: take_branch = (a < b);                    // BLTU (branch if less than unsigned)
            3'b111: take_branch = (a >= b);                   // BGEU (branch if greater than or equal unsigned )
            default: take_branch = 1'b0;
        endcase
    end
endmodule