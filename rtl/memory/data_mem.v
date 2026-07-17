module data_mem (
    //CONTROL INPUTS
    input logic clk, mem_write, mem_read,

    //DATA INPUTS
    input logic [31:0] addr,   //The memory address calculated by the ALU
    input logic [31:0] write_data,    //The data we want to save, which comes from rd2
    input  logic [2:0]  funct3,      // The new size/type selector

    //DATA OUTPUT
    output logic [31:0] read_data
);

logic [31:0] ram [255:0];

// Helper wire to grab the 32-bit row address
wire [29:0] word_addr = addr[31:2];

logic [31:0] full_word;
//READ LOGIC
assign full_word = ram[word_addr]; // Grab the full 32-bit row first

always_comb begin
        if (mem_read == 1'b1) begin
            case (funct3)
                // LB (Load Byte - Sign Extended)
                3'b000: begin 
                    case (addr[1:0])
                        2'b00: read_data = {{24{full_word[7]}},  full_word[7:0]};
                        2'b01: read_data = {{24{full_word[15]}}, full_word[15:8]};
                        2'b10: read_data = {{24{full_word[23]}}, full_word[23:16]};
                        2'b11: read_data = {{24{full_word[31]}}, full_word[31:24]};
                    endcase
                end
                
                // LH (Load Halfword - Sign Extended)
                3'b001: begin 
                    case (addr[1])
                        1'b0: read_data = {{16{full_word[15]}}, full_word[15:0]};
                        1'b1: read_data = {{16{full_word[31]}}, full_word[31:16]};
                    endcase
                end
                
                // LW (Load Word)
                3'b010: begin 
                    read_data = full_word;
                end
                
                // LBU (Load Byte Unsigned - Zero Extended)
                3'b100: begin 
                    case (addr[1:0])
                        2'b00: read_data = {24'b0, full_word[7:0]};
                        2'b01: read_data = {24'b0, full_word[15:8]};
                        2'b10: read_data = {24'b0, full_word[23:16]};
                        2'b11: read_data = {24'b0, full_word[31:24]};
                    endcase
                end
                
                // LHU (Load Halfword Unsigned - Zero Extended)
                3'b101: begin 
                    case (addr[1])
                        1'b0: read_data = {16'b0, full_word[15:0]};
                        1'b1: read_data = {16'b0, full_word[31:16]};
                    endcase
                end
                
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

//WRITE LOGIC
    
always_ff @(posedge clk) begin
    if(mem_write == 1'b1) begin
            case (funct3)
            // SB (Store Byte)
                3'b000: begin
                    case (addr[1:0])
                        2'b00: ram[word_addr][7:0]   <= write_data[7:0];
                        2'b01: ram[word_addr][15:8]  <= write_data[7:0];
                        2'b10: ram[word_addr][23:16] <= write_data[7:0];
                        2'b11: ram[word_addr][31:24] <= write_data[7:0];
                    endcase
                end
                
            // SH (Store Halfword)
                3'b001: begin
                    case (addr[1])
                        1'b0: ram[word_addr][15:0]  <= write_data[15:0];
                        1'b1: ram[word_addr][31:16] <= write_data[15:0];
                    endcase
                end
                
            // SW (Store Word)
                3'b010: begin
                    ram[word_addr] <= write_data;
                end
            endcase
        end
    end

endmodule