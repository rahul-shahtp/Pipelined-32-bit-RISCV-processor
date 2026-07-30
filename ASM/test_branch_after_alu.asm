# test_branch_after_alu.s -- (1) an ALU op immediately followed by a branch
# that consumes its result and (2) back-to-back branches, where a
# branch target is itself immediately followed by another branch.
#
# Expected final x3 = 0x00000004 (4)
.text
.globl _start
_start:
    addi x1, x0, 3
    addi x2, x0, 4
    addi x3, x0, 0

    # (a) ALU result consumed immediately by a taken branch
    add  x5, x1, x2          # x5 = 7
    beq  x5, x5, A_TAKEN       # depends on x5 from the instruction right before it
    addi x3, x3, 100            # dead code if flush/forwarding works
A_TAKEN:
    addi x3, x3, 1                # x3 = 1

    # (b) ALU result consumed immediately by a not-taken branch
    sub  x6, x2, x1            # x6 = 1
    beq  x6, x1, B_NOTTAKEN       # 1 != 3 -> not taken
    addi x3, x3, 1                  # executes: x3 = 2
B_NOTTAKEN:
    addi x3, x3, 1                    # x3 = 3

    # (c) back-to-back branches: landing from one branch straight into another
    beq  x1, x1, C_MID                  # always taken
    addi x3, x3, 100
C_MID:
    bne  x1, x2, C_END                    # 3 != 4 -> taken, immediately after landing
    addi x3, x3, 100
C_END:
    addi x3, x3, 1                          # x3 = 4

    ebreak