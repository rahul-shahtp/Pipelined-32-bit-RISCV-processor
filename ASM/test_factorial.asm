# test_factorial.s -- Iterative Factorial using MUL, BLT, JAL (M-extension + control-flow)
#
# Computes 7! via iteration.
#
# Expected final register state:
#   x5  = 0x000013b0 (5040)       result = 7!
#   x6  = 0x00000008 (8)          i (loop counter, one past n at exit)
#   x10 = 0x000013b0 (5040)       result copied from x5
#   x28 = 0x00000007 (7)          n = 7 (loop bound, unchanged)

.text
.globl _start
_start:
addi x5,  x0, 1         # x5 = result = 1
addi x6,  x0, 1         # x6 = i = 1
addi x28, x0, 7         # x28 = n = 7

fact_loop:
blt  x28, x6, fact_done # exit when n < i
mul  x5,  x5, x6        # result *= i
addi x6,  x6, 1         # i++
jal  x0,  fact_loop      # unconditional branch back

fact_done:
add  x10, x5, x0        # result = 7!

ebreak