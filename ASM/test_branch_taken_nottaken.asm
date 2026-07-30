# test_branch_taken_nottaken.s -- BEQ/BNE/BLT/BGE/BLTU/BGEU, each with a
# taken case and one not-taken case
#
# x3 is a running counter; trace it to confirm each branch resolved
# correctly. Any wrong-path "addi x3,x3,100" that executes means a
# flush bug. Final expected x3 = 0x00000011 (17).
.text
.globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 5
    addi x3, x0, 0

    beq  x1, x2, T1        # 5==5 -> taken
    addi x3, x3, 100        # dead code if flush works
T1:
    addi x3, x3, 1          # x3 = 1

    addi x4, x0, 6
    bne  x1, x4, T2         # 5!=6 -> taken
    addi x3, x3, 100
T2:
    addi x3, x3, 1           # x3 = 2

    beq  x1, x4, NT1          # 5!=6 -> NOT taken
    addi x3, x3, 10             # executes: x3 = 12
NT1:
    addi x3, x3, 1                # x3 = 13

    blt  x1, x4, T3                 # 5<6 -> taken
    addi x3, x3, 100
T3:
    addi x3, x3, 1                   # x3 = 14

    bge  x4, x1, T4                    # 6>=5 -> taken
    addi x3, x3, 100
T4:
    addi x3, x3, 1                      # x3 = 15

    addi x5, x0, -1                       # 0xffffffff
    bltu x1, x5, T5                        # unsigned: 5 < 0xffffffff -> taken
    addi x3, x3, 100
T5:
    addi x3, x3, 1                           # x3 = 16

    bgeu x5, x1, T6                            # unsigned: 0xffffffff >= 5 -> taken
    addi x3, x3, 100
T6:
    addi x3, x3, 1                               # x3 = 17

    ebreak