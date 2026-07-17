module divider (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,      // triggers division
    input  logic [31:0] dividend,
    input  logic [31:0] divisor,

    output logic [31:0] quotient,
    output logic [31:0] remainder,
    output logic        ready,      // goes high when division is done
    output logic        div_by_zero // Flag for division by zero error
);

    //FSM
    typedef enum logic {
        IDLE = 1'b0,
        BUSY = 1'b1
    } state_t;

    state_t state;

    // Internal Registers
    logic [63:0] rq_reg;      // 64-bit Remainder/Quotient register
    logic [31:0] divisor_reg; 
    logic [5:0]  count;       // Counts 32 shifts

    // Combinatorial logic for the math (forces clean synthesis)
    logic [63:0] shifted_rq;
    logic [31:0] sub_result;
    
    // Always calculate the shifted value and the subtraction result
    assign shifted_rq = rq_reg << 1;
    assign sub_result = shifted_rq[63:32] - divisor_reg;    

    // FSM and Datapath (single block forces the synthesizer to place a physical D-Flip-Flop at every single update)
    //and shorter critical path (faster Fmax)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            rq_reg      <= 64'b0;
            divisor_reg <= 32'b0;
            count       <= 6'b0;
            ready       <= 1'b0;
            div_by_zero <= 1'b0;
            quotient    <= 32'b0;
            remainder   <= 32'b0;
        end 
        else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    
                    if (start) begin
                        if (divisor == 32'b0) begin
                            // Handle Division by Zero instantly
                            div_by_zero <= 1'b1;
                            ready       <= 1'b1;
                            quotient    <= 32'hFFFF_FFFF; // RISC-V spec for div-by-zero
                            remainder   <= dividend;      // RISC-V spec for div-by-zero
                        end 
                        else begin
                            // Setup for normal division
                            div_by_zero <= 1'b0;
                            divisor_reg <= divisor;
                            rq_reg      <= {32'b0, dividend}; // upper 32 bits with zero
                            count       <= 6'b0;
                            state       <= BUSY;
                        end
                    end
                end

                BUSY: begin
                    if (count < 6'd32) begin
                        // Check if the subtraction would be positive/zero
                        if (shifted_rq[63:32] >= divisor_reg) begin
                            // It fits, Update upper half with subtraction, set lowest bit to 1
                            rq_reg <= {sub_result, shifted_rq[31:1], 1'b1};
                        end 
                        else begin
                            // It doesn't fit, Just keep the shifted value
                            rq_reg <= shifted_rq;
                        end
                        
                        count <= count + 6'd1;
                    end 
                    else begin
                        // Finished 32 cycles
                        quotient  <= rq_reg[31:0];
                        remainder <= rq_reg[63:32];
                        ready     <= 1'b1;
                        state     <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule