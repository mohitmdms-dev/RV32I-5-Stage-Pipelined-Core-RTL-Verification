module branch_eval (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic branch_E,
    input  logic [2:0]  funct3,
    output logic        take_branch
);

logic eval_result;
    always_comb begin
        case (funct3)
            3'b000: eval_result = (a == b); // BEQ
            3'b001: eval_result = (a != b); // BNE
            3'b100: eval_result = ($signed(a) < $signed(b));  // BLT  (branch if less than)
            3'b101: eval_result = ($signed(a) >= $signed(b)); // BGE  (branch if greater than or equal)
            3'b110: eval_result = (a < b);                    // BLTU (branch if less than unsigned)
            3'b111: eval_result = (a >= b);                   // BGEU (branch if greater than or equal unsigned )
            default: eval_result = 1'b0;
        endcase
        take_branch = eval_result & branch_E;
    end
endmodule