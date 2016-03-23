# ring_network-based-multicore-
多核处理器 ;scalable ring network , four core, shared space memory ,directory-based cache coherency


Hello, everyone, this is a project from theory to practice. I would like to use this project to test the results of my study, and I am very pleased that some of friends with the common interest can actively communicate with me and learn from each other. In this project, I implemented a number issues in the simple processor  and explored some of the issues about cache consistency. I achieve Processor by using a simple five stage pipeline with simple branch prediction including BTB，RAS and BHT, instruction set is SMIPSv2 which could be found from the MIT courses resources or common.v file in the project. as for memory system part,I implement the directory ,which is supported by corresponding protocals, to achieve cache consistency rather than the bus. In order to make programming easier, I used a shared address space memory. In order to reduce the critical messages delay between cache and its parent cache  , I used the reply-forwarding protocal,whose details,however, is inspired by the MIT materias for computer architecture material. In the end, I am very grateful if you would make a good suggestion to improve my project! It is a work-in-progress and remains in active development.
I will try my best to make implemente the project well!

A  SMIPSv2 Instruction Set

 LW rt, oset(rs)
 SW rt, oset(rs)
I-Type Computational Instructions
 ADDIU rt, rs, signed-imm.
 SLTI rt, rs, signed-imm.
 SLTIU rt, rs, signed-imm.
 ANDI rt, rs, zero-ext-imm.
 ORI rt, rs, zero-ext-imm.
 XORI rt, rs, zero-ext-imm.
 LUI rt, zero-ext-imm.
R-Type Computational Instructions
 SLL rd, rt, shamt
 SRL rd, rt, shamt
 SRA rd, rt, shamt
 SLLV rd, rt, rs
 SRLV rd, rt, rs
 SRAV rd, rt, rs
 ADDU rd, rs, rt
 SUBU rd, rs, rt
 AND rd, rs, rt
 OR rd, rs, rt
 XOR rd, rs, rt
 NOR rd, rs, rt
 SLT rd, rs, rt
 SLTU rd, rs, rt
Jump and Branch Instructions
 J target
 JAL target
 JR rs
 JALR rd, rs
 BEQ rs, rt, oset
 BNE rs, rt, oset
 BLEZ rs, oset
 BGTZ rs, oset
 BLTZ rs, oset
 BGEZ rs, oset
System Coprocessor (COP0) Instructions
  MFC0 rt, rd
  MTC0 rt, rd
