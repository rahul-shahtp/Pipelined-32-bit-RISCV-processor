# test_rtype.s -- R-type ALU ops: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
#
# Expected final register state:
#   x3  = 0x00000012 (18)         add x1(15)+x2(3)
#   x4  = 0x0000000c (12)         sub x1-x2
#   x5  = 0x00000003 (3)          and x1&x2
#   x6  = 0x0000000f (15)         or  x1|x2
#   x7  = 0x0000000c (12)         xor x1^x2
#   x8  = 0x00000078 (120)        sll x1<<x2  (15<<3)
#   x9  = 0x00000001 (1)          srl x1>>x2  (15>>3, logical)
#   x10 = 0xffffffff (-1)         sra x11(-8)>>x2(3) arithmetic
#   x12 = 0x00000001 (1)          slt  x2<x1 -> 3<15 true
#   x13 = 0x00000000 (0)          sltu x1<x2 -> 15<3 unsigned false
.text
.globl _start
_start:
    addi x1, x0, 15        # x1 = 15
    addi x2, x0, 3         # x2 = 3
    addi x11, x0, -8       # x11 = -8 (0xfffffff8), operand for SRA

    add  x3, x1, x2
    sub  x4, x1, x2
    and  x5, x1, x2
    or   x6, x1, x2
    xor  x7, x1, x2
    sll  x8, x1, x2
    srl  x9, x1, x2
    sra  x10, x11, x2
    slt  x12, x2, x1
    sltu x13, x1, x2

    ebreak