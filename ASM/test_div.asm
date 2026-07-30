# test_div.s -- M-extension: DIV, DIVU, REM, REMU including div-by-zero
# and the INT_MIN / -1 overflow case
#
# Expected final register state:
#   x3  = 0x00000003 (3)          div   20/6
#   x4  = 0x00000002 (2)          rem   20%6
#   x7  = 0xfffffffd (-3)         div  -20/6  (truncates toward zero)
#   x8  = 0xfffffffe (-2)         rem  -20%6
#   x11 = 0x00000003 (3)          divu  20/6
#   x12 = 0x00000002 (2)          remu  20%6
#   x15 = 0xffffffff (-1)         div   5/0   -> defined result: all-ones
#   x16 = 0xffffffff              divu  5/0   -> defined result: all-ones
#   x17 = 0x00000005 (5)          rem   5%0   -> defined result: dividend
#   x18 = 0x00000005 (5)          remu  5%0   -> defined result: dividend
#   x21 = 0x80000000 (INT_MIN)    div   INT_MIN / -1 -> defined result: INT_MIN (no trap)
#   x22 = 0x00000000 (0)          rem   INT_MIN % -1 -> defined result: 0
.text
.globl _start
_start:
    addi x1, x0, 20
    addi x2, x0, 6
    div  x3, x1, x2
    rem  x4, x1, x2

    addi x5, x0, -20
    addi x6, x0, 6
    div  x7, x5, x6
    rem  x8, x5, x6

    addi x9, x0, 20
    addi x10, x0, 6
    divu x11, x9, x10
    remu x12, x9, x10

    addi x13, x0, 5
    addi x14, x0, 0
    div  x15, x13, x14
    divu x16, x13, x14
    rem  x17, x13, x14
    remu x18, x13, x14

    li   x19, 0x80000000    # INT_MIN
    addi x20, x0, -1
    div  x21, x19, x20
    rem  x22, x19, x20

    ebreak