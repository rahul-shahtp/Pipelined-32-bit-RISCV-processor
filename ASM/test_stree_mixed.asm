# test_stress_mixed.s -- mixed stress program: a loop with a nested
# branch (odd/even split), MUL to compute i*i, a load/store round-trip
# through data memory each iteration, and DIV/REM on the final sum.
#
# for i = 1..5:
#   if i is odd: sum += i*i
#   else:        even_count++
#   store i*i, load it back, accumulate into running_total
#
# Expected final register state:
#   x4  = 0x00000023 (35)   sum of squares of odd i (1+9+25)
#   x5  = 0x00000002 (2)    even_count (i=2,4)
#   x10 = 0x00000037 (55)   running_total via store/load round trip (1+4+9+16+25)
#   x11 = 0x00000008 (8)    div sum/4
#   x12 = 0x00000003 (3)    rem sum%4
.text
.globl _start
_start:
    addi x1, x0, 0x100     # data memory scratch base
    addi x2, x0, 1          # i = 1
    addi x3, x0, 5           # N = 5
    addi x4, x0, 0             # sum = 0
    addi x5, x0, 0              # even_count = 0
    addi x6, x0, 4                # divisor for final div/rem
    addi x10, x0, 0                 # running_total = 0

LOOP:
    blt  x3, x2, LOOP_END    # if N < i, exit loop
    mul  x7, x2, x2            # x7 = i*i
    andi x8, x2, 1               # x8 = i & 1
    beq  x8, x0, EVEN              # branch nested inside the loop
    add  x4, x4, x7                  # odd path: sum += i*i
    j    STORE
EVEN:
    addi x5, x5, 1                     # even path: even_count++
STORE:
    sw   x7, 0(x1)                       # store i*i
    lw   x9, 0(x1)                         # load it back
    add  x10, x10, x9                        # running_total += loaded value
    addi x2, x2, 1                             # i++
    j    LOOP

LOOP_END:
    div  x11, x4, x6
    rem  x12, x4, x6
    ebreak