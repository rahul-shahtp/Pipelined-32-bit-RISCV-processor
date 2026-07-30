# test_itype.s -- I-type immediates: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
#
# Expected final register state:
#   x2  = 0x0000000f (15)     addi x1+10
#   x3  = 0x00000001 (1)      slti  5<10 -> true
#   x4  = 0x00000000 (0)      sltiu 5<3  -> false
#   x5  = 0x0000000a (10)     xori 5^0xF
#   x6  = 0x0000000d (13)     ori  5|8
#   x7  = 0x00000001 (1)      andi 5&3
#   x8  = 0x00000014 (20)     slli 5<<2
#   x9  = 0x00000002 (2)      srli 5>>1
#   x11 = 0xfffffffb (-5)     srai -20>>2 (arithmetic, sign preserved)
#   x12 = 0xffffffff (-1)     addi 0 + (-1)
.text
.globl _start
_start:
    addi x1, x0, 5
    addi x2, x1, 10
    slti x3, x1, 10
    sltiu x4, x1, 3
    xori x5, x1, 0xF
    ori  x6, x1, 0x8
    andi x7, x1, 0x3
    slli x8, x1, 2
    srli x9, x1, 1

    addi x10, x0, -20
    srai x11, x10, 2
    addi x12, x0, -1

    ebreak