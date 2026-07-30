# test_loadstore.s -- LW/SW, LB/LBU, LH/LHU with sign-extension checks
#
# Expected final register state:
#   x3  = 0xdeadbeef           lw  after sw (word round-trip)
#   x5  = 0xffffff80 (-128)    lb  sign-extends 0x80
#   x6  = 0x00000080 (128)     lbu zero-extends 0x80
#   x8  = 0xffff8000 (-32768)  lh  sign-extends 0x8000
#   x9  = 0x00008000 (32768)   lhu zero-extends 0x8000
#   x11 = 0x0000007f (127)     lb  positive byte, no sign effect
#   x12 = 0x0000007f (127)     lbu same positive byte
.text
.globl _start
_start:
    addi x1, x0, 0x100      # scratch base address

    li   x2, 0xDEADBEEF
    sw   x2, 0(x1)
    lw   x3, 0(x1)

    li   x4, 0xFFFFFF80     # low byte = 0x80
    sb   x4, 4(x1)
    lb   x5, 4(x1)
    lbu  x6, 4(x1)

    li   x7, 0xFFFF8000     # low halfword = 0x8000
    sh   x7, 8(x1)
    lh   x8, 8(x1)
    lhu  x9, 8(x1)

    addi x10, x0, 0x7F
    sb   x10, 12(x1)
    lb   x11, 12(x1)
    lbu  x12, 12(x1)

    ebreak