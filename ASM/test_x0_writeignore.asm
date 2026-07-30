# test_x0_writeignore.s -- x0 must always read as zero; writes to it
# (from either R-type or I-type instructions) must be silently discarded.
#
# Expected final register state:
#   x0 = 0x00000000  (always, regardless of attempted writes)
#   x2 = 0x0000007b (123)   0 + 123, confirms x0 was read as 0
#   x3 = 0x0000007b (123)   123 - 0, confirms x0 was read as 0
.text
.globl _start
_start:
    addi x1, x0, 123
    add  x0, x1, x1     # attempted write to x0 (R-type) -- must be ignored
    addi x0, x1, 5       # attempted write to x0 (I-type) -- must be ignored
    add  x2, x0, x1        # read x0 as a source operand
    sub  x3, x1, x0
    ebreak