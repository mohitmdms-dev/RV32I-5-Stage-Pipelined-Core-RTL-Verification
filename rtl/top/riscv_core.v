module riscv_core (
    input logic clk,
    input logic rst_n,

    output logic [31:0] probe_out // Added to prevent optimization
);

    // GLOBAL HAZARD WIRES
    
    logic stall;
    logic flush; 
    
    
// STAGE 1: FETCH (F)
    
    logic [31:0] pc_F;        //current pc value
    logic [31:0] pc_plus4_F;  //default sequential next pc
    logic [31:0] instr_F;     //raw 32 bit instruction
    logic [31:0] next_pc_F;   //selected next pc output of pc_mux
    
    // Branch control from Memory Stage
    logic        pcsel_M;        //from the MEM stage
    logic [31:0] target_addr_M;  //destination address of a taken branch from MEM stage
    
    assign flush = take_branch_E; // Flush immediately when Execute stage says jump

    mux2to1 #(32) pc_mux (
        .in0(pc_plus4_F),
        .in1(target_addr_E),     // bug Fixed: Now pulling the target from Execute stage
        .sel(take_branch_E),     //changed from pcsel_M to Now using the gated decision from Execute stage
        .out(next_pc_F)
    );

    pc_register pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pc_en(~stall), 
        .pc_next(next_pc_F),
        .pc_current(pc_F)
    );

    pc_adder pc_adder_inst (
        .pc_in(pc_F),
        .pc_out(pc_plus4_F)
    );

    instr_mem imem (
        .a(pc_F),
        .rd(instr_F)
    );

    
    // PIPELINE REGISTER 1: IF/ID
    
    logic [31:0] pc_D;
    logic [31:0] instr_D;

    if_id_reg if_id_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(~stall),
        .flush(flush),
        .pc_in(pc_F),
        .instr_in(instr_F),
        .pc_out(pc_D),
        .instr_out(instr_D)
    );


// STAGE 2: DECODE (D)
    
    logic [4:0]  rs1_D;         //5bit register addresses extracted from instr_d  
    logic [4:0]  rs2_D;
    logic [4:0]  rd_D;

    assign rs1_D = instr_D[19:15];
    assign rs2_D = instr_D[24:20];
    assign rd_D  = instr_D[11:7];
    
    logic [31:0] rd1_D, rd2_D;     //data read from registerfile
    logic [31:0] imm_ext_D;

    // Control Wires
    logic reg_write_D, mem_to_reg_D, mem_write_D, mem_read_D;
    logic branch_D, alu_src_D;
    logic [2:0] alu_op_D;
    logic [2:0] imm_src_D;

    control_unit ctrl_inst (
        .opcode(instr_D[6:0]),
        .reg_write(reg_write_D),
        .mem_to_reg(mem_to_reg_D),
        .mem_write(mem_write_D),
        .mem_read(mem_read_D),
        .branch(branch_D),
        .alu_src(alu_src_D),
        .alu_op(alu_op_D),
        .imm_src(imm_src_D)
    );

    // Writeback Wires (From Stage 5)
    logic        reg_write_W;
    logic [4:0]  rd_W;
    logic [31:0] write_data_W;

    regfile rf_inst (
        .clk(clk),
        .write_en(reg_write_W),
        .a1(rs1_D),
        .a2(rs2_D),
        .a3(rd_W),
        .wd3(write_data_W),
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    imm_gen imm_inst (
        .instr(instr_D),
        .imm_src(imm_src_D),
        .imm_ext(imm_ext_D)
    );


    // PIPELINE REGISTER 2: ID/EX
    
    logic reg_write_E, mem_to_reg_E, mem_write_E, mem_read_E;
    logic branch_E, alu_src_E;
    logic [2:0] alu_op_E;
    
    logic [31:0] pc_E, rd1_E, rd2_E, imm_ext_E;
    logic [4:0]  rs1_E, rs2_E, rd_E;
    logic [2:0]  funct3_E;
    logic        funct7_5_E;

    logic funct7_0_E;    // Added: Bit 25 of the instruction, crucial for identifying MUL instructions

    id_ex_reg id_ex_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(~stall),   
        .flush((stall & ~is_mul_E & ~is_div_E) | flush),   //fix, prevent the register from flushing during ANY math stall
        
        .reg_write_in(reg_write_D), .mem_to_reg_in(mem_to_reg_D),
        .mem_write_in(mem_write_D), .mem_read_in(mem_read_D),
        .branch_in(branch_D),       .alu_src_in(alu_src_D),
        .alu_op_in(alu_op_D),
        
        .pc_in(pc_D),               .rd1_in(rd1_D),
        .rd2_in(rd2_D),             .imm_ext_in(imm_ext_D),
        .rs1_in(rs1_D),             .rs2_in(rs2_D),
        .rd_in(rd_D),
        .funct3_in(instr_D[14:12]), .funct7_5_in(instr_D[30]),
        .funct7_0_in(instr_D[25]),   //Connecting instruction bit 25
        .op_5_in(instr_D[5]),        //Extract bit 5 of the current instruction to send to Execute stage


        .reg_write_out(reg_write_E), .mem_to_reg_out(mem_to_reg_E),
        .mem_write_out(mem_write_E), .mem_read_out(mem_read_E),
        .branch_out(branch_E),       .alu_src_out(alu_src_E),
        .alu_op_out(alu_op_E),
        
        .pc_out(pc_E),               .rd1_out(rd1_E),
        .rd2_out(rd2_E),             .imm_ext_out(imm_ext_E),
        .rs1_out(rs1_E),             .rs2_out(rs2_E),
        .rd_out(rd_E),
        .funct3_out(funct3_E),       .funct7_5_out(funct7_5_E),
        .funct7_0_out(funct7_0_E),    // Passing the bit 25 status to the Execute stage
        .op_5_out(op_5_E)
    );

    // Hazard Detection Unit
    hazard_detection hd_inst (
        .rs1_id(rs1_D),
        .rs2_id(rs2_D),
        .rd_ex(rd_E),
        .mem_read_ex(mem_read_E),
        .stall(hd_stall)   
    );

    
// STAGE 3: EXECUTE (E)
    
    logic [3:0]  alu_ctrl_E;
    logic [31:0] alu_in1_E, alu_in2_mux_E, alu_in2_E;
    logic [31:0] alu_result_E;
    logic        zero_flag_E;
    logic [31:0] target_addr_E;
    logic        take_branch_E;

    // Forwarding Wires & Unit
    logic [1:0] forward_a, forward_b;
    wire op_5_E; 
    // Wires from MEM stage needed for forwarding
    logic        reg_write_M;
    logic [4:0]  rd_M;
    logic [31:0] alu_result_M;
    
    // Divider control signals
    logic div_start;
    logic [31:0] div_quotient;
    logic [31:0] div_remainder;
    logic div_by_zero;

    // Multiplier control signals
    logic mult_start;
    logic [31:0] mult_result;
    
    // Wires for module readiness
    logic mult_ready;
    logic div_ready;
    
    // Identify if the instructions in the Execute stage are MUL or DIV
    wire is_mul_E = (funct7_0_E == 1'b1) && (funct3_E == 3'b000) && (op_5_E == 1'b1);
    wire is_div_E = (funct7_0_E == 1'b1) && (funct3_E == 3'b100) && (op_5_E == 1'b1);
    
    // State flip-flop to track if the multiplier is currently running
    logic mul_busy;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) mul_busy <= 1'b0;
        else if (is_mul_E && !mult_ready) mul_busy <= 1'b1;
        else if (mult_ready) mul_busy <= 1'b0;
    end

    // State flip-flop to track if the divider is currently running
    logic div_busy;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) div_busy <= 1'b0;
        else if (is_div_E && !div_ready) div_busy <= 1'b1;
        else if (div_ready) div_busy <= 1'b0;
    end

    // Only send a 1-cycle START pulse on the very first cycle
    assign div_start = is_div_E & ~div_busy;

    // Only send a 1-cycle START pulse on the very first cycle
    assign mult_start = is_mul_E & ~mul_busy;
    
    // STALL LOGIC: Force global stall if ANY math unit is computing
    wire force_math_stall = (is_mul_E & ~mult_ready) | (is_div_E & ~div_ready);
    assign stall = hd_stall | force_math_stall;

    logic [31:0] final_execute_result;    // for final chosen result

    // The MUX: Choose between MUL, DIV, or standard ALU
    assign final_execute_result = is_mul_E ? mult_result : is_div_E ? div_quotient : alu_result_E;
    multiplier mult_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(mult_start),
        .multiplicand(alu_in1_E),
        .multiplier(alu_in2_mux_E), // Use the forwarded data
        .result(mult_result),
        .ready(mult_ready)
    );

    divider div_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(div_start),
        .dividend(alu_in1_E),
        .divisor(alu_in2_mux_E), // Use the forwarded data
        .quotient(div_quotient),
        .remainder(div_remainder),
        .ready(div_ready),
        .div_by_zero(div_by_zero)
    );

    forwarding_unit fwd_inst (
        .rd_mem(rd_M),
        .rd_wb(rd_W),
        .reg_write_mem(reg_write_M),
        .reg_write_wb(reg_write_W),
        .rs1_ex(rs1_E),
        .rs2_ex(rs2_E),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Forwarding MUX A (3-to-1)
    assign alu_in1_E = (forward_a == 2'b10) ? alu_result_M :
                       (forward_a == 2'b01) ? write_data_W : rd1_E;

    // Forwarding MUX B (3-to-1)
    assign alu_in2_mux_E = (forward_b == 2'b10) ? alu_result_M :
                           (forward_b == 2'b01) ? write_data_W : rd2_E;

    // ALU Src MUX (Chooses between Reg/Forward data vs Immediate)
    mux2to1 #(32) alu_src_mux (
        .in0(alu_in2_mux_E),
        .in1(imm_ext_E),
        .sel(alu_src_E),
        .out(alu_in2_E)
    );

    alu_control alu_ctrl_inst (
        .alu_op(alu_op_E),
        .funct3(funct3_E),
        .funct7_5(funct7_5_E),
        // FIX, Must use the actual instruction's opcode bit (op_5_E), 
        // The immediate and NOT the sign-extended immediate (imm_ext_E[5]) 
        // defaults to 0 for R-Type instructions, which previously forced 
        // all SUBs to execute as ADDs.
        .op_5(op_5_E), 
        .alu_ctrl(alu_ctrl_E)
    );

    alu alu_inst (
        .a(alu_in1_E),
        .b(alu_in2_E),
        .op_sel(alu_ctrl_E),
        .result(alu_result_E),
        .zero_flag(zero_flag_E)
    );

    branch_eval b_eval_inst (
        .a(alu_in1_E),
        .b(alu_in2_mux_E), // Use the forwarded input
        .funct3(funct3_E),
        .branch_E(branch_E),
        .take_branch(take_branch_E)
    );

    branch_adder b_adder_inst (
        .pc_in(pc_E),
        .imm_in(imm_ext_E),
        .target_addr(target_addr_E)
    );


    // PIPELINE REGISTER 3: EX/MEM
    
    logic mem_to_reg_M, mem_write_M, mem_read_M, branch_M, take_branch_M;
    logic [31:0] rd2_M;
    logic        zero_flag_M;
    logic [2:0]  funct3_M;      // ADDED: Wire to hold funct3 in the Memory stage
    
    ex_mem_reg ex_mem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(1'b1),        // EX/MEM: Always advance (en=1'b1), but bubble control signals when math unit is busy
        
        .reg_write_in(reg_write_E & ~force_math_stall), // Inject bubble
        .mem_to_reg_in(mem_to_reg_E),
        .mem_write_in(mem_write_E & ~force_math_stall), // Inject bubble
        .mem_read_in(mem_read_E),
        .branch_in(branch_E),    //fix, If this is a MUL instruction, ONLY allow writing if mult_ready is true
        
        .alu_result_in(final_execute_result), 
        .rd2_in(alu_in2_mux_E),
        .target_addr_in(target_addr_E), 
        .take_branch_in(take_branch_E),
        .rd_in(rd_E),
        .funct3_in(funct3_E), // ADDED: Input from Execute stage

        .reg_write_out(reg_write_M), .mem_to_reg_out(mem_to_reg_M),
        .mem_write_out(mem_write_M), .mem_read_out(mem_read_M),
        .branch_out(branch_M),
        
        .alu_result_out(alu_result_M), 
        .rd2_out(rd2_M),
        .target_addr_out(target_addr_M), 
        .take_branch_out(take_branch_M), 
        .rd_out(rd_M),
        .funct3_out(funct3_M) // ADDED: Output to Memory stage
    );

    
// STAGE 4: MEMORY (M)

    logic [31:0] read_data_M;
    
    // Branch Logic (AND)
    assign pcsel_M = branch_M & take_branch_M;

    data_mem dmem (
        .clk(clk),
        .mem_write(mem_write_M),
        .mem_read(mem_read_M),
        .addr(alu_result_M),
        .write_data(rd2_M),
        .funct3(funct3_M),   // ADDED: Pass funct3 to data memory
        .read_data(read_data_M)
    );

    // PIPELINE REGISTER 4: MEM/WB
    
    logic mem_to_reg_W;
    logic [31:0] alu_result_W, read_data_W;

    mem_wb_reg mem_wb_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(1'b1),  // MEM/WB: Always advance (en=1'b1), just pass through whatever exits EX/MEM
        
        .reg_write_in(reg_write_M),
        .mem_to_reg_in(mem_to_reg_M),
        
        .alu_result_in(alu_result_M),
        .read_data_in(read_data_M),
        .rd_in(rd_M),

        .reg_write_out(reg_write_W),
        .mem_to_reg_out(mem_to_reg_W),
        
        .alu_result_out(alu_result_W),
        .read_data_out(read_data_W),
        .rd_out(rd_W)
    );

// STAGE 5: WRITEBACK (W)
    
    mux2to1 #(32) wb_mux (
        .in0(alu_result_W),
        .in1(read_data_W),
        .sel(mem_to_reg_W),
        .out(write_data_W)
    );

    // Feed the final data to the output for Yosys to builds the CPU
    assign probe_out = write_data_W;
endmodule