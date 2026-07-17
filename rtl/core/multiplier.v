module multiplier (
    input logic        clk,
    input logic       rst_n,
    input logic       start,     //triggers multiplication
    input logic [31:0] multiplicand,
    input logic [31:0] multiplier,

    output logic [31:0] result,  //lower 32 bits of the product
    output logic ready    //goes high when multiplication is done

);

// FSM States
    typedef enum logic {
        IDLE = 1'b0,
        BUSY = 1'b1
    } state_t;

    state_t state, next_state;

// Internal Registers
    logic [31:0] mcand_reg;   // Holds the shifting multiplicand
    logic [31:0] mplier_reg;  // Holds the shifting multiplier
    logic [31:0] accumulator;
    logic [5:0]  count;       // Needs to count up to 32

// State Machine Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end
    end

// Next State Logic
    always_comb begin
        case (state)
            IDLE: begin
                if (start == 1'b1) 
                    next_state = BUSY;
                else 
                    next_state = IDLE;
            end
            BUSY: begin
                if (count == 6'd32) 
                    next_state = IDLE;
                else 
                    next_state = BUSY;
            end
            default: next_state = IDLE;
        endcase
    end

// Datapath (Shift and Add)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mcand_reg   <= 32'b0;
            mplier_reg  <= 32'b0;
            accumulator <= 32'b0;
            count       <= 6'b0;
            ready       <= 1'b0;
            result      <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        // Load the registers when 'start' is triggered
                        mcand_reg   <= multiplicand;
                        mplier_reg  <= multiplier;
                        accumulator <= 32'b0;
                        count       <= 6'b0;
                    end
                end

                BUSY: begin
                    if (count < 6'd32) begin
                        // If the lowest bit of the multiplier is 1, add the multiplicand
                        if (mplier_reg[0]) begin
                            accumulator <= accumulator + mcand_reg;
                        end
                        
                        // Shift multiplicand left, shift multiplier right
                        mcand_reg  <= mcand_reg << 1;
                        mplier_reg <= mplier_reg >> 1;
                        
                        count <= count + 1'b1;
                    end 
                    else begin
                        // Finished 32 cycles
                        result <= accumulator;
                        ready  <= 1'b1;
                    end
                end
            endcase
        end
    end

endmodule