module riscv_core (
    input logic clk,
    input logic rst_n
);

    // GLOBAL HAZARD WIRES
    
    logic stall;
    logic flush; 
    
    
    // STAGE 1: FETCH (F)
    
    logic [31:0] pc_F;
    logic [31:0] pc_plus4_F;
    logic [31:0] instr_F;
    logic [31:0] next_pc_F;
    
    // Branch control from Memory Stage
    logic        pcsel_M; 
    logic [31:0] target_addr_M;
    
    assign flush = pcsel_M; // If we branch, flush the instructions behind it

    mux2to1 #(32) pc_mux (
        .d0(pc_plus4_F),
        .d1(target_addr_M),
        .sel(pcsel_M),
        .y(next_pc_F)
    );

    pc_reg pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(~stall), 
        .d(next_pc_F),
        .q(pc_F)
    );

    adder pc_adder (
        .a(pc_F),
        .b(32'd4),
        .sum(pc_plus4_F)
    );

    instr_mem imem (
        .addr(pc_F),
        .instr(instr_F)
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
    
    logic [4:0]  rs1_D = instr_D[19:15];
    logic [4:0]  rs2_D = instr_D[24:20];
    logic [4:0]  rd_D  = instr_D[11:7];
    
    logic [31:0] rd1_D, rd2_D;
    logic [31:0] imm_ext_D;

    // Control Wires
    logic reg_write_D, mem_to_reg_D, mem_write_D, mem_read_D;
    logic branch_D, alu_src_D;
    logic [1:0] alu_op_D;

    control_unit ctrl_inst (
        .opcode(instr_D[6:0]),
        .reg_write(reg_write_D),
        .mem_to_reg(mem_to_reg_D),
        .mem_write(mem_write_D),
        .mem_read(mem_read_D),
        .branch(branch_D),
        .alu_src(alu_src_D),
        .alu_op(alu_op_D)
    );

    // Writeback Wires (From Stage 5)
    logic        reg_write_W;
    logic [4:0]  rd_W;
    logic [31:0] write_data_W;

    reg_file rf_inst (
        .clk(clk),
        .reg_write(reg_write_W),
        .rs1(rs1_D),
        .rs2(rs2_D),
        .rd(rd_W),
        .write_data(write_data_W),
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    imm_gen imm_inst (
        .instr(instr_D),
        .imm_ext(imm_ext_D)
    );


    // PIPELINE REGISTER 2: ID/EX
    
    logic reg_write_E, mem_to_reg_E, mem_write_E, mem_read_E;
    logic branch_E, alu_src_E;
    logic [1:0] alu_op_E;
    
    logic [31:0] pc_E, rd1_E, rd2_E, imm_ext_E;
    logic [4:0]  rs1_E, rs2_E, rd_E;
    logic [2:0]  funct3_E;
    logic        funct7_5_E;

    id_ex_reg id_ex_inst (
        .clk(clk),
        .rst_n(rst_n),
        .flush(stall || flush), // Flush EX if we stall or branch
        
        .reg_write_in(reg_write_D), .mem_to_reg_in(mem_to_reg_D),
        .mem_write_in(mem_write_D), .mem_read_in(mem_read_D),
        .branch_in(branch_D),       .alu_src_in(alu_src_D),
        .alu_op_in(alu_op_D),
        
        .pc_in(pc_D),               .rd1_in(rd1_D),
        .rd2_in(rd2_D),             .imm_ext_in(imm_ext_D),
        .rs1_in(rs1_D),             .rs2_in(rs2_D),
        .rd_in(rd_D),
        .funct3_in(instr_D[14:12]), .funct7_5_in(instr_D[30]),

        .reg_write_out(reg_write_E), .mem_to_reg_out(mem_to_reg_E),
        .mem_write_out(mem_write_E), .mem_read_out(mem_read_E),
        .branch_out(branch_E),       .alu_src_out(alu_src_E),
        .alu_op_out(alu_op_E),
        
        .pc_out(pc_E),               .rd1_out(rd1_E),
        .rd2_out(rd2_E),             .imm_ext_out(imm_ext_E),
        .rs1_out(rs1_E),             .rs2_out(rs2_E),
        .rd_out(rd_E),
        .funct3_out(funct3_E),       .funct7_5_out(funct7_5_E)
    );

    // Hazard Detection Unit
    hazard_detection hd_inst (
        .rs1_id(rs1_D),
        .rs2_id(rs2_D),
        .rd_ex(rd_E),
        .mem_read_ex(mem_read_E),
        .stall(stall)
    );

    
    // STAGE 3: EXECUTE (E)
    
    logic [2:0]  alu_ctrl_E;
    logic [31:0] alu_in1_E, alu_in2_mux_E, alu_in2_E;
    logic [31:0] alu_result_E;
    logic        zero_flag_E;
    logic [31:0] target_addr_E;

    // Forwarding Wires & Unit
    logic [1:0] forward_a, forward_b;
    
    // Wires from MEM stage needed for forwarding
    logic        reg_write_M;
    logic [4:0]  rd_M;
    logic [31:0] alu_result_M;

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
        .d0(alu_in2_mux_E),
        .d1(imm_ext_E),
        .sel(alu_src_E),
        .y(alu_in2_E)
    );

    alu_control alu_ctrl_inst (
        .alu_op(alu_op_E),
        .funct3(funct3_E),
        .funct7_5(funct7_5_E),
        .op_5(imm_ext_E[5]), // Bit 5 of instruction dictates R vs I type math
        .alu_ctrl(alu_ctrl_E)
    );

    alu alu_inst (
        .a(alu_in1_E),
        .b(alu_in2_E),
        .alu_ctrl(alu_ctrl_E),
        .result(alu_result_E),
        .zero(zero_flag_E)
    );

    branch_adder b_adder_inst (
        .pc_in(pc_E),
        .imm_in(imm_ext_E),
        .target_addr(target_addr_E)
    );


    // PIPELINE REGISTER 3: EX/MEM
    
    logic mem_to_reg_M, mem_write_M, mem_read_M, branch_M;
    logic [31:0] rd2_M;
    logic        zero_flag_M;

    ex_mem_reg ex_mem_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        .reg_write_in(reg_write_E), .mem_to_reg_in(mem_to_reg_E),
        .mem_write_in(mem_write_E), .mem_read_in(mem_read_E),
        .branch_in(branch_E),
        
        .alu_result_in(alu_result_E), .rd2_in(alu_in2_mux_E), // Pass forwarded data!
        .target_addr_in(target_addr_E), .zero_flag_in(zero_flag_E),
        .rd_in(rd_E),

        .reg_write_out(reg_write_M), .mem_to_reg_out(mem_to_reg_M),
        .mem_write_out(mem_write_M), .mem_read_out(mem_read_M),
        .branch_out(branch_M),
        
        .alu_result_out(alu_result_M), .rd2_out(rd2_M),
        .target_addr_out(target_addr_M), .zero_flag_out(zero_flag_M),
        .rd_out(rd_M)
    );

    
    // STAGE 4: MEMORY (M)

    logic [31:0] read_data_M;
    
    // Branch Logic (AND gate)
    assign pcsel_M = branch_M & zero_flag_M;

    data_mem dmem (
        .clk(clk),
        .mem_write(mem_write_M),
        .mem_read(mem_read_M),
        .addr(alu_result_M),
        .write_data(rd2_M),
        .read_data(read_data_M)
    );

    // PIPELINE REGISTER 4: MEM/WB
    
    logic mem_to_reg_W;
    logic [31:0] alu_result_W, read_data_W;

    mem_wb_reg mem_wb_inst (
        .clk(clk),
        .rst_n(rst_n),
        
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
        .d0(alu_result_W),
        .d1(read_data_W),
        .sel(mem_to_reg_W),
        .y(write_data_W)
    );

endmodule