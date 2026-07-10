// rtl/riscv_pkg.sv
// Shared parameters, opcode/funct3 defines, typedefs used across RTL modules
//
// TODO: define opcode map, funct3/funct7 encodings, CSR addresses, pipeline widths

package riscv_pkg;

  // Opcodes (fill in from docs/project_charter.md section 4.1)
  parameter logic [6:0] OPC_RTYPE = 7'b0110011;
  parameter logic [6:0] OPC_ITYPE = 7'b0010011;
  // TODO: remaining opcodes

endpackage
