//A  Small MIPSv2 Instruction Set

// LW rt, offset(rs)
// SW rt, offset(rs)
//I-Type Computational Instructions
// ADDIU rt, rs, signed-imm.
// SLTI rt, rs, signed-imm.
// SLTIU rt, rs, signed-imm.
// ANDI rt, rs, zero-ext-imm.
// ORI rt, rs, zero-ext-imm.
// XORI rt, rs, zero-ext-imm.
// LUI rt, zero-ext-imm.
//R-Type Computational Instructions
// SLL rd, rt, shamt
// SRL rd, rt, shamt
// SRA rd, rt, shamt
// SLLV rd, rt, rs
// SRLV rd, rt, rs
// SRAV rd, rt, rs
// ADDU rd, rs, rt
// SUBU rd, rs, rt
// AND rd, rs, rt
// OR rd, rs, rt
// XOR rd, rs, rt
// NOR rd, rs, rt
// SLT rd, rs, rt
// SLTU rd, rs, rt
//Jump and Branch Instructions
// J target
// JAL target
// JR rs
// JALR rd, rs
// BEQ rs, rt, offset
// BNE rs, rt, offset
// BLEZ rs, offset
// BGTZ rs, offset
// BLTZ rs, offset
// BGEZ rs, offset
//System Coprocessor (COP0) Instructions
//  MFC0 rt, rd
//  MTC0 rt, rd
