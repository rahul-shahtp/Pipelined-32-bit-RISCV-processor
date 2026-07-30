# test_mul.s -- M-extension: MUL, MULH, MULHSU, MULHU
#
# Expected final register state:
#   x3  = 0x0000002a (42)         mul   6*7
#   x6  = 0xffffffd2 (-42)        mul  -6*7
#   x9  = 0x10000000              mulh  0x40000000*0x40000000, upper 32 of signed 64-bit product
#   x12 = 0xfffffffe              mulhu 0xffffffff*0xffffffff, upper 32 of unsigned 64-bit product
#   x13 = 0x00000001              mul   (lower 32 of the same operands)
#   x16 = 0xffffffff              mulhsu -1 (signed) * 0xffffffff (unsigned), upper 32
.text
.globl _start
_start:
    addi x1, x0, 6
    addi x2, x0, 7
    mul  x3, x1, x2

    addi x4, x0, -6
    addi x5, x0, 7
    mul  x6, x4, x5

    lui  x7, 0x40000        # x7 = 0x40000000
    lui  x8, 0x40000        # x8 = 0x40000000
    mulh x9, x7, x8

    li   x10, 0xFFFFFFFF
    li   x11, 0xFFFFFFFF
    mulhu x12, x10, x11
    mul   x13, x10, x11

    addi x14, x0, -1        # x14 = 0xffffffff (signed -1)
    li   x15, 0xFFFFFFFF    # x15 = 0xffffffff (used as unsigned operand)
    mulhsu x16, x14, x15

    ebreak