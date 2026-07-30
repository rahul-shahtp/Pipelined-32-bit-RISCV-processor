# test_fibonacci.s -- Iterative Fibonacci using ADD, BEQ, JAL (control-flow stress)
#
# Computes fib(10) via iteration, no recursion, no MUL required.
#
# Expected final register state:
#   x5  = 0x00000037 (55)         a -> fib(10)
#   x6  = 0x00000059 (89)         b -> fib(11) (one step ahead)
#   x10 = 0x00000037 (55)         result = fib(10), copied from x5
#   x28 = 0x0000000a (10)         n = 10 (loop bound, unchanged)
#   x29 = 0x0000000a (10)         i = 10 (loop counter at exit)

.text
.globl _start
_start:
addi x5,  x0, 0         # x5 = a = fib(0)
addi x6,  x0, 1         # x6 = b = fib(1)
addi x28, x0, 10        # x28 = n = 10
addi x29, x0, 0         # x29 = i = 0

fib_loop:
beq  x29, x28, fib_done # exit when i == n
add  x7,  x5, x6        # t = a + b
add  x5,  x6, x0        # a = b
add  x6,  x7, x0        # b = t
addi x29, x29, 1        # i++
jal  x0,  fib_loop       # unconditional branch back

fib_done:
add  x10, x5, x0        # result = fib(10)

ebreak